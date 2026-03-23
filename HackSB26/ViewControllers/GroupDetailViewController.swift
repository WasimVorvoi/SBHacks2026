import UIKit

class GroupDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private var group: ClutchGroup
    private let tableView = UITableView()
    private let podiumView = UIView()
    private var leaderboard: [(member: GroupMember, points: Int, tasksDone: Int)] = []

    init(group: ClutchGroup) {
        self.group = group
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = group.name
        view.backgroundColor = Theme.bg
        setupUI()
        refreshData()
    }

    private func setupUI() {
        // Code + Race header
        let headerCard = UIView()
        Theme.applyGlowCard(to: headerCard)
        headerCard.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerCard)

        let codeTitle = UILabel()
        codeTitle.text = "Group Code"
        codeTitle.font = .systemFont(ofSize: 11, weight: .semibold)
        codeTitle.textColor = Theme.textDim
        codeTitle.translatesAutoresizingMaskIntoConstraints = false
        headerCard.addSubview(codeTitle)

        let codeLabel = UILabel()
        codeLabel.text = group.code
        codeLabel.font = .monospacedDigitSystemFont(ofSize: 22, weight: .heavy)
        codeLabel.textColor = Theme.neon
        codeLabel.translatesAutoresizingMaskIntoConstraints = false
        headerCard.addSubview(codeLabel)

        let membersCount = UILabel()
        membersCount.text = "\(group.members.count) members"
        membersCount.font = .systemFont(ofSize: 13, weight: .medium)
        membersCount.textColor = Theme.textDim
        membersCount.translatesAutoresizingMaskIntoConstraints = false
        headerCard.addSubview(membersCount)

        NSLayoutConstraint.activate([
            headerCard.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            headerCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            headerCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            headerCard.heightAnchor.constraint(equalToConstant: 70),

            codeTitle.topAnchor.constraint(equalTo: headerCard.topAnchor, constant: 12),
            codeTitle.leadingAnchor.constraint(equalTo: headerCard.leadingAnchor, constant: 16),

            codeLabel.topAnchor.constraint(equalTo: codeTitle.bottomAnchor, constant: 2),
            codeLabel.leadingAnchor.constraint(equalTo: headerCard.leadingAnchor, constant: 16),

            membersCount.centerYAnchor.constraint(equalTo: headerCard.centerYAnchor),
            membersCount.trailingAnchor.constraint(equalTo: headerCard.trailingAnchor, constant: -16)
        ])

        // Race progress (if race active)
        var topAnchor = headerCard.bottomAnchor

        if let race = group.race {
            let raceCard = UIView()
            Theme.applyCard(to: raceCard)
            raceCard.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(raceCard)

            let raceTitle = UILabel()
            if let winner = race.winnerName {
                raceTitle.text = "\(winner) won the race!"
                raceTitle.textColor = Theme.gold
            } else {
                raceTitle.text = "Race to \(race.targetPoints) pts"
                raceTitle.textColor = Theme.neon
            }
            raceTitle.font = .systemFont(ofSize: 15, weight: .bold)
            raceTitle.translatesAutoresizingMaskIntoConstraints = false
            raceCard.addSubview(raceTitle)

            let liveBadge = UILabel()
            liveBadge.text = race.winnerId != nil ? " Won " : " Live "
            liveBadge.font = .systemFont(ofSize: 10, weight: .bold)
            liveBadge.textColor = race.winnerId != nil ? Theme.gold : Theme.neon
            liveBadge.backgroundColor = race.winnerId != nil ? Theme.gold.withAlphaComponent(0.15) : Theme.neonDim
            liveBadge.layer.cornerRadius = 6
            liveBadge.clipsToBounds = true
            liveBadge.translatesAutoresizingMaskIntoConstraints = false
            raceCard.addSubview(liveBadge)

            NSLayoutConstraint.activate([
                raceCard.topAnchor.constraint(equalTo: headerCard.bottomAnchor, constant: 8),
                raceCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                raceCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                raceCard.heightAnchor.constraint(equalToConstant: 44),

                raceTitle.centerYAnchor.constraint(equalTo: raceCard.centerYAnchor),
                raceTitle.leadingAnchor.constraint(equalTo: raceCard.leadingAnchor, constant: 16),

                liveBadge.centerYAnchor.constraint(equalTo: raceCard.centerYAnchor),
                liveBadge.trailingAnchor.constraint(equalTo: raceCard.trailingAnchor, constant: -16)
            ])
            topAnchor = raceCard.bottomAnchor
        }

        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MemberCell")
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 100, right: 0)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func refreshData() {
        FirebaseService.shared.fetchGroup(code: group.code) { [weak self] g in
            guard let g = g else { return }
            self?.group = g
            self?.leaderboard = g.leaderboard()
            self?.tableView.reloadData()
        }
    }

    // MARK: - TableView

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        leaderboard.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemberCell", for: indexPath)
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }

        let entry = leaderboard[indexPath.row]
        let rank = indexPath.row + 1
        let isMe = entry.member.id == TaskStore.shared.profile.id

        let card = UIView()
        if isMe {
            Theme.applyGlowCard(to: card)
        } else {
            Theme.applyCard(to: card)
        }
        card.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(card)

        let rankLabel = UILabel()
        if rank == 1 { rankLabel.text = "🥇" }
        else if rank == 2 { rankLabel.text = "🥈" }
        else if rank == 3 { rankLabel.text = "🥉" }
        else { rankLabel.text = "#\(rank)" }
        rankLabel.font = rank <= 3 ? .systemFont(ofSize: 20) : .monospacedDigitSystemFont(ofSize: 14, weight: .bold)
        rankLabel.textColor = Theme.textDim
        rankLabel.textAlignment = .center
        rankLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(rankLabel)

        let emoji = UILabel()
        emoji.text = entry.member.emoji
        emoji.font = .systemFont(ofSize: 22)
        emoji.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(emoji)

        let name = UILabel()
        name.text = isMe ? "\(entry.member.name) (You)" : entry.member.name
        name.font = .systemFont(ofSize: 15, weight: .semibold)
        name.textColor = isMe ? Theme.neon : Theme.text
        name.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(name)

        let pts = UILabel()
        pts.text = "\(entry.points) pts"
        pts.font = .monospacedDigitSystemFont(ofSize: 14, weight: .bold)
        pts.textColor = Theme.neon
        pts.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(pts)

        let tasks = UILabel()
        tasks.text = "\(entry.tasksDone) done"
        tasks.font = .systemFont(ofSize: 11, weight: .medium)
        tasks.textColor = Theme.textDim
        tasks.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(tasks)

        // Race progress bar
        if let race = group.race, race.winnerId == nil {
            let progressBg = UIView()
            progressBg.backgroundColor = Theme.bgSubtle
            progressBg.layer.cornerRadius = 3
            progressBg.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview(progressBg)

            let progressFill = UIView()
            let progress = min(1.0, Double(entry.points) / Double(race.targetPoints))
            progressFill.backgroundColor = isMe ? Theme.neon : Theme.accent
            progressFill.layer.cornerRadius = 3
            progressFill.translatesAutoresizingMaskIntoConstraints = false
            progressBg.addSubview(progressFill)

            NSLayoutConstraint.activate([
                progressBg.leadingAnchor.constraint(equalTo: emoji.trailingAnchor, constant: 10),
                progressBg.trailingAnchor.constraint(equalTo: pts.leadingAnchor, constant: -10),
                progressBg.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -10),
                progressBg.heightAnchor.constraint(equalToConstant: 6),

                progressFill.leadingAnchor.constraint(equalTo: progressBg.leadingAnchor),
                progressFill.topAnchor.constraint(equalTo: progressBg.topAnchor),
                progressFill.bottomAnchor.constraint(equalTo: progressBg.bottomAnchor),
                progressFill.widthAnchor.constraint(equalTo: progressBg.widthAnchor, multiplier: max(0.01, progress))
            ])
        }

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 3),
            card.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
            card.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -3),
            card.heightAnchor.constraint(greaterThanOrEqualToConstant: 60),

            rankLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            rankLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            rankLabel.widthAnchor.constraint(equalToConstant: 30),

            emoji.leadingAnchor.constraint(equalTo: rankLabel.trailingAnchor, constant: 8),
            emoji.centerYAnchor.constraint(equalTo: card.centerYAnchor),

            name.leadingAnchor.constraint(equalTo: emoji.trailingAnchor, constant: 10),
            name.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),

            tasks.leadingAnchor.constraint(equalTo: name.leadingAnchor),
            tasks.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 2),

            pts.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            pts.centerYAnchor.constraint(equalTo: card.centerYAnchor)
        ])

        return cell
    }
}
