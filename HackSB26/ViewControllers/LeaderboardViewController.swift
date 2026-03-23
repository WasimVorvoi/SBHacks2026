import UIKit

class LeaderboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private let timeSegment = UISegmentedControl(items: ["All Time", "This Week"])
    private let tableView = UITableView()
    private let podiumView = UIView()
    private var entries: [LeaderboardEntry] = []
    private var animatedRows: Set<IndexPath> = []
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.bg
        setupUI()
        loadEntries()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animatedRows.removeAll()
        loadEntries()
    }

    private func setupUI() {
        timeSegment.selectedSegmentIndex = 0
        timeSegment.selectedSegmentTintColor = Theme.accent
        timeSegment.setTitleTextAttributes([.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 12, weight: .semibold)], for: .selected)
        timeSegment.setTitleTextAttributes([.foregroundColor: Theme.textDim, .font: UIFont.systemFont(ofSize: 12, weight: .medium)], for: .normal)
        timeSegment.backgroundColor = Theme.card
        timeSegment.addTarget(self, action: #selector(timeChanged), for: .valueChanged)
        timeSegment.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(timeSegment)

        podiumView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(podiumView)

        loadingIndicator.color = Theme.neon
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingIndicator)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(LeaderboardCell.self, forCellReuseIdentifier: "LeaderboardCell")
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 100, right: 0)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            timeSegment.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            timeSegment.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            timeSegment.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            podiumView.topAnchor.constraint(equalTo: timeSegment.bottomAnchor, constant: 8),
            podiumView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            podiumView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            podiumView.heightAnchor.constraint(equalToConstant: 180),

            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.topAnchor.constraint(equalTo: podiumView.bottomAnchor, constant: 20),

            tableView.topAnchor.constraint(equalTo: podiumView.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func loadEntries() {
        loadingIndicator.startAnimating()
        animatedRows.removeAll()

        let timeFrame = timeSegment.selectedSegmentIndex == 0 ? "allTime" : "weekly"

        TaskStore.shared.fetchGlobalLeaderboard(timeFrame: timeFrame) { [weak self] entries in
            self?.loadingIndicator.stopAnimating()
            if entries.isEmpty {
                self?.entries = TaskStore.shared.globalLeaderboard()
            } else {
                self?.entries = entries
            }
            self?.buildPodium()
            self?.tableView.reloadData()
        }
    }

    @objc private func timeChanged() {
        Theme.hapticLight()
        animatedRows.removeAll()
        UIView.transition(with: view, duration: 0.3, options: .transitionCrossDissolve) {
            self.loadEntries()
        }
    }

    private func buildPodium() {
        podiumView.subviews.forEach { $0.removeFromSuperview() }
        guard entries.count >= 3 else {
            // Show minimal podium for less than 3
            if entries.isEmpty { return }
            return
        }

        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .bottom
        stack.distribution = .fillEqually
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        podiumView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: podiumView.topAnchor),
            stack.leadingAnchor.constraint(equalTo: podiumView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: podiumView.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: podiumView.bottomAnchor)
        ])

        // 2nd, 1st, 3rd
        let order = [1, 0, 2]
        let heights: [CGFloat] = [140, 170, 120]
        let isMe = entries.map { $0.name == TaskStore.shared.profile.name }

        for i in 0..<3 {
            let idx = order[i]
            let entry = entries[idx]
            let card = makePodiumCard(entry: entry, rank: idx + 1, height: heights[i], isCurrentUser: isMe[idx])
            stack.addArrangedSubview(card)
        }
    }

    private func makePodiumCard(entry: LeaderboardEntry, rank: Int, height: CGFloat, isCurrentUser: Bool) -> UIView {
        let wrapper = UIView()

        let card = UIView()
        if isCurrentUser {
            Theme.applyGlowCard(to: card)
        } else {
            Theme.applyCard(to: card)
        }
        card.translatesAutoresizingMaskIntoConstraints = false
        wrapper.addSubview(card)

        let emoji = UILabel()
        emoji.text = entry.emoji
        emoji.font = .systemFont(ofSize: 28)
        emoji.textAlignment = .center
        emoji.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(emoji)

        let name = UILabel()
        name.text = entry.name
        name.font = .systemFont(ofSize: 13, weight: .bold)
        name.textColor = isCurrentUser ? Theme.neon : Theme.text
        name.textAlignment = .center
        name.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(name)

        let pts = UILabel()
        pts.text = "\(Int(entry.points))"
        pts.font = .monospacedDigitSystemFont(ofSize: 16, weight: .bold)
        pts.textColor = Theme.neon
        pts.textAlignment = .center
        pts.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(pts)

        let rankLabel = UILabel()
        rankLabel.text = rank == 1 ? "👑" : "\(rank)"
        rankLabel.font = rank == 1 ? .systemFont(ofSize: 20) : .rounded(ofSize: 14, weight: .heavy)
        rankLabel.textColor = rank == 1 ? Theme.gold : (rank == 2 ? .systemGray : UIColor(red: 0.8, green: 0.5, blue: 0.2, alpha: 1.0))
        rankLabel.textAlignment = .center
        rankLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(rankLabel)

        let level = UILabel()
        level.text = "Lv.\(entry.level)"
        level.font = .systemFont(ofSize: 11, weight: .semibold)
        level.textColor = Theme.textDim
        level.textAlignment = .center
        level.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(level)

        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor),
            card.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor),
            card.heightAnchor.constraint(equalToConstant: height),

            rankLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 10),
            rankLabel.centerXAnchor.constraint(equalTo: card.centerXAnchor),

            emoji.topAnchor.constraint(equalTo: rankLabel.bottomAnchor, constant: 6),
            emoji.centerXAnchor.constraint(equalTo: card.centerXAnchor),

            name.topAnchor.constraint(equalTo: emoji.bottomAnchor, constant: 6),
            name.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            name.leadingAnchor.constraint(greaterThanOrEqualTo: card.leadingAnchor, constant: 4),
            name.trailingAnchor.constraint(lessThanOrEqualTo: card.trailingAnchor, constant: -4),

            pts.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 4),
            pts.centerXAnchor.constraint(equalTo: card.centerXAnchor),

            level.topAnchor.constraint(equalTo: pts.bottomAnchor, constant: 2),
            level.centerXAnchor.constraint(equalTo: card.centerXAnchor)
        ])

        return wrapper
    }

    // MARK: - TableView (rank 4+)

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(0, entries.count - 3)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LeaderboardCell", for: indexPath) as! LeaderboardCell
        let entryIndex = indexPath.row + 3
        let isCurrentUser = entries[entryIndex].name == TaskStore.shared.profile.name
        cell.configure(rank: entryIndex + 1, entry: entries[entryIndex], isCurrentUser: isCurrentUser)
        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard !animatedRows.contains(indexPath) else { return }
        animatedRows.insert(indexPath)
        cell.alpha = 0
        cell.transform = CGAffineTransform(translationX: -40, y: 0)
        UIView.animate(withDuration: 0.45, delay: Double(indexPath.row) * 0.08, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: []) {
            cell.alpha = 1
            cell.transform = .identity
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Theme.hapticLight()
        let entryIndex = indexPath.row + 3
        let entry = entries[entryIndex]
        let detailVC = UserProfileDetailViewController(entry: entry, rank: entryIndex + 1)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - LeaderboardCell

class LeaderboardCell: UITableViewCell {
    private let cardView = UIView()
    private let rankLabel = UILabel()
    private let emojiLabel = UILabel()
    private let nameLabel = UILabel()
    private let pointsLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        cardView.backgroundColor = Theme.card
        cardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cardView)

        rankLabel.font = .monospacedDigitSystemFont(ofSize: 13, weight: .bold)
        rankLabel.textColor = Theme.textMuted
        rankLabel.textAlignment = .center
        rankLabel.translatesAutoresizingMaskIntoConstraints = false

        emojiLabel.font = .systemFont(ofSize: 20)
        emojiLabel.textAlignment = .center
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false

        nameLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        nameLabel.textColor = Theme.text
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        pointsLabel.font = .monospacedDigitSystemFont(ofSize: 13, weight: .bold)
        pointsLabel.textColor = Theme.neon
        pointsLabel.textAlignment = .right
        pointsLabel.translatesAutoresizingMaskIntoConstraints = false

        cardView.addSubview(rankLabel)
        cardView.addSubview(emojiLabel)
        cardView.addSubview(nameLabel)
        cardView.addSubview(pointsLabel)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 1),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -1),

            rankLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            rankLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            rankLabel.widthAnchor.constraint(equalToConstant: 24),

            emojiLabel.leadingAnchor.constraint(equalTo: rankLabel.trailingAnchor, constant: 10),
            emojiLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),

            nameLabel.leadingAnchor.constraint(equalTo: emojiLabel.trailingAnchor, constant: 10),
            nameLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),

            pointsLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            pointsLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(rank: Int, entry: LeaderboardEntry, isCurrentUser: Bool) {
        rankLabel.text = "\(rank)"
        emojiLabel.text = entry.emoji
        nameLabel.text = isCurrentUser ? "\(entry.name) (You)" : entry.name
        pointsLabel.text = "\(Int(entry.points))"

        if isCurrentUser {
            cardView.backgroundColor = Theme.accentDim
            cardView.layer.borderWidth = 1
            cardView.layer.borderColor = Theme.accentGlow.cgColor
            cardView.layer.cornerRadius = 10
            nameLabel.textColor = Theme.neon
        } else {
            cardView.backgroundColor = Theme.card
            cardView.layer.borderWidth = 0
            cardView.layer.cornerRadius = 0
            nameLabel.textColor = Theme.text
        }
    }
}
