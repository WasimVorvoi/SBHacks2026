import UIKit

class ChallengesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private let tableView = UITableView(frame: .zero, style: .grouped)
    private var sections: [(String, [Challenge])] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.bg
        sections = ChallengesManager.shared.challengesByCategory()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ChallengeCell")
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    // MARK: - TableView

    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].0
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = Theme.text
            header.textLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].1.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChallengeCell", for: indexPath)
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }

        let challenge = sections[indexPath.section].1[indexPath.row]
        let tasks = TaskStore.shared.tasks
        let profile = TaskStore.shared.profile
        let progress = challenge.check(tasks, profile)
        let isCompleted = ChallengesManager.shared.completedChallengeIds.contains(challenge.id)

        let card = UIView()
        if isCompleted {
            Theme.applyGlowCard(to: card)
        } else {
            Theme.applyCard(to: card)
        }
        card.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(card)

        // Icon
        let iconCircle = UIView()
        iconCircle.backgroundColor = isCompleted ? Theme.neonDim : Theme.accentDim
        iconCircle.layer.cornerRadius = 20
        iconCircle.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(iconCircle)

        let iconView = UIImageView(image: UIImage(systemName: challenge.icon))
        iconView.tintColor = isCompleted ? Theme.neon : Theme.accent
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconCircle.addSubview(iconView)

        // Title + desc
        let titleLabel = UILabel()
        titleLabel.text = challenge.title
        titleLabel.font = .systemFont(ofSize: 15, weight: .bold)
        titleLabel.textColor = isCompleted ? Theme.neon : Theme.text
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(titleLabel)

        let descLabel = UILabel()
        descLabel.text = challenge.desc
        descLabel.font = .systemFont(ofSize: 12, weight: .medium)
        descLabel.textColor = Theme.textDim
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(descLabel)

        // Bonus pts
        let bonusLabel = UILabel()
        bonusLabel.text = isCompleted ? "Earned!" : "+\(challenge.bonusPts)"
        bonusLabel.font = .monospacedDigitSystemFont(ofSize: 13, weight: .bold)
        bonusLabel.textColor = isCompleted ? Theme.success : Theme.neon
        bonusLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(bonusLabel)

        // Progress bar
        let progressBg = UIView()
        progressBg.backgroundColor = Theme.bgSubtle
        progressBg.layer.cornerRadius = 3
        progressBg.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(progressBg)

        let progressFill = UIView()
        progressFill.backgroundColor = isCompleted ? Theme.neon : Theme.accent
        progressFill.layer.cornerRadius = 3
        progressFill.translatesAutoresizingMaskIntoConstraints = false
        progressBg.addSubview(progressFill)

        let progressLabel = UILabel()
        progressLabel.text = "\(Int(min(progress, 1.0) * 100))%"
        progressLabel.font = .monospacedDigitSystemFont(ofSize: 10, weight: .bold)
        progressLabel.textColor = Theme.textMuted
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(progressLabel)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 3),
            card.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
            card.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -3),

            iconCircle.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            iconCircle.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            iconCircle.widthAnchor.constraint(equalToConstant: 40),
            iconCircle.heightAnchor.constraint(equalToConstant: 40),

            iconView.centerXAnchor.constraint(equalTo: iconCircle.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconCircle.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20),

            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: iconCircle.trailingAnchor, constant: 12),

            descLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            descLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descLabel.trailingAnchor.constraint(equalTo: bonusLabel.leadingAnchor, constant: -8),

            bonusLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            bonusLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),

            progressBg.topAnchor.constraint(equalTo: descLabel.bottomAnchor, constant: 8),
            progressBg.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            progressBg.trailingAnchor.constraint(equalTo: progressLabel.leadingAnchor, constant: -8),
            progressBg.heightAnchor.constraint(equalToConstant: 6),
            progressBg.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12),

            progressFill.leadingAnchor.constraint(equalTo: progressBg.leadingAnchor),
            progressFill.topAnchor.constraint(equalTo: progressBg.topAnchor),
            progressFill.bottomAnchor.constraint(equalTo: progressBg.bottomAnchor),
            progressFill.widthAnchor.constraint(equalTo: progressBg.widthAnchor, multiplier: max(0.01, min(1.0, progress))),

            progressLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            progressLabel.centerYAnchor.constraint(equalTo: progressBg.centerYAnchor)
        ])

        return cell
    }
}
