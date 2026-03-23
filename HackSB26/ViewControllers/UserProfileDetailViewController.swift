import UIKit

class UserProfileDetailViewController: UIViewController {

    private let entry: LeaderboardEntry
    private let rank: Int
    private let scrollView = UIScrollView()

    init(entry: LeaderboardEntry, rank: Int) {
        self.entry = entry
        self.rank = rank
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = entry.name
        view.backgroundColor = Theme.bg
        navigationItem.largeTitleDisplayMode = .never
        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateIn()
    }

    private func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -100),
            stack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32)
        ])

        // Header card
        let headerCard = UIView()
        Theme.applyGlowCard(to: headerCard)
        headerCard.translatesAutoresizingMaskIntoConstraints = false

        let emojiCircle = UIView()
        emojiCircle.backgroundColor = Theme.accentDim
        emojiCircle.layer.cornerRadius = 30
        emojiCircle.layer.borderWidth = 2
        emojiCircle.layer.borderColor = Theme.accentGlow.cgColor
        emojiCircle.translatesAutoresizingMaskIntoConstraints = false
        headerCard.addSubview(emojiCircle)

        let avatarLabel = UILabel()
        avatarLabel.text = entry.emoji
        avatarLabel.font = .systemFont(ofSize: 32)
        avatarLabel.textAlignment = .center
        avatarLabel.translatesAutoresizingMaskIntoConstraints = false
        emojiCircle.addSubview(avatarLabel)

        let nameLabel = UILabel()
        nameLabel.text = entry.name
        nameLabel.font = .systemFont(ofSize: 24, weight: .bold)
        nameLabel.textColor = Theme.text
        nameLabel.textAlignment = .center
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        headerCard.addSubview(nameLabel)

        let rankBadge = UILabel()
        rankBadge.text = rankText(rank)
        rankBadge.font = .systemFont(ofSize: 13, weight: .bold)
        rankBadge.textColor = .black
        rankBadge.textAlignment = .center
        rankBadge.backgroundColor = rankColor(rank)
        rankBadge.layer.cornerRadius = 12
        rankBadge.clipsToBounds = true
        rankBadge.translatesAutoresizingMaskIntoConstraints = false
        headerCard.addSubview(rankBadge)

        let levelLabel = UILabel()
        levelLabel.text = "Lv.\(entry.level) \(PointsCalculator.levelTitle(level: entry.level))"
        levelLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        levelLabel.textColor = Theme.accentLight
        levelLabel.textAlignment = .center
        levelLabel.translatesAutoresizingMaskIntoConstraints = false
        headerCard.addSubview(levelLabel)

        NSLayoutConstraint.activate([
            emojiCircle.topAnchor.constraint(equalTo: headerCard.topAnchor, constant: 20),
            emojiCircle.centerXAnchor.constraint(equalTo: headerCard.centerXAnchor),
            emojiCircle.widthAnchor.constraint(equalToConstant: 60),
            emojiCircle.heightAnchor.constraint(equalToConstant: 60),

            avatarLabel.centerXAnchor.constraint(equalTo: emojiCircle.centerXAnchor),
            avatarLabel.centerYAnchor.constraint(equalTo: emojiCircle.centerYAnchor),

            nameLabel.topAnchor.constraint(equalTo: emojiCircle.bottomAnchor, constant: 10),
            nameLabel.centerXAnchor.constraint(equalTo: headerCard.centerXAnchor),

            rankBadge.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 6),
            rankBadge.centerXAnchor.constraint(equalTo: headerCard.centerXAnchor),
            rankBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
            rankBadge.heightAnchor.constraint(equalToConstant: 24),

            levelLabel.topAnchor.constraint(equalTo: rankBadge.bottomAnchor, constant: 6),
            levelLabel.centerXAnchor.constraint(equalTo: headerCard.centerXAnchor),
            levelLabel.bottomAnchor.constraint(equalTo: headerCard.bottomAnchor, constant: -20)
        ])
        stack.addArrangedSubview(headerCard)

        // Points card
        let pointsCard = UIView()
        Theme.applyCard(to: pointsCard)
        pointsCard.translatesAutoresizingMaskIntoConstraints = false

        let pointsValue = UILabel()
        pointsValue.text = "\(Int(entry.points))"
        pointsValue.font = .monospacedDigitSystemFont(ofSize: 40, weight: .heavy)
        pointsValue.textColor = Theme.neon
        pointsValue.textAlignment = .center
        pointsValue.translatesAutoresizingMaskIntoConstraints = false
        pointsCard.addSubview(pointsValue)

        let pointsSub = UILabel()
        pointsSub.text = "TOTAL POINTS"
        pointsSub.font = .systemFont(ofSize: 11, weight: .bold)
        pointsSub.textColor = Theme.textMuted
        pointsSub.textAlignment = .center
        pointsSub.translatesAutoresizingMaskIntoConstraints = false
        pointsCard.addSubview(pointsSub)

        NSLayoutConstraint.activate([
            pointsValue.topAnchor.constraint(equalTo: pointsCard.topAnchor, constant: 16),
            pointsValue.centerXAnchor.constraint(equalTo: pointsCard.centerXAnchor),
            pointsSub.topAnchor.constraint(equalTo: pointsValue.bottomAnchor, constant: 2),
            pointsSub.centerXAnchor.constraint(equalTo: pointsCard.centerXAnchor),
            pointsSub.bottomAnchor.constraint(equalTo: pointsCard.bottomAnchor, constant: -16)
        ])
        stack.addArrangedSubview(pointsCard)

        // Stats row
        let statsRow = UIStackView()
        statsRow.axis = .horizontal
        statsRow.distribution = .fillEqually
        statsRow.spacing = 10

        statsRow.addArrangedSubview(makeStatCard(value: "\(entry.tasksCompleted)", label: "TASKS", icon: "checkmark.circle.fill", color: Theme.success))
        statsRow.addArrangedSubview(makeStatCard(value: "\(entry.currentStreak)", label: "STREAK", icon: "flame.fill", color: .systemOrange))
        statsRow.addArrangedSubview(makeStatCard(value: avgPointsPerTask(), label: "AVG/TASK", icon: "chart.bar.fill", color: Theme.accent))
        stack.addArrangedSubview(statsRow)

        // Activity card
        let activityCard = UIView()
        Theme.applyCard(to: activityCard)
        activityCard.translatesAutoresizingMaskIntoConstraints = false

        let activityHeader = UILabel()
        activityHeader.text = "Activity"
        activityHeader.font = .systemFont(ofSize: 16, weight: .bold)
        activityHeader.textColor = Theme.text
        activityHeader.translatesAutoresizingMaskIntoConstraints = false
        activityCard.addSubview(activityHeader)

        let activityStack = UIStackView()
        activityStack.axis = .vertical
        activityStack.spacing = 12
        activityStack.translatesAutoresizingMaskIntoConstraints = false
        activityCard.addSubview(activityStack)

        for activity in generateActivities() {
            let row = makeActivityRow(icon: activity.icon, text: activity.text, time: activity.time, color: activity.color)
            activityStack.addArrangedSubview(row)
        }

        NSLayoutConstraint.activate([
            activityHeader.topAnchor.constraint(equalTo: activityCard.topAnchor, constant: 16),
            activityHeader.leadingAnchor.constraint(equalTo: activityCard.leadingAnchor, constant: 16),
            activityStack.topAnchor.constraint(equalTo: activityHeader.bottomAnchor, constant: 12),
            activityStack.leadingAnchor.constraint(equalTo: activityCard.leadingAnchor, constant: 16),
            activityStack.trailingAnchor.constraint(equalTo: activityCard.trailingAnchor, constant: -16),
            activityStack.bottomAnchor.constraint(equalTo: activityCard.bottomAnchor, constant: -16)
        ])
        stack.addArrangedSubview(activityCard)

        // Completed Goals
        if !entry.completedGoals.isEmpty {
            let goalsCard = UIView()
            Theme.applyCard(to: goalsCard)
            goalsCard.translatesAutoresizingMaskIntoConstraints = false

            let goalsHeader = UILabel()
            goalsHeader.text = "Completed Goals"
            goalsHeader.font = .systemFont(ofSize: 16, weight: .bold)
            goalsHeader.textColor = Theme.text
            goalsHeader.translatesAutoresizingMaskIntoConstraints = false
            goalsCard.addSubview(goalsHeader)

            let countBadge = UILabel()
            countBadge.text = "  \(entry.completedGoals.count)  "
            countBadge.font = .systemFont(ofSize: 12, weight: .bold)
            countBadge.textColor = .black
            countBadge.backgroundColor = Theme.neon
            countBadge.layer.cornerRadius = 10
            countBadge.clipsToBounds = true
            countBadge.translatesAutoresizingMaskIntoConstraints = false
            goalsCard.addSubview(countBadge)

            let goalsStack = UIStackView()
            goalsStack.axis = .vertical
            goalsStack.spacing = 8
            goalsStack.translatesAutoresizingMaskIntoConstraints = false
            goalsCard.addSubview(goalsStack)

            for goal in entry.completedGoals {
                goalsStack.addArrangedSubview(makeGoalRow(goal: goal))
            }

            NSLayoutConstraint.activate([
                goalsHeader.topAnchor.constraint(equalTo: goalsCard.topAnchor, constant: 16),
                goalsHeader.leadingAnchor.constraint(equalTo: goalsCard.leadingAnchor, constant: 16),
                countBadge.centerYAnchor.constraint(equalTo: goalsHeader.centerYAnchor),
                countBadge.leadingAnchor.constraint(equalTo: goalsHeader.trailingAnchor, constant: 8),
                countBadge.heightAnchor.constraint(equalToConstant: 20),
                goalsStack.topAnchor.constraint(equalTo: goalsHeader.bottomAnchor, constant: 14),
                goalsStack.leadingAnchor.constraint(equalTo: goalsCard.leadingAnchor, constant: 12),
                goalsStack.trailingAnchor.constraint(equalTo: goalsCard.trailingAnchor, constant: -12),
                goalsStack.bottomAnchor.constraint(equalTo: goalsCard.bottomAnchor, constant: -14)
            ])
            stack.addArrangedSubview(goalsCard)
        }
    }

    // MARK: - Goal Row

    private func makeGoalRow(goal: CompletedGoal) -> UIView {
        let card = UIView()
        card.backgroundColor = Theme.bgSubtle
        card.layer.cornerRadius = 12
        card.layer.borderWidth = 1
        card.layer.borderColor = Theme.border.cgColor
        card.translatesAutoresizingMaskIntoConstraints = false

        let statusIcon = UIImageView()
        statusIcon.contentMode = .scaleAspectFit
        statusIcon.translatesAutoresizingMaskIntoConstraints = false
        switch goal.status {
        case .completedEarly:
            statusIcon.image = UIImage(systemName: "bolt.circle.fill")
            statusIcon.tintColor = Theme.success
        case .completedOnTime:
            statusIcon.image = UIImage(systemName: "checkmark.circle.fill")
            statusIcon.tintColor = Theme.neon
        case .completedLate:
            statusIcon.image = UIImage(systemName: "clock.circle.fill")
            statusIcon.tintColor = Theme.warning
        default:
            statusIcon.image = UIImage(systemName: "circle.fill")
            statusIcon.tintColor = Theme.textMuted
        }
        card.addSubview(statusIcon)

        let titleLabel = UILabel()
        titleLabel.text = goal.title
        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textColor = Theme.text
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(titleLabel)

        let dotsStack = UIStackView()
        dotsStack.axis = .horizontal
        dotsStack.spacing = 2
        dotsStack.translatesAutoresizingMaskIntoConstraints = false
        let diffColor = Theme.difficultyColor(for: goal.difficulty)
        for i in 0..<10 {
            let dot = UIView()
            dot.layer.cornerRadius = 2.5
            dot.backgroundColor = i < goal.difficulty ? diffColor : Theme.border
            dot.translatesAutoresizingMaskIntoConstraints = false
            dot.widthAnchor.constraint(equalToConstant: 5).isActive = true
            dot.heightAnchor.constraint(equalToConstant: 5).isActive = true
            dotsStack.addArrangedSubview(dot)
        }
        card.addSubview(dotsStack)

        let timeLabel = UILabel()
        timeLabel.text = goal.completedAgo
        timeLabel.font = .systemFont(ofSize: 11)
        timeLabel.textColor = Theme.textMuted
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(timeLabel)

        let pointsBadge = UILabel()
        pointsBadge.text = "+\(goal.pointsEarned)"
        pointsBadge.font = .monospacedDigitSystemFont(ofSize: 13, weight: .bold)
        pointsBadge.textAlignment = .center
        pointsBadge.layer.cornerRadius = 10
        pointsBadge.clipsToBounds = true
        pointsBadge.translatesAutoresizingMaskIntoConstraints = false
        switch goal.status {
        case .completedEarly:
            pointsBadge.textColor = Theme.success
            pointsBadge.backgroundColor = Theme.success.withAlphaComponent(0.12)
        case .completedOnTime:
            pointsBadge.textColor = Theme.neon
            pointsBadge.backgroundColor = Theme.neonDim
        case .completedLate:
            pointsBadge.textColor = Theme.warning
            pointsBadge.backgroundColor = Theme.warning.withAlphaComponent(0.12)
        default:
            pointsBadge.textColor = Theme.textMuted
            pointsBadge.backgroundColor = Theme.border
        }
        card.addSubview(pointsBadge)

        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(equalToConstant: 58),
            statusIcon.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 10),
            statusIcon.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            statusIcon.widthAnchor.constraint(equalToConstant: 24),
            statusIcon.heightAnchor.constraint(equalToConstant: 24),

            titleLabel.leadingAnchor.constraint(equalTo: statusIcon.trailingAnchor, constant: 10),
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: pointsBadge.leadingAnchor, constant: -8),

            dotsStack.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dotsStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),

            timeLabel.leadingAnchor.constraint(equalTo: dotsStack.trailingAnchor, constant: 8),
            timeLabel.centerYAnchor.constraint(equalTo: dotsStack.centerYAnchor),

            pointsBadge.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -10),
            pointsBadge.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            pointsBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 44),
            pointsBadge.heightAnchor.constraint(equalToConstant: 20)
        ])

        return card
    }

    // MARK: - Helpers

    private func makeStatCard(value: String, label: String, icon: String, color: UIColor) -> UIView {
        let card = UIView()
        Theme.applyCard(to: card)

        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = color
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false

        let valLabel = UILabel()
        valLabel.text = value
        valLabel.font = .monospacedDigitSystemFont(ofSize: 22, weight: .bold)
        valLabel.textColor = Theme.text
        valLabel.textAlignment = .center
        valLabel.translatesAutoresizingMaskIntoConstraints = false

        let descLabel = UILabel()
        descLabel.text = label
        descLabel.font = .systemFont(ofSize: 10, weight: .bold)
        descLabel.textColor = Theme.textMuted
        descLabel.textAlignment = .center
        descLabel.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(iconView)
        card.addSubview(valLabel)
        card.addSubview(descLabel)

        NSLayoutConstraint.activate([
            iconView.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            iconView.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20),
            valLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 6),
            valLabel.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            descLabel.topAnchor.constraint(equalTo: valLabel.bottomAnchor, constant: 2),
            descLabel.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            descLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12)
        ])

        return card
    }

    private func makeActivityRow(icon: String, text: String, time: String, color: UIColor) -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 10
        row.alignment = .center

        let iconBg = UIView()
        iconBg.backgroundColor = color.withAlphaComponent(0.12)
        iconBg.layer.cornerRadius = 14
        iconBg.translatesAutoresizingMaskIntoConstraints = false
        iconBg.widthAnchor.constraint(equalToConstant: 28).isActive = true
        iconBg.heightAnchor.constraint(equalToConstant: 28).isActive = true

        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = color
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconBg.addSubview(iconView)
        NSLayoutConstraint.activate([
            iconView.centerXAnchor.constraint(equalTo: iconBg.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconBg.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 14),
            iconView.heightAnchor.constraint(equalToConstant: 14)
        ])

        let textLabel = UILabel()
        textLabel.text = text
        textLabel.font = .systemFont(ofSize: 14, weight: .medium)
        textLabel.textColor = Theme.text

        let timeLabel = UILabel()
        timeLabel.text = time
        timeLabel.font = .systemFont(ofSize: 12)
        timeLabel.textColor = Theme.textMuted
        timeLabel.setContentHuggingPriority(.required, for: .horizontal)

        row.addArrangedSubview(iconBg)
        row.addArrangedSubview(textLabel)
        row.addArrangedSubview(timeLabel)

        return row
    }

    private func rankText(_ rank: Int) -> String {
        switch rank {
        case 1: return "  1st Place  "
        case 2: return "  2nd Place  "
        case 3: return "  3rd Place  "
        default: return "  #\(rank)  "
        }
    }

    private func rankColor(_ rank: Int) -> UIColor {
        switch rank {
        case 1: return Theme.gold
        case 2: return .systemGray
        case 3: return UIColor(red: 0.8, green: 0.5, blue: 0.2, alpha: 1.0)
        default: return Theme.accent
        }
    }

    private func avgPointsPerTask() -> String {
        if entry.tasksCompleted > 0 {
            return "\(Int(entry.points / Double(entry.tasksCompleted)))"
        }
        return "0"
    }

    struct Activity {
        let icon: String
        let text: String
        let time: String
        let color: UIColor
    }

    private func generateActivities() -> [Activity] {
        let isCurrentUser = entry.name == TaskStore.shared.profile.name
        if isCurrentUser {
            let recentTasks = TaskStore.shared.tasks.suffix(4)
            return recentTasks.reversed().map { task in
                switch task.taskStatus {
                case .completedEarly:
                    return Activity(icon: "bolt.fill", text: "Completed \"\(task.title)\" early!", time: "Recently", color: Theme.success)
                case .completedOnTime:
                    return Activity(icon: "checkmark.circle.fill", text: "Finished \"\(task.title)\" on time", time: "Recently", color: Theme.neon)
                case .completedLate:
                    return Activity(icon: "clock.fill", text: "Completed \"\(task.title)\" late", time: "Recently", color: Theme.warning)
                case .failed:
                    return Activity(icon: "xmark.circle.fill", text: "Missed \"\(task.title)\"", time: "Recently", color: Theme.danger)
                case .pending:
                    return Activity(icon: "plus.circle.fill", text: "Added \"\(task.title)\"", time: "Recently", color: Theme.accent)
                }
            }
        }

        return [
            Activity(icon: "bolt.fill", text: "Completed \"Study for finals\" early", time: "2h ago", color: Theme.success),
            Activity(icon: "checkmark.circle.fill", text: "Finished \"Gym workout\"", time: "5h ago", color: Theme.neon),
            Activity(icon: "plus.circle.fill", text: "Added \"Read chapter 5\"", time: "8h ago", color: Theme.accent),
            Activity(icon: "flame.fill", text: "3-day streak!", time: "1d ago", color: .systemOrange)
        ]
    }

    // MARK: - Animation

    private func animateIn() {
        let stack = scrollView.subviews.first as? UIStackView
        stack?.arrangedSubviews.enumerated().forEach { index, view in
            view.alpha = 0
            view.transform = CGAffineTransform(translationX: 0, y: 24)
            UIView.animate(withDuration: 0.45, delay: Double(index) * 0.08, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: []) {
                view.alpha = 1
                view.transform = .identity
            }
        }
    }
}
