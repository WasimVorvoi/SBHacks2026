import Foundation

struct Challenge {
    let id: String
    let icon: String
    let title: String
    let desc: String
    let bonusPts: Int
    let category: ChallengeCategory
    let check: ([TaskItem], UserProfile) -> Double
}

enum ChallengeCategory: String {
    case daily, weekly, milestone
}

class ChallengesManager {
    static let shared = ChallengesManager()

    private let completedKey = "clutch_completed_challenges"
    private let lastDailyResetKey = "clutch_daily_reset"
    private let lastWeeklyResetKey = "clutch_weekly_reset"

    var completedChallengeIds: Set<String> {
        didSet { saveCompleted() }
    }

    private init() {
        if let arr = UserDefaults.standard.array(forKey: completedKey) as? [String] {
            completedChallengeIds = Set(arr)
        } else {
            completedChallengeIds = []
        }
        checkResets()
    }

    private func saveCompleted() {
        UserDefaults.standard.set(Array(completedChallengeIds), forKey: completedKey)
    }

    private func checkResets() {
        let cal = Calendar.current
        let now = Date()

        if let last = UserDefaults.standard.object(forKey: lastDailyResetKey) as? Date {
            if !cal.isDate(last, inSameDayAs: now) {
                let dailyIds = allChallenges.filter { $0.category == .daily }.map { $0.id }
                completedChallengeIds.subtract(dailyIds)
                UserDefaults.standard.set(now, forKey: lastDailyResetKey)
            }
        } else {
            UserDefaults.standard.set(now, forKey: lastDailyResetKey)
        }

        if let last = UserDefaults.standard.object(forKey: lastWeeklyResetKey) as? Date {
            let lastWeek = cal.component(.weekOfYear, from: last)
            let thisWeek = cal.component(.weekOfYear, from: now)
            if lastWeek != thisWeek {
                let weeklyIds = allChallenges.filter { $0.category == .weekly }.map { $0.id }
                completedChallengeIds.subtract(weeklyIds)
                UserDefaults.standard.set(now, forKey: lastWeeklyResetKey)
            }
        } else {
            UserDefaults.standard.set(now, forKey: lastWeeklyResetKey)
        }
    }

    func checkAndComplete(tasks: [TaskItem], profile: UserProfile) -> [Challenge] {
        var newlyCompleted: [Challenge] = []
        for challenge in allChallenges {
            if completedChallengeIds.contains(challenge.id) { continue }
            let progress = challenge.check(tasks, profile)
            if progress >= 1.0 {
                completedChallengeIds.insert(challenge.id)
                newlyCompleted.append(challenge)
            }
        }
        return newlyCompleted
    }

    // MARK: - Helpers

    static func todayTasks(_ tasks: [TaskItem]) -> [TaskItem] {
        let cal = Calendar.current
        let now = Date()
        return tasks.filter { t in
            guard t.completed, !t.flagged, let cd = t.completedDate else { return false }
            return cal.isDate(cd, inSameDayAs: now)
        }
    }

    static func weekTasks(_ tasks: [TaskItem]) -> [TaskItem] {
        let weekAgo = Date().addingTimeInterval(-604800)
        return tasks.filter { t in
            guard t.completed, !t.flagged, let cd = t.completedDate else { return false }
            return cd >= weekAgo
        }
    }

    // MARK: - All Challenges

    lazy var allChallenges: [Challenge] = {
        var list: [Challenge] = []
        buildDaily(&list)
        buildWeekly(&list)
        buildMilestones(&list)
        return list
    }()

    private func buildDaily(_ list: inout [Challenge]) {
        list.append(Challenge(id: "early_bird", icon: "sunrise.fill", title: "Early Bird",
                              desc: "Complete 1 task today", bonusPts: 25, category: .daily,
                              check: { t, _ in min(1.0, Double(ChallengesManager.todayTasks(t).count)) }))

        list.append(Challenge(id: "hat_trick", icon: "3.circle.fill", title: "Hat Trick",
                              desc: "Complete 3 tasks in one day", bonusPts: 75, category: .daily,
                              check: { t, _ in min(1.0, Double(ChallengesManager.todayTasks(t).count) / 3.0) }))

        list.append(Challenge(id: "on_fire", icon: "flame.fill", title: "On Fire",
                              desc: "Complete 5 tasks in one day", bonusPts: 150, category: .daily,
                              check: { t, _ in min(1.0, Double(ChallengesManager.todayTasks(t).count) / 5.0) }))

        list.append(Challenge(id: "clutch_play", icon: "bolt.fill", title: "Clutch Play",
                              desc: "Complete 8+ difficulty task today", bonusPts: 100, category: .daily,
                              check: { t, _ in ChallengesManager.todayTasks(t).contains { $0.difficulty >= 8 } ? 1.0 : 0.0 }))

        list.append(Challenge(id: "speed_run", icon: "hare.fill", title: "Speed Run",
                              desc: "Complete 2 tasks within 1 hour", bonusPts: 80, category: .daily,
                              check: { t, _ in
            let today = ChallengesManager.todayTasks(t).sorted { $0.completedAt < $1.completedAt }
            let cnt = today.count
            if cnt >= 2 {
                for i in 0..<(cnt - 1) {
                    if today[i + 1].completedAt - today[i].completedAt <= 3600000 { return 1.0 }
                }
            }
            return min(0.5, Double(cnt) / 4.0)
        }))
    }

    private func buildWeekly(_ list: inout [Challenge]) {
        list.append(Challenge(id: "grind_mode", icon: "repeat", title: "Grind Mode",
                              desc: "Complete 10 tasks this week", bonusPts: 200, category: .weekly,
                              check: { t, _ in min(1.0, Double(ChallengesManager.weekTasks(t).count) / 10.0) }))

        list.append(Challenge(id: "point_chaser", icon: "star.fill", title: "Point Chaser",
                              desc: "Earn 500 pts this week", bonusPts: 250, category: .weekly,
                              check: { t, _ in
            let pts = ChallengesManager.weekTasks(t).reduce(0) { $0 + $1.points }
            return min(1.0, Double(pts) / 500.0)
        }))

        list.append(Challenge(id: "elite_grinder", icon: "crown.fill", title: "Elite Grinder",
                              desc: "Earn 1000 pts this week", bonusPts: 500, category: .weekly,
                              check: { t, _ in
            let pts = ChallengesManager.weekTasks(t).reduce(0) { $0 + $1.points }
            return min(1.0, Double(pts) / 1000.0)
        }))

        list.append(Challenge(id: "hard_mode", icon: "exclamationmark.triangle.fill", title: "Hard Mode",
                              desc: "Complete 3 difficulty 7+ tasks this week", bonusPts: 300, category: .weekly,
                              check: { t, _ in
            let count = ChallengesManager.weekTasks(t).filter { $0.difficulty >= 7 }.count
            return min(1.0, Double(count) / 3.0)
        }))

        list.append(Challenge(id: "extreme_run", icon: "bolt.horizontal.fill", title: "Extreme Run",
                              desc: "Complete 1 difficulty 10 task", bonusPts: 400, category: .weekly,
                              check: { t, _ in ChallengesManager.weekTasks(t).contains { $0.difficulty == 10 } ? 1.0 : 0.0 }))

        list.append(Challenge(id: "consistent", icon: "calendar.badge.checkmark", title: "Consistent",
                              desc: "Complete 1+ task daily for 5 days", bonusPts: 350, category: .weekly,
                              check: { t, _ in
            var days = Set<String>()
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd"
            for task in ChallengesManager.weekTasks(t) {
                if let d = task.completedDate { days.insert(df.string(from: d)) }
            }
            return min(1.0, Double(days.count) / 5.0)
        }))

        list.append(Challenge(id: "study_grind", icon: "book.fill", title: "Study Grind",
                              desc: "300 pts from Exam Prep tasks", bonusPts: 200, category: .weekly,
                              check: { t, _ in
            let pts = ChallengesManager.weekTasks(t).filter { $0.category == "exam" }.reduce(0) { $0 + $1.points }
            return min(1.0, Double(pts) / 300.0)
        }))

        list.append(Challenge(id: "fitness_freak", icon: "figure.run", title: "Fitness Freak",
                              desc: "Complete 5 Fitness tasks", bonusPts: 175, category: .weekly,
                              check: { t, _ in
            let count = ChallengesManager.weekTasks(t).filter { $0.category == "fitness" }.count
            return min(1.0, Double(count) / 5.0)
        }))

        list.append(Challenge(id: "creative_burst", icon: "paintbrush.fill", title: "Creative Burst",
                              desc: "Complete 3 Creative tasks", bonusPts: 150, category: .weekly,
                              check: { t, _ in
            let count = ChallengesManager.weekTasks(t).filter { $0.category == "creative" }.count
            return min(1.0, Double(count) / 3.0)
        }))

        list.append(Challenge(id: "project_mode", icon: "hammer.fill", title: "Project Mode",
                              desc: "400 pts from Project tasks", bonusPts: 250, category: .weekly,
                              check: { t, _ in
            let pts = ChallengesManager.weekTasks(t).filter { $0.category == "project" }.reduce(0) { $0 + $1.points }
            return min(1.0, Double(pts) / 400.0)
        }))

        list.append(Challenge(id: "renaissance", icon: "paintpalette.fill", title: "Renaissance",
                              desc: "Complete a task in every category this week", bonusPts: 400, category: .weekly,
                              check: { t, _ in
            let cats = Set(ChallengesManager.weekTasks(t).map { $0.category })
            let total = Double(TaskCategory.allCases.count)
            return min(1.0, Double(cats.count) / total)
        }))
    }

    private func buildMilestones(_ list: inout [Challenge]) {
        list.append(Challenge(id: "getting_started", icon: "flag.fill", title: "Getting Started",
                              desc: "Complete 10 tasks total", bonusPts: 100, category: .milestone,
                              check: { _, p in min(1.0, Double(p.tasksCompleted) / 10.0) }))

        list.append(Challenge(id: "committed", icon: "medal.fill", title: "Committed",
                              desc: "Complete 50 tasks total", bonusPts: 300, category: .milestone,
                              check: { _, p in min(1.0, Double(p.tasksCompleted) / 50.0) }))

        list.append(Challenge(id: "century_club", icon: "trophy.fill", title: "Century Club",
                              desc: "Complete 100 tasks total", bonusPts: 750, category: .milestone,
                              check: { _, p in min(1.0, Double(p.tasksCompleted) / 100.0) }))

        list.append(Challenge(id: "unbreakable", icon: "flame.circle.fill", title: "Unbreakable",
                              desc: "Reach 10-day streak", bonusPts: 500, category: .milestone,
                              check: { _, p in min(1.0, Double(p.bestStreak) / 10.0) }))
    }

    func challengesByCategory() -> [(String, [Challenge])] {
        return [
            ("Daily", allChallenges.filter { $0.category == .daily }),
            ("Weekly", allChallenges.filter { $0.category == .weekly }),
            ("Milestones", allChallenges.filter { $0.category == .milestone })
        ]
    }
}
