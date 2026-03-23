import UIKit

class ProfileViewController: UIViewController {

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let nameField = UITextField()
    private let pointsLabel = UILabel()
    private let statsStack = UIStackView()
    private let avatarLabel = UILabel()
    private let levelTitleLabel = UILabel()
    private let levelSubLabel = UILabel()
    private var levelProgressFill: UIView?
    private var levelProgressWidthConstraint: NSLayoutConstraint?
    private var statBoxes: [UIView] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Profile"
        view.backgroundColor = Theme.bg
        navigationItem.largeTitleDisplayMode = .always
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshStats(animated: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateIn()
    }

    private func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.alignment = .fill
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -100),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32)
        ])

        // Profile card (emoji + name + level badge)
        let profileCard = UIView()
        Theme.applyGlowCard(to: profileCard, cornerRadius: 14)
        profileCard.translatesAutoresizingMaskIntoConstraints = false

        // Emoji circle
        let emojiCircle = UIView()
        emojiCircle.backgroundColor = Theme.accentDim
        emojiCircle.layer.cornerRadius = 36
        emojiCircle.layer.borderWidth = 2
        emojiCircle.layer.borderColor = Theme.accentGlow.cgColor
        emojiCircle.translatesAutoresizingMaskIntoConstraints = false
        profileCard.addSubview(emojiCircle)

        avatarLabel.text = TaskStore.shared.profile.emoji
        avatarLabel.font = .systemFont(ofSize: 36)
        avatarLabel.textAlignment = .center
        avatarLabel.translatesAutoresizingMaskIntoConstraints = false
        emojiCircle.addSubview(avatarLabel)

        nameField.text = TaskStore.shared.profile.name
        nameField.font = .systemFont(ofSize: 22, weight: .bold)
        nameField.textColor = Theme.text
        nameField.textAlignment = .center
        nameField.borderStyle = .none
        nameField.returnKeyType = .done
        nameField.addTarget(self, action: #selector(nameChanged), for: .editingDidEnd)
        nameField.addTarget(self, action: #selector(nameReturnPressed), for: .editingDidEndOnExit)
        nameField.translatesAutoresizingMaskIntoConstraints = false
        profileCard.addSubview(nameField)

        // Level badge
        let levelBadge = UILabel()
        let p = TaskStore.shared.profile
        levelBadge.text = "  Lv.\(p.level) \(p.levelTitle)  "
        levelBadge.font = .systemFont(ofSize: 12, weight: .bold)
        levelBadge.textColor = Theme.accentLight
        levelBadge.backgroundColor = Theme.accentDim
        levelBadge.layer.cornerRadius = 10
        levelBadge.clipsToBounds = true
        levelBadge.textAlignment = .center
        levelBadge.translatesAutoresizingMaskIntoConstraints = false
        profileCard.addSubview(levelBadge)

        NSLayoutConstraint.activate([
            profileCard.heightAnchor.constraint(equalToConstant: 140),

            emojiCircle.topAnchor.constraint(equalTo: profileCard.topAnchor, constant: 16),
            emojiCircle.centerXAnchor.constraint(equalTo: profileCard.centerXAnchor),
            emojiCircle.widthAnchor.constraint(equalToConstant: 72),
            emojiCircle.heightAnchor.constraint(equalToConstant: 72),

            avatarLabel.centerXAnchor.constraint(equalTo: emojiCircle.centerXAnchor),
            avatarLabel.centerYAnchor.constraint(equalTo: emojiCircle.centerYAnchor),

            nameField.topAnchor.constraint(equalTo: emojiCircle.bottomAnchor, constant: 8),
            nameField.centerXAnchor.constraint(equalTo: profileCard.centerXAnchor),
            nameField.widthAnchor.constraint(equalTo: profileCard.widthAnchor, constant: -40),

            levelBadge.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 4),
            levelBadge.centerXAnchor.constraint(equalTo: profileCard.centerXAnchor),
            levelBadge.heightAnchor.constraint(equalToConstant: 22)
        ])
        contentStack.addArrangedSubview(profileCard)

        // Points card
        let pointsCard = UIView()
        Theme.applyCard(to: pointsCard)
        pointsCard.translatesAutoresizingMaskIntoConstraints = false

        pointsLabel.font = .monospacedDigitSystemFont(ofSize: 44, weight: .heavy)
        pointsLabel.textColor = Theme.neon
        pointsLabel.textAlignment = .center
        pointsLabel.translatesAutoresizingMaskIntoConstraints = false
        pointsCard.addSubview(pointsLabel)

        let ptsSubtitle = UILabel()
        ptsSubtitle.text = "TOTAL POINTS"
        ptsSubtitle.font = .systemFont(ofSize: 11, weight: .bold)
        ptsSubtitle.textColor = Theme.textMuted
        ptsSubtitle.textAlignment = .center
        ptsSubtitle.translatesAutoresizingMaskIntoConstraints = false
        pointsCard.addSubview(ptsSubtitle)

        pointsCard.heightAnchor.constraint(equalToConstant: 90).isActive = true
        NSLayoutConstraint.activate([
            pointsLabel.centerXAnchor.constraint(equalTo: pointsCard.centerXAnchor),
            pointsLabel.topAnchor.constraint(equalTo: pointsCard.topAnchor, constant: 14),
            ptsSubtitle.centerXAnchor.constraint(equalTo: pointsCard.centerXAnchor),
            ptsSubtitle.topAnchor.constraint(equalTo: pointsLabel.bottomAnchor, constant: 0)
        ])
        contentStack.addArrangedSubview(pointsCard)

        // Level progress card
        let levelCard = UIView()
        Theme.applyCard(to: levelCard)
        levelCard.translatesAutoresizingMaskIntoConstraints = false

        levelTitleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        levelTitleLabel.textColor = Theme.text
        levelTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        levelCard.addSubview(levelTitleLabel)

        levelSubLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        levelSubLabel.textColor = Theme.textDim
        levelSubLabel.translatesAutoresizingMaskIntoConstraints = false
        levelCard.addSubview(levelSubLabel)

        let levelProgressBg = UIView()
        levelProgressBg.backgroundColor = Theme.bgSubtle
        levelProgressBg.layer.cornerRadius = 5
        levelProgressBg.translatesAutoresizingMaskIntoConstraints = false
        levelCard.addSubview(levelProgressBg)

        let fill = UIView()
        fill.layer.cornerRadius = 5
        fill.translatesAutoresizingMaskIntoConstraints = false
        levelProgressBg.addSubview(fill)
        self.levelProgressFill = fill

        // Gradient-like fill using accent
        fill.backgroundColor = Theme.accent

        NSLayoutConstraint.activate([
            levelCard.heightAnchor.constraint(equalToConstant: 72),

            levelTitleLabel.topAnchor.constraint(equalTo: levelCard.topAnchor, constant: 14),
            levelTitleLabel.leadingAnchor.constraint(equalTo: levelCard.leadingAnchor, constant: 16),

            levelSubLabel.centerYAnchor.constraint(equalTo: levelTitleLabel.centerYAnchor),
            levelSubLabel.trailingAnchor.constraint(equalTo: levelCard.trailingAnchor, constant: -16),

            levelProgressBg.topAnchor.constraint(equalTo: levelTitleLabel.bottomAnchor, constant: 10),
            levelProgressBg.leadingAnchor.constraint(equalTo: levelCard.leadingAnchor, constant: 16),
            levelProgressBg.trailingAnchor.constraint(equalTo: levelCard.trailingAnchor, constant: -16),
            levelProgressBg.heightAnchor.constraint(equalToConstant: 10),

            fill.leadingAnchor.constraint(equalTo: levelProgressBg.leadingAnchor),
            fill.topAnchor.constraint(equalTo: levelProgressBg.topAnchor),
            fill.bottomAnchor.constraint(equalTo: levelProgressBg.bottomAnchor)
        ])

        let progress = p.levelProgress
        levelProgressWidthConstraint = fill.widthAnchor.constraint(equalTo: levelProgressBg.widthAnchor, multiplier: max(0.02, progress))
        levelProgressWidthConstraint?.isActive = true

        contentStack.addArrangedSubview(levelCard)

        // Stats grid (2x2)
        statsStack.axis = .horizontal
        statsStack.distribution = .fillEqually
        statsStack.spacing = 10
        contentStack.addArrangedSubview(statsStack)

        let statsStack2 = UIStackView()
        statsStack2.axis = .horizontal
        statsStack2.distribution = .fillEqually
        statsStack2.spacing = 10
        statsStack2.tag = 100
        contentStack.addArrangedSubview(statsStack2)

        // Friend code card
        let friendCodeCard = createFriendCodeCard()
        contentStack.addArrangedSubview(friendCodeCard)

        // Activity heatmap
        let heatmapCard = createHeatmapCard()
        contentStack.addArrangedSubview(heatmapCard)

        // Scoring card
        let rulesCard = createRulesCard()
        contentStack.addArrangedSubview(rulesCard)

        // Reset button
        let resetBtn = UIButton(type: .system)
        resetBtn.setTitle("Reset All Data", for: .normal)
        resetBtn.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        resetBtn.setTitleColor(Theme.danger, for: .normal)
        resetBtn.backgroundColor = Theme.danger.withAlphaComponent(0.1)
        resetBtn.layer.cornerRadius = 12
        resetBtn.translatesAutoresizingMaskIntoConstraints = false
        resetBtn.heightAnchor.constraint(equalToConstant: 44).isActive = true
        resetBtn.addTarget(self, action: #selector(resetDataTapped), for: .touchUpInside)
        contentStack.addArrangedSubview(resetBtn)
    }

    private func refreshStats(animated: Bool) {
        let profile = TaskStore.shared.profile
        nameField.text = profile.name
        avatarLabel.text = profile.emoji

        if animated {
            UIView.transition(with: pointsLabel, duration: 0.3, options: .transitionCrossDissolve) {
                self.pointsLabel.text = "\(Int(profile.totalPoints))"
            }
            Theme.pop(pointsLabel.superview ?? pointsLabel, scale: 1.03)
        } else {
            pointsLabel.text = "\(Int(profile.totalPoints))"
        }

        // Update level
        levelTitleLabel.text = "Lv.\(profile.level) \(profile.levelTitle)"
        let progress = profile.levelProgress
        levelSubLabel.text = "\(Int(progress * 100))% to Level \(profile.level + 1)"

        // Stats
        statsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        statBoxes.removeAll()

        if let statsStack2 = contentStack.viewWithTag(100) as? UIStackView {
            statsStack2.arrangedSubviews.forEach { $0.removeFromSuperview() }

            let completed = TaskStore.shared.completedTasks().count
            let pending = TaskStore.shared.pendingTasks().count
            let streak = profile.streak
            let failed = TaskStore.shared.tasks.filter { $0.taskStatus == .failed }.count

            let row1 = [
                makeStatBox(value: "\(completed)", label: "DONE", color: Theme.success),
                makeStatBox(value: "\(pending)", label: "ACTIVE", color: Theme.accent)
            ]
            let row2 = [
                makeStatBox(value: "\(streak)", label: "STREAK", color: .systemOrange),
                makeStatBox(value: "\(failed)", label: "MISSED", color: Theme.danger)
            ]

            for box in row1 {
                statsStack.addArrangedSubview(box)
                statBoxes.append(box)
            }
            for box in row2 {
                statsStack2.addArrangedSubview(box)
                statBoxes.append(box)
            }
        }
    }

    private func animateIn() {
        for (i, box) in statBoxes.enumerated() {
            box.alpha = 0
            box.transform = CGAffineTransform(translationX: 0, y: 20)
            UIView.animate(withDuration: 0.4, delay: 0.1 + Double(i) * 0.08, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: []) {
                box.alpha = 1
                box.transform = .identity
            }
        }
    }

    private func makeStatBox(value: String, label: String, color: UIColor) -> UIView {
        let box = UIView()
        Theme.applyCard(to: box, cornerRadius: 14)

        let colorDot = UIView()
        colorDot.backgroundColor = color
        colorDot.layer.cornerRadius = 4
        colorDot.translatesAutoresizingMaskIntoConstraints = false

        let valLabel = UILabel()
        valLabel.text = value
        valLabel.font = .monospacedDigitSystemFont(ofSize: 26, weight: .bold)
        valLabel.textColor = Theme.text
        valLabel.textAlignment = .center
        valLabel.translatesAutoresizingMaskIntoConstraints = false

        let descLabel = UILabel()
        descLabel.text = label
        descLabel.font = .systemFont(ofSize: 10, weight: .bold)
        descLabel.textColor = Theme.textMuted
        descLabel.textAlignment = .center
        descLabel.translatesAutoresizingMaskIntoConstraints = false

        box.addSubview(colorDot)
        box.addSubview(valLabel)
        box.addSubview(descLabel)

        NSLayoutConstraint.activate([
            colorDot.topAnchor.constraint(equalTo: box.topAnchor, constant: 10),
            colorDot.centerXAnchor.constraint(equalTo: box.centerXAnchor),
            colorDot.widthAnchor.constraint(equalToConstant: 8),
            colorDot.heightAnchor.constraint(equalToConstant: 8),

            valLabel.topAnchor.constraint(equalTo: colorDot.bottomAnchor, constant: 6),
            valLabel.centerXAnchor.constraint(equalTo: box.centerXAnchor),

            descLabel.topAnchor.constraint(equalTo: valLabel.bottomAnchor, constant: 2),
            descLabel.centerXAnchor.constraint(equalTo: box.centerXAnchor),
            descLabel.bottomAnchor.constraint(equalTo: box.bottomAnchor, constant: -10)
        ])

        return box
    }

    private func createRulesCard() -> UIView {
        let card = UIView()
        Theme.applyCard(to: card)

        let headerLabel = UILabel()
        headerLabel.text = "Scoring"
        headerLabel.font = .systemFont(ofSize: 16, weight: .bold)
        headerLabel.textColor = Theme.text
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(headerLabel)

        let rulesStack = UIStackView()
        rulesStack.axis = .vertical
        rulesStack.spacing = 10
        rulesStack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(rulesStack)

        let rules: [(String, String, UIColor)] = [
            ("bolt.fill", "Early: 1.25x points", Theme.success),
            ("checkmark.circle.fill", "On time: 1.0x points", Theme.neon),
            ("clock.fill", "Late: 0.75x points", Theme.warning),
            ("xmark.circle.fill", "Missed: 0 points", Theme.danger)
        ]

        for (icon, text, color) in rules {
            let row = UIStackView()
            row.axis = .horizontal
            row.spacing = 10
            row.alignment = .center

            let iconView = UIImageView(image: UIImage(systemName: icon))
            iconView.tintColor = color
            iconView.contentMode = .scaleAspectFit
            iconView.translatesAutoresizingMaskIntoConstraints = false
            iconView.widthAnchor.constraint(equalToConstant: 20).isActive = true
            iconView.heightAnchor.constraint(equalToConstant: 20).isActive = true

            let label = UILabel()
            label.text = text
            label.font = .systemFont(ofSize: 14, weight: .medium)
            label.textColor = Theme.textDim

            row.addArrangedSubview(iconView)
            row.addArrangedSubview(label)
            rulesStack.addArrangedSubview(row)
        }

        let aiNote = UILabel()
        aiNote.text = "Difficulty is rated by AI (1-10). Harder tasks earn more base points!"
        aiNote.font = .systemFont(ofSize: 12)
        aiNote.textColor = Theme.textMuted
        aiNote.numberOfLines = 0
        aiNote.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(aiNote)

        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            headerLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),

            rulesStack.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 12),
            rulesStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            rulesStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),

            aiNote.topAnchor.constraint(equalTo: rulesStack.bottomAnchor, constant: 12),
            aiNote.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            aiNote.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            aiNote.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])

        return card
    }

    private func createFriendCodeCard() -> UIView {
        let card = UIView()
        Theme.applyGlowCard(to: card)

        let titleLabel = UILabel()
        titleLabel.text = "Your Friend Code"
        titleLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        titleLabel.textColor = Theme.textDim
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(titleLabel)

        let codeLabel = UILabel()
        let code = String(TaskStore.shared.profile.id.prefix(8)).uppercased()
        codeLabel.text = code
        codeLabel.font = .monospacedDigitSystemFont(ofSize: 26, weight: .heavy)
        codeLabel.textColor = Theme.neon
        codeLabel.textAlignment = .center
        codeLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(codeLabel)

        let copyBtn = UIButton(type: .system)
        copyBtn.setTitle("Copy", for: .normal)
        copyBtn.titleLabel?.font = .systemFont(ofSize: 13, weight: .bold)
        copyBtn.setTitleColor(Theme.accent, for: .normal)
        copyBtn.addTarget(self, action: #selector(copyFriendCode), for: .touchUpInside)
        copyBtn.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(copyBtn)

        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(equalToConstant: 72),
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            titleLabel.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            codeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            codeLabel.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            copyBtn.centerYAnchor.constraint(equalTo: codeLabel.centerYAnchor),
            copyBtn.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16)
        ])

        return card
    }

    @objc private func copyFriendCode() {
        let code = String(TaskStore.shared.profile.id.prefix(8)).uppercased()
        UIPasteboard.general.string = code
        Theme.hapticSuccess()
    }

    private func createHeatmapCard() -> UIView {
        let card = UIView()
        Theme.applyCard(to: card)

        let titleLabel = UILabel()
        titleLabel.text = "Activity (Last 7 Days)"
        titleLabel.font = .systemFont(ofSize: 14, weight: .bold)
        titleLabel.textColor = Theme.text
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(titleLabel)

        let dayStack = UIStackView()
        dayStack.axis = .horizontal
        dayStack.distribution = .fillEqually
        dayStack.spacing = 6
        dayStack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(dayStack)

        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let dayNames = ["S", "M", "T", "W", "T", "F", "S"]

        for i in (0..<7).reversed() {
            guard let day = cal.date(byAdding: .day, value: -i, to: today) else { continue }
            let weekday = cal.component(.weekday, from: day) - 1 // 0=Sun

            let col = UIStackView()
            col.axis = .vertical
            col.alignment = .center
            col.spacing = 4

            let label = UILabel()
            label.text = dayNames[weekday]
            label.font = .systemFont(ofSize: 10, weight: .bold)
            label.textColor = Theme.textMuted
            label.textAlignment = .center

            let count = TaskStore.shared.tasks.filter { task in
                guard task.completed, !task.flagged, let cd = task.completedDate else { return false }
                return cal.isDate(cd, inSameDayAs: day)
            }.count

            let block = UIView()
            block.layer.cornerRadius = 4
            block.translatesAutoresizingMaskIntoConstraints = false
            block.widthAnchor.constraint(equalToConstant: 28).isActive = true
            block.heightAnchor.constraint(equalToConstant: 28).isActive = true

            if count == 0 {
                block.backgroundColor = Theme.bgSubtle
            } else if count <= 1 {
                block.backgroundColor = Theme.accent.withAlphaComponent(0.25)
            } else if count <= 2 {
                block.backgroundColor = Theme.accent.withAlphaComponent(0.5)
            } else if count <= 3 {
                block.backgroundColor = Theme.accent.withAlphaComponent(0.75)
            } else {
                block.backgroundColor = Theme.accent
            }

            let countLabel = UILabel()
            countLabel.text = "\(count)"
            countLabel.font = .monospacedDigitSystemFont(ofSize: 10, weight: .bold)
            countLabel.textColor = count > 0 ? Theme.text : Theme.textMuted
            countLabel.textAlignment = .center
            countLabel.translatesAutoresizingMaskIntoConstraints = false
            block.addSubview(countLabel)
            NSLayoutConstraint.activate([
                countLabel.centerXAnchor.constraint(equalTo: block.centerXAnchor),
                countLabel.centerYAnchor.constraint(equalTo: block.centerYAnchor)
            ])

            col.addArrangedSubview(label)
            col.addArrangedSubview(block)
            dayStack.addArrangedSubview(col)
        }

        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(equalToConstant: 90),
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            dayStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            dayStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            dayStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16)
        ])

        return card
    }

    @objc private func resetDataTapped() {
        let alert = UIAlertController(title: "Reset All Data?", message: "This will delete all tasks, progress, and groups. This cannot be undone.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Reset", style: .destructive) { _ in
            UserDefaults.standard.removeObject(forKey: "clutch_state")
            UserDefaults.standard.removeObject(forKey: "clutch_completed_challenges")
            TaskStore.shared.tasks = []
            TaskStore.shared.myGroupCodes = []
            TaskStore.shared.profile = UserProfile(name: "Player")
            TaskStore.shared.onboarded = false
            Theme.hapticSuccess()

            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = scene.windows.first {
                let onboarding = OnboardingViewController()
                onboarding.onComplete = {
                    window.rootViewController = MainTabBarController()
                    UIView.transition(with: window, duration: 0.4, options: .transitionCrossDissolve, animations: nil)
                }
                window.rootViewController = onboarding
                UIView.transition(with: window, duration: 0.4, options: .transitionCrossDissolve, animations: nil)
            }
        })
        present(alert, animated: true)
    }

    @objc private func nameChanged() {
        guard let name = nameField.text, !name.isEmpty else { return }
        TaskStore.shared.profile.name = name
        Theme.hapticLight()
    }

    @objc private func nameReturnPressed() {
        nameField.resignFirstResponder()
    }
}
