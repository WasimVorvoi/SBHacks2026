import Foundation

class AIService {
    static let shared = AIService()
    private let apiKey = "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"
    private let baseURL = "https://api.openai.com/v1/chat/completions"

    func rateDifficulty(
        title: String,
        description: String,
        deadline: Date,
        category: TaskCategory = .general,
        competitionMode: CompetitionMode = .privateOnly,
        timeFrameMinutes: Int = 0
    , completion: @escaping (Int) -> Void) {
        let hoursUntilDeadline = max(1, Int(deadline.timeIntervalSinceNow / 3600))

        let timeFrameDesc: String
        if timeFrameMinutes == 0 {
            timeFrameDesc = "Instant (must be done right now)"
        } else if timeFrameMinutes < 60 {
            timeFrameDesc = "\(timeFrameMinutes) minutes"
        } else {
            timeFrameDesc = "\(timeFrameMinutes / 60) hour(s)"
        }

        let competitionDesc: String
        switch competitionMode {
        case .privateOnly: competitionDesc = "Private (solo, no pressure)"
        case .friends: competitionDesc = "Friends (competing with friends)"
        case .global: competitionDesc = "Global (public leaderboard)"
        case .group: competitionDesc = "Group (team competition)"
        }

        let prompt = """
        Rate the difficulty of this task on a scale of 1-10 (1=trivial, 10=extremely hard).
        Consider ALL of these factors:

        Task: \(title)
        Details: \(description)
        Category: \(category.label)
        Time available until deadline: \(hoursUntilDeadline) hours
        Estimated time to complete: \(timeFrameDesc)
        Competition mode: \(competitionDesc)

        Rating guidelines:
        - Category matters: exams/projects are harder than chores/general tasks
        - Tighter deadlines increase difficulty
        - Shorter estimated time for complex tasks = harder
        - Competition modes with social pressure (global/group) add +1 difficulty
        - Instant tasks with tight windows are stressful = harder
        - Consider realistic effort needed for the category

        Respond with ONLY a single integer from 1-10, nothing else.
        """

        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "max_tokens": 10,
            "messages": [
                ["role": "user", "content": prompt]
            ]
        ]

        guard let url = URL(string: baseURL),
              let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            completion(estimateLocalDifficulty(title: title, description: description, hoursUntilDeadline: hoursUntilDeadline, category: category, competitionMode: competitionMode, timeFrameMinutes: timeFrameMinutes))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let choices = json["choices"] as? [[String: Any]],
                  let message = choices.first?["message"] as? [String: Any],
                  let text = message["content"] as? String,
                  let difficulty = Int(text.trimmingCharacters(in: .whitespacesAndNewlines)),
                  difficulty >= 1 && difficulty <= 10 else {
                let fallback = self?.estimateLocalDifficulty(title: title, description: description, hoursUntilDeadline: hoursUntilDeadline, category: category, competitionMode: competitionMode, timeFrameMinutes: timeFrameMinutes) ?? 5
                DispatchQueue.main.async { completion(fallback) }
                return
            }

            DispatchQueue.main.async { completion(difficulty) }
        }.resume()
    }

    private func estimateLocalDifficulty(
        title: String,
        description: String,
        hoursUntilDeadline: Int,
        category: TaskCategory,
        competitionMode: CompetitionMode,
        timeFrameMinutes: Int
    ) -> Int {
        let text = (title + " " + description).lowercased()
        var score = 5

        // Category base difficulty
        switch category {
        case .exam:     score += 2
        case .project:  score += 1
        case .homework: score += 1
        case .creative: score += 0
        case .reading:  score -= 1
        case .fitness:  score -= 1
        case .chores:   score -= 2
        case .general:  score += 0
        }

        // Keyword adjustments
        let hardWords = ["research", "build", "create", "develop", "design", "analyze", "write essay",
                         "presentation", "study for exam", "implement", "debug", "thesis", "report"]
        let easyWords = ["buy", "clean", "email", "call", "organize", "pack", "wash", "grocery", "laundry"]

        for word in hardWords where text.contains(word) { score += 1 }
        for word in easyWords where text.contains(word) { score -= 1 }

        // Deadline pressure
        if hoursUntilDeadline < 2 { score += 2 }
        else if hoursUntilDeadline < 6 { score += 1 }
        else if hoursUntilDeadline > 72 { score -= 1 }

        // Time frame — short estimated time for complex categories = harder
        if timeFrameMinutes == 0 {
            // Instant task
            score += 1
        } else if timeFrameMinutes <= 30 && (category == .exam || category == .project) {
            score += 1 // tight time for hard category
        } else if timeFrameMinutes >= 120 {
            score += 1 // long task = more effort
        }

        // Competition pressure
        switch competitionMode {
        case .global: score += 1
        case .group:  score += 1
        case .friends: score += 0
        case .privateOnly: score += 0
        }

        return max(1, min(10, score))
    }
}
