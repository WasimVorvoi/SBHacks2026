import UIKit

class GroupsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private let tableView = UITableView()
    private var groups: [ClutchGroup] = []
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.bg
        setupUI()
        loadGroups()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadGroups()
    }

    private func setupUI() {
        let btnStack = UIStackView()
        btnStack.axis = .horizontal
        btnStack.spacing = 10
        btnStack.distribution = .fillEqually
        btnStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(btnStack)

        let createBtn = UIButton(type: .system)
        createBtn.setTitle("Create Group", for: .normal)
        createBtn.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        createBtn.setTitleColor(.black, for: .normal)
        createBtn.backgroundColor = Theme.neon
        createBtn.layer.cornerRadius = 22
        createBtn.addTarget(self, action: #selector(createGroupTapped), for: .touchUpInside)
        Theme.addButtonEffect(to: createBtn)

        let joinBtn = UIButton(type: .system)
        joinBtn.setTitle("Join Group", for: .normal)
        joinBtn.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        joinBtn.setTitleColor(Theme.neon, for: .normal)
        joinBtn.backgroundColor = Theme.card
        joinBtn.layer.cornerRadius = 22
        joinBtn.layer.borderWidth = 1
        joinBtn.layer.borderColor = Theme.border.cgColor
        joinBtn.addTarget(self, action: #selector(joinGroupTapped), for: .touchUpInside)
        Theme.addButtonEffect(to: joinBtn)

        btnStack.addArrangedSubview(createBtn)
        btnStack.addArrangedSubview(joinBtn)

        loadingIndicator.color = Theme.neon
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingIndicator)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "GroupCell")
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 100, right: 0)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            btnStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            btnStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            btnStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            btnStack.heightAnchor.constraint(equalToConstant: 44),

            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.topAnchor.constraint(equalTo: btnStack.bottomAnchor, constant: 20),

            tableView.topAnchor.constraint(equalTo: btnStack.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func loadGroups() {
        loadingIndicator.startAnimating()
        groups.removeAll()
        let codes = TaskStore.shared.myGroupCodes
        guard !codes.isEmpty else {
            loadingIndicator.stopAnimating()
            tableView.reloadData()
            return
        }

        let group = DispatchGroup()
        for code in codes {
            group.enter()
            FirebaseService.shared.fetchGroup(code: code) { [weak self] g in
                if let g = g {
                    self?.groups.append(g)
                }
                group.leave()
            }
        }
        group.notify(queue: .main) { [weak self] in
            self?.loadingIndicator.stopAnimating()
            self?.tableView.reloadData()
        }
    }

    @objc private func createGroupTapped() {
        Theme.hapticLight()
        let alert = UIAlertController(title: "Create Group", message: nil, preferredStyle: .alert)
        alert.addTextField { tf in
            tf.placeholder = "Group name"
            tf.font = .systemFont(ofSize: 16, weight: .medium)
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Create", style: .default) { [weak self] _ in
            guard let name = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !name.isEmpty else { return }
            let me = TaskStore.shared.profile
            let newGroup = ClutchGroup(name: name, creatorId: me.id)
            var g = newGroup
            g.members[me.id] = GroupMember(id: me.id, name: me.name, emoji: me.emoji)

            FirebaseService.shared.createGroup(g) { success in
                if success {
                    TaskStore.shared.myGroupCodes.append(g.code)
                    Theme.hapticSuccess()
                    self?.loadGroups()
                }
            }
        })
        presentingViewController?.present(alert, animated: true) ?? present(alert, animated: true)
    }

    @objc private func joinGroupTapped() {
        Theme.hapticLight()
        let alert = UIAlertController(title: "Join Group", message: "Enter the 6-character group code", preferredStyle: .alert)
        alert.addTextField { tf in
            tf.placeholder = "Group code"
            tf.autocapitalizationType = .allCharacters
            tf.font = .monospacedDigitSystemFont(ofSize: 16, weight: .medium)
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Join", style: .default) { [weak self] _ in
            guard let code = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines).uppercased(),
                  code.count == 6 else { return }
            let me = TaskStore.shared.profile
            let member = GroupMember(id: me.id, name: me.name, emoji: me.emoji)
            FirebaseService.shared.joinGroup(code: code, member: member) { group in
                if group != nil {
                    if !TaskStore.shared.myGroupCodes.contains(code) {
                        TaskStore.shared.myGroupCodes.append(code)
                    }
                    Theme.hapticSuccess()
                    self?.loadGroups()
                } else {
                    Theme.hapticError()
                }
            }
        })
        presentingViewController?.present(alert, animated: true) ?? present(alert, animated: true)
    }

    // MARK: - TableView

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCell", for: indexPath)
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }

        let g = groups[indexPath.row]
        let card = UIView()
        Theme.applyCard(to: card)
        card.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(card)

        let nameLabel = UILabel()
        nameLabel.text = g.name
        nameLabel.font = .systemFont(ofSize: 16, weight: .bold)
        nameLabel.textColor = Theme.text
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(nameLabel)

        let codeLabel = UILabel()
        codeLabel.text = g.code
        codeLabel.font = .monospacedDigitSystemFont(ofSize: 12, weight: .semibold)
        codeLabel.textColor = Theme.accent
        codeLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(codeLabel)

        let membersLabel = UILabel()
        membersLabel.text = "\(g.members.count) members"
        membersLabel.font = .systemFont(ofSize: 12, weight: .medium)
        membersLabel.textColor = Theme.textDim
        membersLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(membersLabel)

        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = Theme.textMuted
        chevron.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(chevron)

        // Race badge
        if let race = g.race {
            let raceBadge = UILabel()
            if race.winnerId != nil {
                raceBadge.text = " Won "
                raceBadge.backgroundColor = Theme.gold.withAlphaComponent(0.15)
                raceBadge.textColor = Theme.gold
            } else {
                raceBadge.text = " Race: \(race.targetPoints)pts "
                raceBadge.backgroundColor = Theme.neonDim
                raceBadge.textColor = Theme.neon
            }
            raceBadge.font = .systemFont(ofSize: 10, weight: .bold)
            raceBadge.layer.cornerRadius = 6
            raceBadge.clipsToBounds = true
            raceBadge.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview(raceBadge)
            NSLayoutConstraint.activate([
                raceBadge.centerYAnchor.constraint(equalTo: codeLabel.centerYAnchor),
                raceBadge.leadingAnchor.constraint(equalTo: codeLabel.trailingAnchor, constant: 8),
                raceBadge.heightAnchor.constraint(equalToConstant: 18)
            ])
        }

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 4),
            card.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
            card.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -4),
            card.heightAnchor.constraint(greaterThanOrEqualToConstant: 68),

            nameLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),

            codeLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            codeLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),

            membersLabel.topAnchor.constraint(equalTo: codeLabel.bottomAnchor, constant: 4),
            membersLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            membersLabel.bottomAnchor.constraint(lessThanOrEqualTo: card.bottomAnchor, constant: -12),

            chevron.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            chevron.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16)
        ])

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Theme.hapticLight()
        let detailVC = GroupDetailViewController(group: groups[indexPath.row])
        if let nav = navigationController {
            nav.pushViewController(detailVC, animated: true)
        } else if let parentNav = parent?.navigationController {
            parentNav.pushViewController(detailVC, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let g = groups[indexPath.row]
        let leave = UIContextualAction(style: .destructive, title: "Leave") { [weak self] _, _, handler in
            FirebaseService.shared.leaveGroup(code: g.code, userId: TaskStore.shared.profile.id) { _ in
                TaskStore.shared.myGroupCodes.removeAll { $0 == g.code }
                self?.groups.remove(at: indexPath.row)
                self?.tableView.reloadData()
            }
            handler(true)
        }
        return UISwipeActionsConfiguration(actions: [leave])
    }
}
