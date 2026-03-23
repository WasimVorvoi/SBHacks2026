import Foundation

// Matches the website's scoring exactly
enum PointsCalculator {

    // Points = Base + TimeBonus + UrgencyBonus
    static func calcPoints(difficulty: Int, timeMins: Int, deadline: Date, created: Date) -> Int {
        let base = difficulty * 10

        // TimeBonus: shorter time frame = more bonus
        let timeBonus: Int
        if timeMins > 0 {
            let hours = timeMins / 60
            timeBonus = max(1, 6 - hours) * 5
        } else {
            timeBonus = 25 // instant tasks get max time bonus
        }

        // UrgencyBonus: tighter deadline = more bonus
        let hoursUntilDeadline = deadline.timeIntervalSince(created) / 3600
        let urgencyBonus: Int
        if hoursUntilDeadline < 24 {
            urgencyBonus = 20
        } else if hoursUntilDeadline < 72 {
            urgencyBonus = 10
        } else {
            urgencyBonus = 0
        }

        return base + timeBonus + urgencyBonus
    }

    // Level = totalPoints / 150 + 1
    static func calcLevel(totalPoints: Double) -> Int {
        return max(1, Int(totalPoints / 150) + 1)
    }

    // Progress to next level (0.0 - 1.0)
    static func levelProgress(points: Double) -> Double {
        let currentThreshold = Double((calcLevel(totalPoints: points) - 1)) * 150
        let nextThreshold = currentThreshold + 150
        if nextThreshold <= currentThreshold { return 1.0 }
        return (points - currentThreshold) / (nextThreshold - currentThreshold)
    }

    // Level tier title
    static func levelTitle(level: Int) -> String {
        switch level {
        case 1...5: return "Rookie"
        case 6...10: return "Grinder"
        case 11...20: return "Warrior"
        case 21...35: return "Elite"
        case 36...50: return "Legend"
        default: return "Mythic"
        }
    }

    // Cheat detection — matches website logic
    static func checkCheat(task: TaskItem, completionMs: Double) -> (suspicious: Bool, reason: String) {
        let elapsedMs = completionMs - task.createdAt
        let elapsedMins = elapsedMs / 60000

        // Instant tasks: must be within ±5 min of deadline
        if task.isInstant {
            let diffFromDeadline = abs(completionMs - task.deadline)
            if diffFromDeadline > 5 * 60 * 1000 {
                return (true, "Instant task completed outside the ±5 min window")
            }
        }

        // Timed tasks: if completed in < 70% of estimated time
        if task.timeFrameMinutes > 0 && task.startedAt > 0 {
            let activeMs = completionMs - task.startedAt
            let activeMins = activeMs / 60000
            let threshold = Double(task.timeFrameMinutes) * 0.7
            if activeMins < threshold && task.difficulty >= 5 {
                return (true, "Completed in \(Int(activeMins))m — expected at least \(Int(threshold))m")
            }
        }

        return (false, "")
    }

    // Difficulty color hex (matches website)
    static func difficultyLabel(_ difficulty: Int) -> String {
        switch difficulty {
        case 1...3: return "Easy"
        case 4...6: return "Medium"
        case 7...8: return "Hard"
        default: return "Extreme"
        }
    }
}
