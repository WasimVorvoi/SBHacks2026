import UIKit

class TaskListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let segmentControl = UISegmentedControl(items: ["Active", "Today", "Done"])
    private let pointsLabel = UILabel()
    private let pointsContainer = UIView()
    private let streakBadge = UILabel()
    private let emptyStateView = UIView()
    private let emptyIcon = UILabel()
    private let emptyLabel = UILabel()
    private var filterIndex = 0 // 0=Active, 1=Today, 2=Done
    private var animatedIndexPaths: Set<IndexPath> = []

    private var displayedTasks: [TaskItem] {
        switch filterIndex {
        case 0: return TaskStore.shared.pendingTasks()
        case 1: return TaskStore.shared.tasksForDate(Date())
        case 2: return TaskStore.shared.completedTasks()
        default: return []
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Tasks"
        view.backgroundColor = Theme.bg
        navigationItem.largeTitleDisplayMode = .always

        setupPointsBanner()
        setupSegmentControl()
        setupTableView()
        setupEmptyState()
        setupAddButton()

        // Check for expired tasks
        for i in 0..<TaskStore.shared.tasks.count {
            let task = TaskStore.shared.tasks[i]
            if !task.completed && task.deadlineDate < Date() {
                TaskStore.shared.tasks[i].completed = true
                TaskStore.shared.tasks[i].completedAt = task.deadline
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animatedIndexPaths.removeAll()
        updatePointsLabel(animated: false)
        updateStreakBadge()
        tableView.reloadData()
        updateEmptyState()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Theme.spring(0.6, delay: 0.1, damping: 0.7, velocity: 0.5) {
            self.pointsContainer.transform = .identity
            self.pointsContainer.alpha = 1
        }
    }

    // MARK: - Setup

    private func setupPointsBanner() {
        pointsContainer.translatesAutoresizingMaskIntoConstraints = false
        pointsContainer.transform = CGAffineTransform(translationX: 0, y: -20)
        pointsContainer.alpha = 0
        Theme.applyGlowCard(to: pointsContainer, cornerRadius: 14)
        view.addSubview(pointsContainer)

        pointsLabel.font = .monospacedDigitSystemFont(ofSize: 30, weight: .heavy)
        pointsLabel.textAlignment = .center
        pointsLabel.textColor = Theme.neon
        pointsLabel.translatesAutoresizingMaskIntoConstraints = false
        pointsContainer.addSubview(pointsLabel)

        let subtitle = UILabel()
        subtitle.text = "Total Points"
        subtitle.font = .systemFont(ofSize: 12, weight: .semibold)
        subtitle.textColor = Theme.textDim
        subtitle.textAlignment = .center
        subtitle.translatesAutoresizingMaskIntoConstraints = false
        pointsContainer.addSubview(subtitle)

        // Streak badge
        streakBadge.font = .systemFont(ofSize: 13, weight: .bold)
        streakBadge.textColor = .systemOrange
        streakBadge.translatesAutoresizingMaskIntoConstraints = false
        pointsContainer.addSubview(streakBadge)
        updateStreakBadge()

        NSLayoutConstraint.activate([
            pointsContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 4),
            pointsContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            pointsContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            pointsContainer.heightAnchor.constraint(equalToConstant: 60),

            pointsLabel.centerYAnchor.constraint(equalTo: pointsContainer.centerYAnchor, constant: -6),
            pointsLabel.centerXAnchor.constraint(equalTo: pointsContainer.centerXAnchor),

            subtitle.topAnchor.constraint(equalTo: pointsLabel.bottomAnchor, constant: -2),
            subtitle.centerXAnchor.constraint(equalTo: pointsContainer.centerXAnchor),

            streakBadge.trailingAnchor.constraint(equalTo: pointsContainer.trailingAnchor, constant: -14),
            streakBadge.centerYAnchor.constraint(equalTo: pointsContainer.centerYAnchor)
        ])
        updatePointsLabel(animated: false)
    }

    private func updatePointsLabel(animated: Bool = true) {
        let points = Int(TaskStore.shared.profile.totalPoints)
        let newText = "\(points)"
        guard newText != pointsLabel.text else { return }

        if animated {
            Theme.pop(pointsContainer, scale: 1.06)
            UIView.transition(with: pointsLabel, duration: 0.25, options: .transitionCrossDissolve) {
                self.pointsLabel.text = newText
            }
        } else {
            pointsLabel.text = newText
        }
    }

    private func setupSegmentControl() {
        segmentControl.selectedSegmentIndex = 0
        segmentControl.selectedSegmentTintColor = Theme.accent
        segmentControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        segmentControl.setTitleTextAttributes([.foregroundColor: Theme.textDim], for: .normal)
        segmentControl.backgroundColor = Theme.card
        segmentControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(segmentControl)

        NSLayoutConstraint.activate([
            segmentControl.topAnchor.constraint(equalTo: pointsContainer.bottomAnchor, constant: 12),
            segmentControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TaskCell.self, forCellReuseIdentifier: "TaskCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 100, right: 0)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupEmptyState() {
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.isHidden = true
        view.addSubview(emptyStateView)

        emptyIcon.text = "📋"
        emptyIcon.font = .systemFont(ofSize: 56)
        emptyIcon.textAlignment = .center
        emptyIcon.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.addSubview(emptyIcon)

        emptyLabel.text = "No tasks yet!\nTap + to add your first task"
        emptyLabel.font = .systemFont(ofSize: 16, weight: .medium)
        emptyLabel.textColor = Theme.textMuted
        emptyLabel.textAlignment = .center
        emptyLabel.numberOfLines = 0
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            emptyStateView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: tableView.centerYAnchor, constant: -30),
            emptyStateView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -60),

            emptyIcon.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            emptyIcon.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),

            emptyLabel.topAnchor.constraint(equalTo: emptyIcon.bottomAnchor, constant: 12),
            emptyLabel.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyLabel.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor)
        ])
    }

    private func updateStreakBadge() {
        let streak = TaskStore.shared.profile.streak
        if streak > 0 {
            streakBadge.text = "🔥 \(streak)"
            streakBadge.isHidden = false
        } else {
            streakBadge.isHidden = true
        }
    }

    private func checkChallenges() {
        let completed = ChallengesManager.shared.checkAndComplete(
            tasks: TaskStore.shared.tasks,
            profile: TaskStore.shared.profile
        )
        for challenge in completed {
            TaskStore.shared.profile.totalPoints += Double(challenge.bonusPts)
            showChallengeToast(challenge)
        }
    }

    private func showChallengeToast(_ challenge: Challenge) {
        let toast = UIView()
        Theme.applyGlowCard(to: toast)
        toast.translatesAutoresizingMaskIntoConstraints = false
        toast.alpha = 0
        toast.transform = CGAffineTransform(translationX: 0, y: -60)
        view.addSubview(toast)

        let icon = UIImageView(image: UIImage(systemName: challenge.icon))
        icon.tintColor = Theme.neon
        icon.translatesAutoresizingMaskIntoConstraints = false
        toast.addSubview(icon)

        let titleLabel = UILabel()
        titleLabel.text = "Challenge Complete!"
        titleLabel.font = .systemFont(ofSize: 11, weight: .bold)
        titleLabel.textColor = Theme.neon
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        toast.addSubview(titleLabel)

        let nameLabel = UILabel()
        nameLabel.text = "\(challenge.title) +\(challenge.bonusPts)pts"
        nameLabel.font = .systemFont(ofSize: 14, weight: .bold)
        nameLabel.textColor = Theme.text
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        toast.addSubview(nameLabel)

        NSLayoutConstraint.activate([
            toast.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            toast.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            toast.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            toast.heightAnchor.constraint(equalToConstant: 56),

            icon.leadingAnchor.constraint(equalTo: toast.leadingAnchor, constant: 14),
            icon.centerYAnchor.constraint(equalTo: toast.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 24),
            icon.heightAnchor.constraint(equalToConstant: 24),

            titleLabel.topAnchor.constraint(equalTo: toast.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 10),

            nameLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            nameLabel.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 10)
        ])

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: []) {
            toast.alpha = 1
            toast.transform = .identity
        } completion: { _ in
            UIView.animate(withDuration: 0.4, delay: 2.5, options: .curveEaseIn) {
                toast.alpha = 0
                toast.transform = CGAffineTransform(translationX: 0, y: -60)
            } completion: { _ in
                toast.removeFromSuperview()
            }
        }
    }

    private func updateEmptyState() {
        let isEmpty = displayedTasks.isEmpty
        if isEmpty {
            let emptyTexts = [
                "No tasks yet!\nTap + to add your first task",
                "No tasks today!\nEnjoy or add something",
                "No completed tasks yet.\nGet started on your goals!"
            ]
            emptyIcon.text = filterIndex == 2 ? "🎉" : "📋"
            emptyLabel.text = emptyTexts[min(filterIndex, 2)]
        }

        UIView.animate(withDuration: 0.3) {
            self.emptyStateView.isHidden = !isEmpty
            self.emptyStateView.alpha = isEmpty ? 1 : 0
            self.tableView.alpha = isEmpty ? 0.3 : 1
        }
    }

    private func setupAddButton() {
        let addButton = UIButton(type: .system)
        addButton.setImage(UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)), for: .normal)
        addButton.tintColor = .black
        addButton.backgroundColor = Theme.accent
        addButton.layer.cornerRadius = 26
        addButton.layer.shadowColor = Theme.accent.cgColor
        addButton.layer.shadowOpacity = 0.4
        addButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        addButton.layer.shadowRadius = 20
        addButton.translatesAutoresizingMaskIntoConstraints = false
        Theme.addButtonEffect(to: addButton)
        addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
        view.addSubview(addButton)

        NSLayoutConstraint.activate([
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addButton.widthAnchor.constraint(equalToConstant: 52),
            addButton.heightAnchor.constraint(equalToConstant: 52)
        ])
    }

    // MARK: - Actions

    @objc private func segmentChanged() {
        Theme.hapticLight()
        filterIndex = segmentControl.selectedSegmentIndex
        animatedIndexPaths.removeAll()

        UIView.transition(with: tableView, duration: 0.3, options: .transitionCrossDissolve) {
            self.tableView.reloadData()
        }
        updateEmptyState()
    }

    @objc private func addTapped() {
        Theme.hapticMedium()
        let addVC = AddTaskViewController()
        addVC.onTaskAdded = { [weak self] in
            self?.animatedIndexPaths.removeAll()
            self?.tableView.reloadData()
            self?.updatePointsLabel()
            self?.updateEmptyState()
        }
        let nav = UINavigationController(rootViewController: addVC)
        nav.modalPresentationStyle = .pageSheet
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 24
        }
        present(nav, animated: true)
    }

    // MARK: - Confetti on complete

    private func showCompletionCelebration(points: Int) {
        let overlay = UIView(frame: view.bounds)
        overlay.backgroundColor = .clear
        overlay.isUserInteractionEnabled = false
        view.addSubview(overlay)

        let popup = UILabel()
        popup.text = "+\(points) pts"
        popup.font = .monospacedDigitSystemFont(ofSize: 32, weight: .heavy)
        popup.textColor = Theme.neon
        popup.textAlignment = .center
        popup.alpha = 0
        popup.transform = CGAffineTransform(scaleX: 0.5, y: 0.5).translatedBy(x: 0, y: 30)
        popup.translatesAutoresizingMaskIntoConstraints = false
        overlay.addSubview(popup)
        NSLayoutConstraint.activate([
            popup.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            popup.centerYAnchor.constraint(equalTo: overlay.centerYAnchor, constant: -40)
        ])

        Theme.hapticSuccess()

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: []) {
            popup.alpha = 1
            popup.transform = .identity
        } completion: { _ in
            UIView.animate(withDuration: 0.4, delay: 0.6, options: .curveEaseIn) {
                popup.alpha = 0
                popup.transform = CGAffineTransform(translationX: 0, y: -50)
            } completion: { _ in
                overlay.removeFromSuperview()
            }
        }

        emitConfetti(on: overlay)
    }

    private func emitConfetti(on view: UIView) {
        let colors: [UIColor] = [Theme.neon, Theme.accent, Theme.accentLight, Theme.success, Theme.gold]
        for i in 0..<20 {
            let confetti = UIView()
            confetti.backgroundColor = colors[i % colors.count]
            confetti.frame = CGRect(x: CGFloat.random(in: 0...view.bounds.width), y: -10, width: CGFloat.random(in: 6...10), height: CGFloat.random(in: 6...10))
            confetti.layer.cornerRadius = 3
            confetti.transform = CGAffineTransform(rotationAngle: CGFloat.random(in: 0...(.pi * 2)))
            view.addSubview(confetti)

            UIView.animate(withDuration: Double.random(in: 1.0...1.8), delay: Double(i) * 0.03, options: .curveEaseIn) {
                confetti.frame.origin.y = view.bounds.height + 20
                confetti.frame.origin.x += CGFloat.random(in: -80...80)
                confetti.transform = CGAffineTransform(rotationAngle: CGFloat.random(in: 0...(.pi * 4)))
                confetti.alpha = 0
            } completion: { _ in
                confetti.removeFromSuperview()
            }
        }
    }

    // MARK: - TableView

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedTasks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskCell
        cell.configure(with: displayedTasks[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard !animatedIndexPaths.contains(indexPath) else { return }
        animatedIndexPaths.insert(indexPath)

        cell.alpha = 0
        cell.transform = CGAffineTransform(translationX: 0, y: 20)
        UIView.animate(withDuration: 0.4, delay: Double(indexPath.row) * 0.05, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: []) {
            cell.alpha = 1
            cell.transform = .identity
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let task = displayedTasks[indexPath.row]
        var actions: [UIContextualAction] = []

        if task.taskStatus == .pending {
            let complete = UIContextualAction(style: .normal, title: nil) { [weak self] _, _, handler in
                TaskStore.shared.completeTask(id: task.id)

                if let updated = TaskStore.shared.tasks.first(where: { $0.id == task.id }) {
                    self?.showCompletionCelebration(points: updated.points)
                }

                self?.updatePointsLabel()
                self?.updateStreakBadge()
                self?.checkChallenges()
                self?.animatedIndexPaths.removeAll()
                self?.tableView.reloadData()
                self?.updateEmptyState()
                handler(true)
            }
            complete.backgroundColor = Theme.success
            complete.image = UIImage(systemName: "checkmark.circle.fill")
            actions.append(complete)
        }

        let delete = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, handler in
            Theme.hapticMedium()
            TaskStore.shared.deleteTask(id: task.id)
            self?.animatedIndexPaths.removeAll()
            self?.tableView.reloadData()
            self?.updateEmptyState()
            handler(true)
        }
        delete.image = UIImage(systemName: "trash.fill")
        actions.append(delete)

        let config = UISwipeActionsConfiguration(actions: actions)
        config.performsFirstActionWithFullSwipe = true
        return config
    }
}

// MARK: - TaskCell (Dark Card Style)

class TaskCell: UITableViewCell {
    private let cardView = UIView()
    private let titleLabel = UILabel()
    private let detailLabel = UILabel()
    private let pointsBadge = UILabel()
    private let difficultyBar = UIView()
    private let categoryLabel = UILabel()
    private let timeIcon = UIImageView()
    private let diffDots = UIStackView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        Theme.applyCard(to: cardView)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cardView)

        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = Theme.text

        detailLabel.font = .systemFont(ofSize: 12, weight: .medium)
        detailLabel.textColor = Theme.textDim

        categoryLabel.font = .systemFont(ofSize: 11, weight: .semibold)
        categoryLabel.textColor = Theme.accentLight
        categoryLabel.backgroundColor = Theme.accentDim
        categoryLabel.layer.cornerRadius = 6
        categoryLabel.clipsToBounds = true
        categoryLabel.textAlignment = .center

        pointsBadge.font = .monospacedDigitSystemFont(ofSize: 14, weight: .bold)
        pointsBadge.textAlignment = .center
        pointsBadge.layer.cornerRadius = 10
        pointsBadge.clipsToBounds = true

        difficultyBar.layer.cornerRadius = 2.5

        timeIcon.image = UIImage(systemName: "clock")
        timeIcon.tintColor = Theme.textMuted
        timeIcon.contentMode = .scaleAspectFit

        for v in [difficultyBar, titleLabel, detailLabel, pointsBadge, timeIcon, categoryLabel] as [UIView] {
            v.translatesAutoresizingMaskIntoConstraints = false
            cardView.addSubview(v)
        }

        diffDots.axis = .horizontal
        diffDots.spacing = 3
        diffDots.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(diffDots)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),

            difficultyBar.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            difficultyBar.topAnchor.constraint(equalTo: cardView.topAnchor),
            difficultyBar.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),
            difficultyBar.widthAnchor.constraint(equalToConstant: 5),

            titleLabel.leadingAnchor.constraint(equalTo: difficultyBar.trailingAnchor, constant: 14),
            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: pointsBadge.leadingAnchor, constant: -10),

            categoryLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            categoryLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            categoryLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 40),
            categoryLabel.heightAnchor.constraint(equalToConstant: 18),

            timeIcon.leadingAnchor.constraint(equalTo: categoryLabel.trailingAnchor, constant: 8),
            timeIcon.centerYAnchor.constraint(equalTo: categoryLabel.centerYAnchor),
            timeIcon.widthAnchor.constraint(equalToConstant: 12),
            timeIcon.heightAnchor.constraint(equalToConstant: 12),

            detailLabel.leadingAnchor.constraint(equalTo: timeIcon.trailingAnchor, constant: 3),
            detailLabel.centerYAnchor.constraint(equalTo: timeIcon.centerYAnchor),

            diffDots.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            diffDots.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 6),

            pointsBadge.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            pointsBadge.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            pointsBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 56),
            pointsBadge.heightAnchor.constraint(equalToConstant: 28)
        ])
    }

    func configure(with task: TaskItem) {
        titleLabel.text = task.title

        // Category badge
        let cat = task.categoryEnum
        categoryLabel.text = " \(cat.emoji) \(cat.label) "

        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated

        let deadlineDate = task.deadlineDate
        let timeLeft = deadlineDate.timeIntervalSinceNow
        if task.taskStatus == .pending {
            if timeLeft > 0 {
                detailLabel.text = formatter.localizedString(for: deadlineDate, relativeTo: Date())
                detailLabel.textColor = timeLeft < 3600 ? Theme.danger : Theme.textDim
                timeIcon.tintColor = timeLeft < 3600 ? Theme.danger : Theme.textMuted
            } else {
                detailLabel.text = "OVERDUE"
                detailLabel.textColor = Theme.danger
                timeIcon.tintColor = Theme.danger
            }
        } else {
            let df = DateFormatter()
            df.dateStyle = .short
            df.timeStyle = .short
            detailLabel.text = "Due: \(df.string(from: deadlineDate))"
            detailLabel.textColor = Theme.textDim
            timeIcon.tintColor = Theme.textMuted
        }

        // Difficulty dots
        diffDots.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let color = Theme.difficultyColor(for: task.difficulty)
        for i in 0..<10 {
            let dot = UIView()
            dot.layer.cornerRadius = 3
            dot.backgroundColor = i < task.difficulty ? color : Theme.border
            dot.translatesAutoresizingMaskIntoConstraints = false
            dot.widthAnchor.constraint(equalToConstant: 6).isActive = true
            dot.heightAnchor.constraint(equalToConstant: 6).isActive = true
            diffDots.addArrangedSubview(dot)
        }

        difficultyBar.backgroundColor = color
        difficultyBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]

        // Points badge
        switch task.taskStatus {
        case .pending:
            pointsBadge.text = "\(task.points) pts"
            pointsBadge.backgroundColor = Theme.accentDim
            pointsBadge.textColor = Theme.accentLight
        case .completedEarly:
            pointsBadge.text = "+\(task.points)"
            pointsBadge.backgroundColor = Theme.success.withAlphaComponent(0.12)
            pointsBadge.textColor = Theme.success
        case .completedOnTime:
            pointsBadge.text = "+\(task.points)"
            pointsBadge.backgroundColor = Theme.neonDim
            pointsBadge.textColor = Theme.neon
        case .completedLate:
            pointsBadge.text = "+\(task.points)"
            pointsBadge.backgroundColor = Theme.warning.withAlphaComponent(0.12)
            pointsBadge.textColor = Theme.warning
        case .failed:
            pointsBadge.text = "0 pts"
            pointsBadge.backgroundColor = Theme.danger.withAlphaComponent(0.12)
            pointsBadge.textColor = Theme.danger
        }

        // Flagged border
        if task.flagged {
            cardView.layer.borderColor = Theme.danger.withAlphaComponent(0.4).cgColor
        } else {
            cardView.layer.borderColor = Theme.border.cgColor
        }
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        UIView.animate(withDuration: highlighted ? 0.1 : 0.25) {
            self.cardView.backgroundColor = highlighted ? Theme.cardHover : Theme.card
        }
    }
}

// MARK: - Rounded Font Extension

extension UIFont {
    static func rounded(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
        let systemFont = UIFont.systemFont(ofSize: size, weight: weight)
        if let descriptor = systemFont.fontDescriptor.withDesign(.rounded) {
            return UIFont(descriptor: descriptor, size: size)
        }
        return systemFont
    }
}
