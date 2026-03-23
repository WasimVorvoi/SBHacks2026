import Foundation

// MARK: - Profile

struct UserProfile: Codable {
    var id: String
    var name: String
    var emoji: String
    var totalPoints: Double
    var tasksCompleted: Int
    var streak: Int
    var bestStreak: Int
    var level: Int

    static let avatarOptions = ["⚡", "🔥", "🧠", "🎯", "💎", "🦊", "🐉", "👾", "🚀", "⚔️", "🎮", "🌟"]

    init(name: String, emoji: String = "⚡") {
        self.id = UUID().uuidString
        self.name = name
        self.emoji = emoji
        self.totalPoints = 0
        self.tasksCompleted = 0
        self.streak = 0
        self.bestStreak = 0
        self.level = 1
    }

    init?(dict: [String: Any]) {
        guard let id = dict["id"] as? String,
              let name = dict["name"] as? String else { return nil }
        self.id = id
        self.name = name
        self.emoji = dict["emoji"] as? String ?? "⚡"
        self.totalPoints = dict["totalPoints"] as? Double ?? 0
        self.tasksCompleted = dict["tasksCompleted"] as? Int ?? 0
        self.streak = dict["streak"] as? Int ?? 0
        self.bestStreak = dict["bestStreak"] as? Int ?? 0
        self.level = dict["level"] as? Int ?? 1
    }

    func toDict() -> [String: Any] {
        return [
            "id": id,
            "name": name,
            "emoji": emoji,
            "totalPoints": totalPoints,
            "tasksCompleted": tasksCompleted,
            "streak": streak,
            "bestStreak": bestStreak,
            "level": level
        ]
    }

    mutating func updateLevel() {
        self.level = PointsCalculator.calcLevel(totalPoints: totalPoints)
    }

    var levelTitle: String {
        PointsCalculator.levelTitle(level: level)
    }

    var levelProgress: Double {
        PointsCalculator.levelProgress(points: totalPoints)
    }
}

// MARK: - Group

struct ClutchGroup: Codable {
    var name: String
    var code: String
    var creatorId: String
    var createdAt: Double
    var timeLimitDays: Int // -1 = unlimited
    var race: GroupRace?
    var members: [String: GroupMember]
    var memberTasks: [String: [TaskItem]]

    init(name: String, creatorId: String, timeLimitDays: Int = -1, race: GroupRace? = nil) {
        self.name = name
        self.code = ClutchGroup.generateCode()
        self.creatorId = creatorId
        self.createdAt = Date().timeIntervalSince1970 * 1000
        self.timeLimitDays = timeLimitDays
        self.race = race
        self.members = [:]
        self.memberTasks = [:]
    }

    init?(dict: [String: Any]) {
        guard let name = dict["name"] as? String,
              let code = dict["code"] as? String else { return nil }
        self.name = name
        self.code = code
        self.creatorId = dict["creatorId"] as? String ?? ""
        self.createdAt = dict["createdAt"] as? Double ?? 0
        self.timeLimitDays = dict["timeLimitDays"] as? Int ?? -1

        if let raceDict = dict["race"] as? [String: Any] {
            self.race = GroupRace(dict: raceDict)
        } else {
            self.race = nil
        }

        self.members = [:]
        if let membersDict = dict["members"] as? [String: [String: Any]] {
            for (key, val) in membersDict {
                if let member = GroupMember(dict: val) {
                    self.members[key] = member
                }
            }
        }

        self.memberTasks = [:]
        if let tasksDict = dict["memberTasks"] as? [String: Any] {
            for (userId, tasksVal) in tasksDict {
                var tasks: [TaskItem] = []
                if let taskArray = tasksVal as? [[String: Any]] {
                    for td in taskArray {
                        if let task = TaskItem(dict: td) {
                            tasks.append(task)
                        }
                    }
                }
                self.memberTasks[userId] = tasks
            }
        }
    }

    func toDict() -> [String: Any] {
        var dict: [String: Any] = [
            "name": name,
            "code": code,
            "creatorId": creatorId,
            "createdAt": createdAt,
            "timeLimitDays": timeLimitDays
        ]
        if let race = race {
            dict["race"] = race.toDict()
        }
        var membersDict: [String: Any] = [:]
        for (key, member) in members {
            membersDict[key] = member.toDict()
        }
        dict["members"] = membersDict
        return dict
    }

    static func generateCode() -> String {
        let chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<6).map { _ in chars.randomElement()! })
    }

    func leaderboard() -> [(member: GroupMember, points: Int, tasksDone: Int)] {
        return members.values.map { member in
            let tasks = memberTasks[member.id] ?? []
            let pts = tasks.filter { $0.completed && !$0.flagged }.reduce(0) { $0 + $1.points }
            let done = tasks.filter { $0.completed }.count
            return (member: member, points: pts, tasksDone: done)
        }.sorted { $0.points > $1.points }
    }
}

struct GroupMember: Codable {
    var id: String
    var name: String
    var emoji: String

    init(id: String, name: String, emoji: String) {
        self.id = id
        self.name = name
        self.emoji = emoji
    }

    init?(dict: [String: Any]) {
        guard let id = dict["id"] as? String,
              let name = dict["name"] as? String else { return nil }
        self.id = id
        self.name = name
        self.emoji = dict["emoji"] as? String ?? "⚡"
    }

    func toDict() -> [String: Any] {
        return ["id": id, "name": name, "emoji": emoji]
    }
}

struct GroupRace: Codable {
    var targetPoints: Int
    var winnerId: String?
    var winnerName: String?
    var wonAt: Double?

    init(targetPoints: Int) {
        self.targetPoints = targetPoints
    }

    init?(dict: [String: Any]) {
        guard let target = dict["targetPoints"] as? Int else { return nil }
        self.targetPoints = target
        self.winnerId = dict["winnerId"] as? String
        self.winnerName = dict["winnerName"] as? String
        self.wonAt = dict["wonAt"] as? Double
    }

    func toDict() -> [String: Any] {
        var d: [String: Any] = ["targetPoints": targetPoints]
        if let wid = winnerId { d["winnerId"] = wid }
        if let wname = winnerName { d["winnerName"] = wname }
        if let wat = wonAt { d["wonAt"] = wat }
        return d
    }
}

// MARK: - Leaderboard Entry (for display)

struct LeaderboardEntry {
    let name: String
    let emoji: String
    let points: Double
    let tasksCompleted: Int
    let currentStreak: Int
    let level: Int
    let completedGoals: [CompletedGoal]
}

struct CompletedGoal {
    let title: String
    let difficulty: Int
    let pointsEarned: Int
    let status: TaskStatus
    let completedAgo: String
    let category: String
}
