import UIKit

class FriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private let tableView = UITableView(frame: .zero, style: .grouped)
    private var friends: [[String: Any]] = []
    private var incoming: [[String: Any]] = []
    private var outgoing: [[String: Any]] = []
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.bg
        setupUI()
        loadFriends()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFriends()
    }

    private func setupUI() {
        // Friend code card at top
        let codeCard = UIView()
        Theme.applyGlowCard(to: codeCard)
        codeCard.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(codeCard)

        let codeTitle = UILabel()
        codeTitle.text = "Your Friend Code"
        codeTitle.font = .systemFont(ofSize: 12, weight: .semibold)
        codeTitle.textColor = Theme.textDim
        codeTitle.textAlignment = .center
        codeTitle.translatesAutoresizingMaskIntoConstraints = false
        codeCard.addSubview(codeTitle)

        let codeLabel = UILabel()
        let friendCode = String(TaskStore.shared.profile.id.prefix(8)).uppercased()
        codeLabel.text = friendCode
        codeLabel.font = .monospacedDigitSystemFont(ofSize: 24, weight: .heavy)
        codeLabel.textColor = Theme.neon
        codeLabel.textAlignment = .center
        codeLabel.translatesAutoresizingMaskIntoConstraints = false
        codeCard.addSubview(codeLabel)

        let copyBtn = UIButton(type: .system)
        copyBtn.setTitle("Copy", for: .normal)
        copyBtn.titleLabel?.font = .systemFont(ofSize: 13, weight: .bold)
        copyBtn.setTitleColor(Theme.accent, for: .normal)
        copyBtn.addTarget(self, action: #selector(copyCode), for: .touchUpInside)
        copyBtn.translatesAutoresizingMaskIntoConstraints = false
        codeCard.addSubview(copyBtn)

        let addFriendBtn = UIButton(type: .system)
        addFriendBtn.setTitle("+ Add Friend", for: .normal)
        addFriendBtn.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        addFriendBtn.setTitleColor(.black, for: .normal)
        addFriendBtn.backgroundColor = Theme.neon
        addFriendBtn.layer.cornerRadius = 22
        addFriendBtn.translatesAutoresizingMaskIntoConstraints = false
        addFriendBtn.addTarget(self, action: #selector(addFriendTapped), for: .touchUpInside)
        Theme.addButtonEffect(to: addFriendBtn)
        view.addSubview(addFriendBtn)

        loadingIndicator.color = Theme.neon
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingIndicator)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FriendCell")
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            codeCard.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            codeCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            codeCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            codeCard.heightAnchor.constraint(equalToConstant: 70),

            codeTitle.topAnchor.constraint(equalTo: codeCard.topAnchor, constant: 10),
            codeTitle.centerXAnchor.constraint(equalTo: codeCard.centerXAnchor),

            codeLabel.topAnchor.constraint(equalTo: codeTitle.bottomAnchor, constant: 4),
            codeLabel.centerXAnchor.constraint(equalTo: codeCard.centerXAnchor),

            copyBtn.centerYAnchor.constraint(equalTo: codeLabel.centerYAnchor),
            copyBtn.trailingAnchor.constraint(equalTo: codeCard.trailingAnchor, constant: -16),

            addFriendBtn.topAnchor.constraint(equalTo: codeCard.bottomAnchor, constant: 12),
            addFriendBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            addFriendBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            addFriendBtn.heightAnchor.constraint(equalToConstant: 44),

            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.topAnchor.constraint(equalTo: addFriendBtn.bottomAnchor, constant: 20),

            tableView.topAnchor.constraint(equalTo: addFriendBtn.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func loadFriends() {
        loadingIndicator.startAnimating()
        FirebaseService.shared.fetchFriends(userId: TaskStore.shared.profile.id) { [weak self] friends, incoming, outgoing in
            self?.loadingIndicator.stopAnimating()
            self?.friends = friends
            self?.incoming = incoming
            self?.outgoing = outgoing
            self?.tableView.reloadData()
        }
    }

    @objc private func copyCode() {
        let code = String(TaskStore.shared.profile.id.prefix(8)).uppercased()
        UIPasteboard.general.string = code
        Theme.hapticSuccess()
    }

    @objc private func addFriendTapped() {
        Theme.hapticLight()
        let alert = UIAlertController(title: "Add Friend", message: "Enter their friend code", preferredStyle: .alert)
        alert.addTextField { tf in
            tf.placeholder = "Friend code"
            tf.autocapitalizationType = .allCharacters
            tf.font = .monospacedDigitSystemFont(ofSize: 16, weight: .medium)
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Send Request", style: .default) { [weak self] _ in
            guard let code = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !code.isEmpty else { return }
            let me = TaskStore.shared.profile
            FirebaseService.shared.sendFriendRequest(from: me, toId: code.lowercased(), toName: "", toEmoji: "") { success in
                if success {
                    Theme.hapticSuccess()
                    self?.loadFriends()
                } else {
                    Theme.hapticError()
                }
            }
        })
        presentingViewController?.present(alert, animated: true) ?? present(alert, animated: true)
    }

    // MARK: - TableView

    func numberOfSections(in tableView: UITableView) -> Int { 3 }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return incoming.isEmpty ? nil : "Incoming Requests"
        case 1: return outgoing.isEmpty ? nil : "Pending Requests"
        case 2: return friends.isEmpty ? nil : "Friends"
        default: return nil
        }
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = Theme.textDim
            header.textLabel?.font = .systemFont(ofSize: 13, weight: .bold)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return incoming.count
        case 1: return outgoing.count
        case 2: return friends.count
        default: return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath)
        cell.backgroundColor = .clear
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        cell.selectionStyle = .none

        let card = UIView()
        Theme.applyCard(to: card)
        card.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(card)

        let data: [String: Any]
        switch indexPath.section {
        case 0: data = incoming[indexPath.row]
        case 1: data = outgoing[indexPath.row]
        default: data = friends[indexPath.row]
        }

        let emoji = UILabel()
        emoji.text = data["emoji"] as? String ?? "⚡"
        emoji.font = .systemFont(ofSize: 24)
        emoji.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(emoji)

        let name = UILabel()
        name.text = data["name"] as? String ?? data["id"] as? String ?? "Unknown"
        name.font = .systemFont(ofSize: 15, weight: .semibold)
        name.textColor = Theme.text
        name.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(name)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 2),
            card.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
            card.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -2),
            card.heightAnchor.constraint(greaterThanOrEqualToConstant: 52),

            emoji.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            emoji.centerYAnchor.constraint(equalTo: card.centerYAnchor),

            name.leadingAnchor.constraint(equalTo: emoji.trailingAnchor, constant: 10),
            name.centerYAnchor.constraint(equalTo: card.centerYAnchor)
        ])

        if indexPath.section == 0 {
            // Accept / Decline buttons
            let acceptBtn = UIButton(type: .system)
            acceptBtn.setTitle("Accept", for: .normal)
            acceptBtn.titleLabel?.font = .systemFont(ofSize: 13, weight: .bold)
            acceptBtn.setTitleColor(.black, for: .normal)
            acceptBtn.backgroundColor = Theme.success
            acceptBtn.layer.cornerRadius = 14
            acceptBtn.tag = indexPath.row
            acceptBtn.addTarget(self, action: #selector(acceptFriend(_:)), for: .touchUpInside)
            acceptBtn.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview(acceptBtn)

            let declineBtn = UIButton(type: .system)
            declineBtn.setTitle("Decline", for: .normal)
            declineBtn.titleLabel?.font = .systemFont(ofSize: 13, weight: .bold)
            declineBtn.setTitleColor(Theme.danger, for: .normal)
            declineBtn.tag = indexPath.row
            declineBtn.addTarget(self, action: #selector(declineFriend(_:)), for: .touchUpInside)
            declineBtn.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview(declineBtn)

            NSLayoutConstraint.activate([
                acceptBtn.trailingAnchor.constraint(equalTo: declineBtn.leadingAnchor, constant: -8),
                acceptBtn.centerYAnchor.constraint(equalTo: card.centerYAnchor),
                acceptBtn.widthAnchor.constraint(equalToConstant: 64),
                acceptBtn.heightAnchor.constraint(equalToConstant: 28),

                declineBtn.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
                declineBtn.centerYAnchor.constraint(equalTo: card.centerYAnchor)
            ])
        } else if indexPath.section == 1 {
            let pending = UILabel()
            pending.text = "Sent"
            pending.font = .systemFont(ofSize: 12, weight: .semibold)
            pending.textColor = Theme.textMuted
            pending.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview(pending)
            NSLayoutConstraint.activate([
                pending.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
                pending.centerYAnchor.constraint(equalTo: card.centerYAnchor)
            ])
        } else {
            let removeBtn = UIButton(type: .system)
            removeBtn.setTitle("Remove", for: .normal)
            removeBtn.titleLabel?.font = .systemFont(ofSize: 12, weight: .semibold)
            removeBtn.setTitleColor(Theme.danger, for: .normal)
            removeBtn.tag = indexPath.row
            removeBtn.addTarget(self, action: #selector(removeFriend(_:)), for: .touchUpInside)
            removeBtn.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview(removeBtn)
            NSLayoutConstraint.activate([
                removeBtn.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
                removeBtn.centerYAnchor.constraint(equalTo: card.centerYAnchor)
            ])
        }

        return cell
    }

    @objc private func acceptFriend(_ sender: UIButton) {
        guard sender.tag < incoming.count else { return }
        let data = incoming[sender.tag]
        let friendId = data["id"] as? String ?? ""
        let friendName = data["name"] as? String ?? ""
        let friendEmoji = data["emoji"] as? String ?? "⚡"
        FirebaseService.shared.acceptFriend(myProfile: TaskStore.shared.profile, friendId: friendId, friendName: friendName, friendEmoji: friendEmoji) { [weak self] _ in
            Theme.hapticSuccess()
            self?.loadFriends()
        }
    }

    @objc private func declineFriend(_ sender: UIButton) {
        guard sender.tag < incoming.count else { return }
        let friendId = incoming[sender.tag]["id"] as? String ?? ""
        FirebaseService.shared.declineFriend(myId: TaskStore.shared.profile.id, friendId: friendId) { [weak self] _ in
            self?.loadFriends()
        }
    }

    @objc private func removeFriend(_ sender: UIButton) {
        guard sender.tag < friends.count else { return }
        let friendId = friends[sender.tag]["id"] as? String ?? ""
        FirebaseService.shared.removeFriend(myId: TaskStore.shared.profile.id, friendId: friendId) { [weak self] _ in
            self?.loadFriends()
        }
    }
}
