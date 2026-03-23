import Foundation

// MARK: - Task Status

enum TaskStatus: String, Codable {
    case pending
    case completedEarly
    case completedOnTime
    case completedLate
    case failed
}

// MARK: - Visibility / Competition Mode

enum CompetitionMode: String, Codable {
    case privateOnly = "private"
    case friends = "friends"
    case global = "global"
    case group = "group"
}

// MARK: - Category

enum TaskCategory: String, Codable, CaseIterable {
    case general
    case homework
    case exam
    case project
    case reading
    case fitness
    case creative
    case chores

    var label: String {
        switch self {
        case .general: return "General"
        case .homework: return "Homework"
        case .exam: return "Exam Prep"
        case .project: return "Project"
        case .reading: return "Reading"
        case .fitness: return "Fitness"
        case .creative: return "Creative"
        case .chores: return "Chores"
        }
    }

    var emoji: String {
        switch self {
        case .general: return "📋"
        case .homework: return "✏️"
        case .exam: return "🧠"
        case .project: return "🔨"
        case .reading: return "📖"
        case .fitness: return "🏃"
        case .creative: return "🎨"
        case .chores: return "🏠"
        }
    }
}

// MARK: - Task

struct TaskItem: Codable, Identifiable {
    let id: String
    var title: String
    var description: String
    var deadline: Double // milliseconds timestamp
    var timeFrameMinutes: Int // 0 = instant
    var difficulty: Int // 1-10
    var points: Int // calculated at creation
    var completed: Bool
    var completedAt: Double // 0 if incomplete
    var createdAt: Double
    var isInstant: Bool
    var startedAt: Double // 0 if not started
    var category: String
    var competitionMode: String
    var flagged: Bool
    var flagReason: String
    var assignedGroup: String

    var deadlineDate: Date {
        Date(timeIntervalSince1970: deadline / 1000)
    }

    var createdDate: Date {
        Date(timeIntervalSince1970: createdAt / 1000)
    }

    var completedDate: Date? {
        completedAt > 0 ? Date(timeIntervalSince1970: completedAt / 1000) : nil
    }

    var taskStatus: TaskStatus {
        if !completed { return .pending }
        if flagged { return .failed }
        // Determine early/on-time/late
        let deadlineMs = deadline
        let completedMs = completedAt
        if completedMs <= deadlineMs {
            let totalDuration = deadlineMs - createdAt
            let timeRemaining = deadlineMs - completedMs
            if totalDuration > 0 && timeRemaining > totalDuration * 0.1 {
                return .completedEarly
            }
            return .completedOnTime
        }
        return .completedLate
    }

    var categoryEnum: TaskCategory {
        TaskCategory(rawValue: category) ?? .general
    }

    var modeEnum: CompetitionMode {
        CompetitionMode(rawValue: competitionMode) ?? .privateOnly
    }

    init(title: String, description: String, deadline: Date, timeFrameMinutes: Int, difficulty: Int, category: TaskCategory, competitionMode: CompetitionMode, assignedGroup: String = "") {
        self.id = UUID().uuidString
        self.title = title
        self.description = description
        self.deadline = deadline.timeIntervalSince1970 * 1000
        self.timeFrameMinutes = timeFrameMinutes
        self.difficulty = difficulty
        self.points = PointsCalculator.calcPoints(difficulty: difficulty, timeMins: timeFrameMinutes, deadline: deadline, created: Date())
        self.completed = false
        self.completedAt = 0
        self.createdAt = Date().timeIntervalSince1970 * 1000
        self.isInstant = timeFrameMinutes == 0
        self.startedAt = 0
        self.category = category.rawValue
        self.competitionMode = competitionMode.rawValue
        self.flagged = false
        self.flagReason = ""
        self.assignedGroup = assignedGroup
    }

    // Init from Firebase dictionary
    init?(dict: [String: Any]) {
        guard let id = dict["id"] as? String,
              let title = dict["title"] as? String else { return nil }
        self.id = id
        self.title = title
        self.description = dict["description"] as? String ?? ""
        self.deadline = dict["deadline"] as? Double ?? 0
        self.timeFrameMinutes = dict["timeFrameMinutes"] as? Int ?? 0
        self.difficulty = dict["difficulty"] as? Int ?? 5
        self.points = dict["points"] as? Int ?? 0
        self.completed = dict["completed"] as? Bool ?? false
        self.completedAt = dict["completedAt"] as? Double ?? 0
        self.createdAt = dict["createdAt"] as? Double ?? 0
        self.isInstant = dict["isInstant"] as? Bool ?? false
        self.startedAt = dict["startedAt"] as? Double ?? 0
        self.category = dict["category"] as? String ?? "general"
        self.competitionMode = dict["competitionMode"] as? String ?? "private"
        self.flagged = dict["flagged"] as? Bool ?? false
        self.flagReason = dict["flagReason"] as? String ?? ""
        self.assignedGroup = dict["assignedGroup"] as? String ?? ""
    }

    func toDict() -> [String: Any] {
        return [
            "id": id,
            "title": title,
            "description": description,
            "deadline": deadline,
            "timeFrameMinutes": timeFrameMinutes,
            "difficulty": difficulty,
            "points": points,
            "completed": completed,
            "completedAt": completedAt,
            "createdAt": createdAt,
            "isInstant": isInstant,
            "startedAt": startedAt,
            "category": category,
            "competitionMode": competitionMode,
            "flagged": flagged,
            "flagReason": flagReason,
            "assignedGroup": assignedGroup
        ]
    }

    mutating func complete() {
        let now = Date().timeIntervalSince1970 * 1000
        self.completed = true
        self.completedAt = now

        // Cheat detection
        let cheatResult = PointsCalculator.checkCheat(task: self, completionMs: now)
        if cheatResult.suspicious {
            self.flagged = true
            self.flagReason = cheatResult.reason
            self.points = 0
        }
    }

    mutating func startTask() {
        self.startedAt = Date().timeIntervalSince1970 * 1000
    }
}
