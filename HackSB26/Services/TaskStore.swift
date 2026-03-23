import Foundation

class TaskStore {
    static let shared = TaskStore()

    private let stateKey = "clutch_state"

    var tasks: [TaskItem] {
        didSet { save() }
    }

    var profile: UserProfile {
        didSet { save() }
    }

    var myGroupCodes: [String] {
        didSet { save() }
    }

    var onboarded: Bool {
        didSet { save() }
    }

    private init() {
        if let data = UserDefaults.standard.data(forKey: stateKey),
           let state = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {

            if let profileDict = state["profile"] as? [String: Any],
               let p = UserProfile(dict: profileDict) {
                self.profile = p
            } else {
                self.profile = UserProfile(name: "Player")
            }

            if let taskDicts = state["tasks"] as? [[String: Any]] {
                self.tasks = taskDicts.compactMap { TaskItem(dict: $0) }
            } else {
                self.tasks = []
            }

            self.myGroupCodes = state["myGroupCodes"] as? [String] ?? []
            self.onboarded = state["onboarded"] as? Bool ?? false
        } else {
            self.profile = UserProfile(name: "Player")
            self.tasks = []
            self.myGroupCodes = []
            self.onboarded = false
        }
    }

    private func save() {
        let state: [String: Any] = [
            "onboarded": onboarded,
            "profile": profile.toDict(),
            "tasks": tasks.map { $0.toDict() },
            "myGroupCodes": myGroupCodes
        ]
        if let data = try? JSONSerialization.data(withJSONObject: state) {
            UserDefaults.standard.set(data, forKey: stateKey)
        }
    }

    // MARK: - Task Operations

    func addTask(_ task: TaskItem) {
        tasks.append(task)
        syncToFirebase()
    }

    func completeTask(id: String) {
        guard let index = tasks.firstIndex(where: { $0.id == id }) else { return }
        tasks[index].complete()

        if !tasks[index].flagged {
            profile.totalPoints += Double(tasks[index].points)
            profile.tasksCompleted += 1
            profile.streak += 1
            if profile.streak > profile.bestStreak {
                profile.bestStreak = profile.streak
            }
            profile.updateLevel()
        }
        syncToFirebase()
    }

    func startTask(id: String) {
        guard let index = tasks.firstIndex(where: { $0.id == id }) else { return }
        tasks[index].startTask()
    }

    func deleteTask(id: String) {
        tasks.removeAll { $0.id == id }
        syncToFirebase()
    }

    func tasksForDate(_ date: Date) -> [TaskItem] {
        let calendar = Calendar.current
        return tasks.filter { calendar.isDate($0.deadlineDate, inSameDayAs: date) }
    }

    func pendingTasks() -> [TaskItem] {
        return tasks.filter { !$0.completed }.sorted { $0.deadline < $1.deadline }
    }

    func completedTasks() -> [TaskItem] {
        return tasks.filter { $0.completed }
    }

    // MARK: - Firebase Sync

    func syncToFirebase() {
        // Sync to global leaderboard
        FirebaseService.shared.syncLeaderboard(profile: profile, tasks: tasks)

        // Sync tasks to all joined groups
        for code in myGroupCodes {
            FirebaseService.shared.syncTasksToGroup(
                code: code,
                userId: profile.id,
                profile: profile,
                tasks: tasks
            ) { _ in }
        }
    }

    // MARK: - Leaderboard

    func fetchGlobalLeaderboard(timeFrame: String = "allTime", completion: @escaping ([LeaderboardEntry]) -> Void) {
        FirebaseService.shared.fetchLeaderboard { entries in
            var result: [LeaderboardEntry] = []

            for dict in entries {
                let name = dict["name"] as? String ?? "Unknown"
                let emoji = dict["emoji"] as? String ?? "⚡"
                let points: Double
                if timeFrame == "weekly" {
                    points = dict["weeklyPts"] as? Double ?? Double(dict["weeklyPts"] as? Int ?? 0)
                } else {
                    points = dict["allTimePts"] as? Double ?? Double(dict["allTimePts"] as? Int ?? 0)
                }

                let entry = LeaderboardEntry(
                    name: name,
                    emoji: emoji,
                    points: points,
                    tasksCompleted: 0,
                    currentStreak: 0,
                    level: PointsCalculator.calcLevel(totalPoints: points),
                    completedGoals: []
                )
                result.append(entry)
            }

            // Make sure current user is included
            let myId = self.profile.id
            if !entries.contains(where: { ($0["id"] as? String) == myId }) {
                let myPts = timeFrame == "weekly" ? self.weeklyPoints() : self.profile.totalPoints
                let myEntry = LeaderboardEntry(
                    name: self.profile.name,
                    emoji: self.profile.emoji,
                    points: myPts,
                    tasksCompleted: self.profile.tasksCompleted,
                    currentStreak: self.profile.streak,
                    level: self.profile.level,
                    completedGoals: self.completedTasks().map { task in
                        CompletedGoal(
                            title: task.title,
                            difficulty: task.difficulty,
                            pointsEarned: task.points,
                            status: task.taskStatus,
                            completedAgo: "Recently",
                            category: task.category
                        )
                    }
                )
                result.append(myEntry)
            }

            completion(result.sorted { $0.points > $1.points })
        }
    }

    func fetchFriendsLeaderboard(completion: @escaping ([LeaderboardEntry]) -> Void) {
        FirebaseService.shared.fetchFriends(userId: profile.id) { friends, _, _ in
            var result: [LeaderboardEntry] = []
            let group = DispatchGroup()

            // Add self
            let myEntry = LeaderboardEntry(
                name: self.profile.name,
                emoji: self.profile.emoji,
                points: self.profile.totalPoints,
                tasksCompleted: self.profile.tasksCompleted,
                currentStreak: self.profile.streak,
                level: self.profile.level,
                completedGoals: []
            )
            result.append(myEntry)

            for friend in friends {
                guard let friendId = friend["id"] as? String else { continue }
                group.enter()
                FirebaseService.shared.fetchLeaderboardEntry(userId: friendId) { data in
                    if let data = data {
                        let name = data["name"] as? String ?? "Unknown"
                        let emoji = data["emoji"] as? String ?? "⚡"
                        let pts = data["allTimePts"] as? Double ?? Double(data["allTimePts"] as? Int ?? 0)
                        let entry = LeaderboardEntry(
                            name: name,
                            emoji: emoji,
                            points: pts,
                            tasksCompleted: 0,
                            currentStreak: 0,
                            level: PointsCalculator.calcLevel(totalPoints: pts),
                            completedGoals: []
                        )
                        result.append(entry)
                    }
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                completion(result.sorted { $0.points > $1.points })
            }
        }
    }

    private func weeklyPoints() -> Double {
        let now = Date().timeIntervalSince1970 * 1000
        let weekAgo = now - 604_800_000
        return Double(tasks
            .filter { $0.completed && !$0.flagged && $0.completedAt >= weekAgo }
            .reduce(0) { $0 + $1.points })
    }

    // Fallback local leaderboard (used if offline)
    func globalLeaderboard() -> [LeaderboardEntry] {
        let userGoals = completedTasks().map { task in
            CompletedGoal(
                title: task.title,
                difficulty: task.difficulty,
                pointsEarned: task.points,
                status: task.taskStatus,
                completedAgo: "Recently",
                category: task.category
            )
        }

        var entries: [LeaderboardEntry] = [
            LeaderboardEntry(name: profile.name, emoji: profile.emoji, points: profile.totalPoints, tasksCompleted: profile.tasksCompleted, currentStreak: profile.streak, level: profile.level, completedGoals: userGoals)
        ]

        entries += [
            LeaderboardEntry(name: "Alex", emoji: "🔥", points: 340, tasksCompleted: 12, currentStreak: 5, level: 3, completedGoals: [
                CompletedGoal(title: "Study for calculus exam", difficulty: 8, pointsEarned: 100, status: .completedEarly, completedAgo: "1h ago", category: "exam"),
                CompletedGoal(title: "Finish lab report", difficulty: 7, pointsEarned: 70, status: .completedOnTime, completedAgo: "3h ago", category: "project"),
            ]),
            LeaderboardEntry(name: "Jordan", emoji: "🧠", points: 285, tasksCompleted: 10, currentStreak: 3, level: 2, completedGoals: [
                CompletedGoal(title: "Build portfolio website", difficulty: 9, pointsEarned: 112, status: .completedEarly, completedAgo: "2h ago", category: "project"),
            ]),
            LeaderboardEntry(name: "Sam", emoji: "🎯", points: 220, tasksCompleted: 8, currentStreak: 2, level: 2, completedGoals: [
                CompletedGoal(title: "Run 5K", difficulty: 6, pointsEarned: 75, status: .completedEarly, completedAgo: "4h ago", category: "fitness"),
            ]),
            LeaderboardEntry(name: "Casey", emoji: "💎", points: 175, tasksCompleted: 7, currentStreak: 1, level: 2, completedGoals: []),
            LeaderboardEntry(name: "Riley", emoji: "🚀", points: 130, tasksCompleted: 5, currentStreak: 0, level: 1, completedGoals: []),
        ]

        return entries.sorted { $0.points > $1.points }
    }
}
