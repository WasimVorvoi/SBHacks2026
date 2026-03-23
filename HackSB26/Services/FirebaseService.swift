import Foundation

class FirebaseService {
    static let shared = FirebaseService()

    private let baseURL = "https://clutch-15e64-default-rtdb.firebaseio.com"

    // MARK: - Global Leaderboard (matches website: leaderboard/{userId})

    func syncLeaderboard(profile: UserProfile, tasks: [TaskItem]) {
        let now = Date().timeIntervalSince1970 * 1000
        let weekAgo = now - 604_800_000 // 7 days in ms

        let weeklyPts = tasks
            .filter { $0.completed && !$0.flagged && $0.completedAt >= weekAgo }
            .reduce(0) { $0 + $1.points }

        let entry: [String: Any] = [
            "id": profile.id,
            "name": profile.name,
            "emoji": profile.emoji,
            "weeklyPts": weeklyPts,
            "allTimePts": profile.totalPoints,
            "updatedAt": now
        ]

        putJSON(path: "leaderboard/\(profile.id)", body: entry) { _ in }
    }

    func fetchLeaderboard(completion: @escaping ([[String: Any]]) -> Void) {
        getJSON(path: "leaderboard") { data in
            guard let dict = data as? [String: [String: Any]] else {
                completion([])
                return
            }
            let entries = dict.values.map { $0 }
            completion(entries)
        }
    }

    func fetchLeaderboardEntry(userId: String, completion: @escaping ([String: Any]?) -> Void) {
        getJSON(path: "leaderboard/\(userId)") { data in
            completion(data as? [String: Any])
        }
    }

    // MARK: - Friends (matches website: friends/{userId}/...)

    func sendFriendRequest(from: UserProfile, toId: String, toName: String, toEmoji: String, completion: @escaping (Bool) -> Void) {
        let now = Date().timeIntervalSince1970 * 1000
        let outgoing: [String: Any] = ["id": toId, "name": toName, "emoji": toEmoji, "sentAt": now]
        let incoming: [String: Any] = ["id": from.id, "name": from.name, "emoji": from.emoji, "sentAt": now]

        putJSON(path: "friends/\(from.id)/outgoing/\(toId)", body: outgoing) { _ in }
        putJSON(path: "friends/\(toId)/incoming/\(from.id)", body: incoming) { success in
            completion(success)
        }
    }

    func acceptFriend(myProfile: UserProfile, friendId: String, friendName: String, friendEmoji: String, completion: @escaping (Bool) -> Void) {
        let myData: [String: Any] = ["id": myProfile.id, "name": myProfile.name, "emoji": myProfile.emoji]
        let friendData: [String: Any] = ["id": friendId, "name": friendName, "emoji": friendEmoji]

        // Add to both friend lists
        putJSON(path: "friends/\(myProfile.id)/list/\(friendId)", body: friendData) { _ in }
        putJSON(path: "friends/\(friendId)/list/\(myProfile.id)", body: myData) { _ in }

        // Remove pending requests
        deleteJSON(path: "friends/\(myProfile.id)/incoming/\(friendId)") { _ in }
        deleteJSON(path: "friends/\(friendId)/outgoing/\(myProfile.id)") { success in
            completion(success)
        }
    }

    func declineFriend(myId: String, friendId: String, completion: @escaping (Bool) -> Void) {
        deleteJSON(path: "friends/\(myId)/incoming/\(friendId)") { _ in }
        deleteJSON(path: "friends/\(friendId)/outgoing/\(myId)") { success in
            completion(success)
        }
    }

    func removeFriend(myId: String, friendId: String, completion: @escaping (Bool) -> Void) {
        deleteJSON(path: "friends/\(myId)/list/\(friendId)") { _ in }
        deleteJSON(path: "friends/\(friendId)/list/\(myId)") { success in
            completion(success)
        }
    }

    func fetchFriends(userId: String, completion: @escaping ([[String: Any]], [[String: Any]], [[String: Any]]) -> Void) {
        var friendsList: [[String: Any]] = []
        var incomingList: [[String: Any]] = []
        var outgoingList: [[String: Any]] = []
        let group = DispatchGroup()

        group.enter()
        getJSON(path: "friends/\(userId)/list") { data in
            if let dict = data as? [String: [String: Any]] {
                friendsList = Array(dict.values)
            }
            group.leave()
        }

        group.enter()
        getJSON(path: "friends/\(userId)/incoming") { data in
            if let dict = data as? [String: [String: Any]] {
                incomingList = Array(dict.values)
            }
            group.leave()
        }

        group.enter()
        getJSON(path: "friends/\(userId)/outgoing") { data in
            if let dict = data as? [String: [String: Any]] {
                outgoingList = Array(dict.values)
            }
            group.leave()
        }

        group.notify(queue: .main) {
            completion(friendsList, incomingList, outgoingList)
        }
    }

    // MARK: - Groups (matches website: groups/{code}/...)

    func createGroup(_ group: ClutchGroup, completion: @escaping (Bool) -> Void) {
        var dict = group.toDict()
        dict["memberTasks"] = [String: Any]()
        putJSON(path: "groups/\(group.code)", body: dict) { success in
            completion(success)
        }
    }

    func joinGroup(code: String, member: GroupMember, completion: @escaping (ClutchGroup?) -> Void) {
        fetchGroup(code: code) { group in
            guard var group = group else {
                completion(nil)
                return
            }
            group.members[member.id] = member
            self.putJSON(path: "groups/\(code)/members/\(member.id)", body: member.toDict()) { _ in
                completion(group)
            }
        }
    }

    func fetchGroup(code: String, completion: @escaping (ClutchGroup?) -> Void) {
        getJSON(path: "groups/\(code)") { data in
            guard let dict = data as? [String: Any] else {
                completion(nil)
                return
            }
            completion(ClutchGroup(dict: dict))
        }
    }

    func leaveGroup(code: String, userId: String, completion: @escaping (Bool) -> Void) {
        deleteJSON(path: "groups/\(code)/members/\(userId)") { success in
            self.deleteJSON(path: "groups/\(code)/memberTasks/\(userId)") { _ in
                completion(success)
            }
        }
    }

    func deleteGroup(code: String, completion: @escaping (Bool) -> Void) {
        deleteJSON(path: "groups/\(code)", completion: completion)
    }

    func syncTasksToGroup(code: String, userId: String, profile: UserProfile, tasks: [TaskItem], completion: @escaping (Bool) -> Void) {
        // Update member info
        let memberDict: [String: Any] = ["id": profile.id, "name": profile.name, "emoji": profile.emoji]
        putJSON(path: "groups/\(code)/members/\(profile.id)", body: memberDict) { _ in }

        // Update tasks
        let taskDicts = tasks.map { $0.toDict() }
        putJSON(path: "groups/\(code)/memberTasks/\(userId)", body: taskDicts) { success in
            completion(success)
        }
    }

    func checkRaceWinner(code: String, winnerId: String, winnerName: String, completion: @escaping (Bool) -> Void) {
        let raceUpdate: [String: Any] = [
            "winnerId": winnerId,
            "winnerName": winnerName,
            "wonAt": Date().timeIntervalSince1970 * 1000
        ]
        patchJSON(path: "groups/\(code)/race", body: raceUpdate, completion: completion)
    }

    // MARK: - HTTP Helpers

    private func getJSON(path: String, completion: @escaping (Any?) -> Void) {
        guard let url = URL(string: "\(baseURL)/\(path).json") else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil,
                  let json = try? JSONSerialization.jsonObject(with: data) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            DispatchQueue.main.async { completion(json) }
        }.resume()
    }

    private func putJSON(path: String, body: Any, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/\(path).json"),
              let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { _, response, error in
            let success = error == nil && (response as? HTTPURLResponse)?.statusCode == 200
            DispatchQueue.main.async { completion(success) }
        }.resume()
    }

    private func patchJSON(path: String, body: Any, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/\(path).json"),
              let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { _, response, error in
            let success = error == nil
            DispatchQueue.main.async { completion(success) }
        }.resume()
    }

    private func deleteJSON(path: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/\(path).json") else {
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        URLSession.shared.dataTask(with: request) { _, _, error in
            DispatchQueue.main.async { completion(error == nil) }
        }.resume()
    }
}
