import UIKit

class AddTaskViewController: UIViewController {

    var onTaskAdded: (() -> Void)?

    private let scrollView = UIScrollView()
    private let titleField = UITextField()
    private let descField = UITextField()
    private let datePicker = UIDatePicker()
    private let visibilityControl = UISegmentedControl(items: ["Private", "Friends", "Global", "Group"])
    private let difficultyLabel = UILabel()
    private let difficultyContainer = UIView()
    private let saveButton = UIButton(type: .system)
    private let aiLoadingIndicator = UIActivityIndicatorView(style: .medium)
    private let difficultyDotsStack = UIStackView()
    private let categoryStack = UIStackView()
    private let timeFrameControl = UISegmentedControl(items: ["Instant", "30m", "1h", "2h", "Custom"])
    private let groupCodeField = UITextField()
    private let groupCodeContainer = UIView()

    private var aiDifficulty: Int = 5
    private var selectedCategory: TaskCategory = .general
    private var customTimeMinutes: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "New Task"
        view.backgroundColor = Theme.bg

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        navigationItem.leftBarButtonItem?.tintColor = Theme.textDim

        setupUI()
        animateFormIn()

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.keyboardDismissMode = .interactive
        view.addSubview(scrollView)

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -20),
            stack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40)
        ])

        // Title
        let titleCard = makeFieldCard()
        styleTextField(titleField, placeholder: "What do you need to do?", icon: "pencil.line")
        titleField.font = .systemFont(ofSize: 18, weight: .medium)
        titleField.textColor = Theme.text
        titleField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        titleCard.addSubview(titleField)
        titleField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleField.topAnchor.constraint(equalTo: titleCard.topAnchor, constant: 14),
            titleField.leadingAnchor.constraint(equalTo: titleCard.leadingAnchor, constant: 14),
            titleField.trailingAnchor.constraint(equalTo: titleCard.trailingAnchor, constant: -14),
            titleField.bottomAnchor.constraint(equalTo: titleCard.bottomAnchor, constant: -14)
        ])
        stack.addArrangedSubview(titleCard)

        // Description
        let descCard = makeFieldCard()
        styleTextField(descField, placeholder: "Add details (optional)", icon: "text.alignleft")
        descField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        descCard.addSubview(descField)
        descField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            descField.topAnchor.constraint(equalTo: descCard.topAnchor, constant: 14),
            descField.leadingAnchor.constraint(equalTo: descCard.leadingAnchor, constant: 14),
            descField.trailingAnchor.constraint(equalTo: descCard.trailingAnchor, constant: -14),
            descField.bottomAnchor.constraint(equalTo: descCard.bottomAnchor, constant: -14)
        ])
        stack.addArrangedSubview(descCard)

        // Category card
        let catCard = makeFieldCard()
        let catLabel = UILabel()
        catLabel.text = "  Category"
        catLabel.font = .systemFont(ofSize: 14, weight: .medium)
        catLabel.textColor = Theme.textDim
        catLabel.translatesAutoresizingMaskIntoConstraints = false
        catCard.addSubview(catLabel)

        // First row: 4 categories
        let catRow1 = UIStackView()
        catRow1.axis = .horizontal
        catRow1.spacing = 8
        catRow1.distribution = .fillEqually
        catRow1.isUserInteractionEnabled = true
        catRow1.translatesAutoresizingMaskIntoConstraints = false
        catCard.addSubview(catRow1)

        let catRow2 = UIStackView()
        catRow2.axis = .horizontal
        catRow2.spacing = 8
        catRow2.distribution = .fillEqually
        catRow2.isUserInteractionEnabled = true
        catRow2.translatesAutoresizingMaskIntoConstraints = false
        catCard.addSubview(catRow2)

        for (i, cat) in TaskCategory.allCases.enumerated() {
            let btn = UIButton(type: .custom)
            btn.setTitle("\(cat.emoji) \(cat.label)", for: .normal)
            btn.titleLabel?.font = .systemFont(ofSize: 11, weight: .semibold)
            btn.titleLabel?.adjustsFontSizeToFitWidth = true
            btn.titleLabel?.minimumScaleFactor = 0.7
            btn.layer.cornerRadius = 10
            btn.layer.borderWidth = 1
            btn.clipsToBounds = true
            btn.tag = i
            btn.isUserInteractionEnabled = true
            btn.addTarget(self, action: #selector(categoryTapped(_:)), for: .touchUpInside)
            updateCategoryButton(btn, selected: i == 0)
            if i < 4 { catRow1.addArrangedSubview(btn) }
            else { catRow2.addArrangedSubview(btn) }
        }

        NSLayoutConstraint.activate([
            catLabel.topAnchor.constraint(equalTo: catCard.topAnchor, constant: 12),
            catLabel.leadingAnchor.constraint(equalTo: catCard.leadingAnchor, constant: 14),
            catRow1.topAnchor.constraint(equalTo: catLabel.bottomAnchor, constant: 10),
            catRow1.leadingAnchor.constraint(equalTo: catCard.leadingAnchor, constant: 10),
            catRow1.trailingAnchor.constraint(equalTo: catCard.trailingAnchor, constant: -10),
            catRow1.heightAnchor.constraint(equalToConstant: 34),
            catRow2.topAnchor.constraint(equalTo: catRow1.bottomAnchor, constant: 6),
            catRow2.leadingAnchor.constraint(equalTo: catCard.leadingAnchor, constant: 10),
            catRow2.trailingAnchor.constraint(equalTo: catCard.trailingAnchor, constant: -10),
            catRow2.heightAnchor.constraint(equalToConstant: 34),
            catRow2.bottomAnchor.constraint(equalTo: catCard.bottomAnchor, constant: -12)
        ])
        stack.addArrangedSubview(catCard)

        // Deadline card
        let deadlineCard = makeFieldCard()
        let deadlineRow = UIStackView()
        deadlineRow.axis = .horizontal
        deadlineRow.distribution = .equalSpacing
        deadlineRow.translatesAutoresizingMaskIntoConstraints = false
        deadlineCard.addSubview(deadlineRow)

        let clockIcon = UIImageView(image: UIImage(systemName: "calendar.badge.clock"))
        clockIcon.tintColor = Theme.accent
        clockIcon.contentMode = .scaleAspectFit
        clockIcon.widthAnchor.constraint(equalToConstant: 22).isActive = true

        let deadlineLabel = UILabel()
        deadlineLabel.text = "  Deadline"
        deadlineLabel.font = .systemFont(ofSize: 16, weight: .medium)
        let leftStack = UIStackView(arrangedSubviews: [clockIcon, deadlineLabel])
        leftStack.spacing = 8
        deadlineRow.addArrangedSubview(leftStack)

        datePicker.datePickerMode = .dateAndTime
        datePicker.minimumDate = Date()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.tintColor = Theme.neon
        datePicker.overrideUserInterfaceStyle = .dark
        deadlineRow.addArrangedSubview(datePicker)

        NSLayoutConstraint.activate([
            deadlineRow.topAnchor.constraint(equalTo: deadlineCard.topAnchor, constant: 10),
            deadlineRow.leadingAnchor.constraint(equalTo: deadlineCard.leadingAnchor, constant: 14),
            deadlineRow.trailingAnchor.constraint(equalTo: deadlineCard.trailingAnchor, constant: -14),
            deadlineRow.bottomAnchor.constraint(equalTo: deadlineCard.bottomAnchor, constant: -10)
        ])
        stack.addArrangedSubview(deadlineCard)

        // Time frame card
        let timeCard = makeFieldCard()
        let timeLabel = UILabel()
        timeLabel.text = "  Estimated Time"
        timeLabel.font = .systemFont(ofSize: 14, weight: .medium)
        timeLabel.textColor = Theme.textDim
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeCard.addSubview(timeLabel)

        timeFrameControl.selectedSegmentIndex = 2 // 1h default
        timeFrameControl.selectedSegmentTintColor = Theme.accent
        timeFrameControl.backgroundColor = Theme.card
        timeFrameControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        timeFrameControl.addTarget(self, action: #selector(timeFrameChanged), for: .valueChanged)
        timeFrameControl.translatesAutoresizingMaskIntoConstraints = false
        timeCard.addSubview(timeFrameControl)

        NSLayoutConstraint.activate([
            timeLabel.topAnchor.constraint(equalTo: timeCard.topAnchor, constant: 12),
            timeLabel.leadingAnchor.constraint(equalTo: timeCard.leadingAnchor, constant: 14),
            timeFrameControl.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 10),
            timeFrameControl.leadingAnchor.constraint(equalTo: timeCard.leadingAnchor, constant: 14),
            timeFrameControl.trailingAnchor.constraint(equalTo: timeCard.trailingAnchor, constant: -14),
            timeFrameControl.bottomAnchor.constraint(equalTo: timeCard.bottomAnchor, constant: -12)
        ])
        stack.addArrangedSubview(timeCard)

        // Visibility card
        let visCard = makeFieldCard()
        let visLabel = UILabel()
        visLabel.text = "  Competition Mode"
        visLabel.font = .systemFont(ofSize: 14, weight: .medium)
        visLabel.textColor = Theme.textDim
        visLabel.translatesAutoresizingMaskIntoConstraints = false
        visCard.addSubview(visLabel)

        visibilityControl.selectedSegmentIndex = 0
        visibilityControl.selectedSegmentTintColor = Theme.accent
        visibilityControl.backgroundColor = Theme.card
        visibilityControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        visibilityControl.addTarget(self, action: #selector(visibilityChanged), for: .valueChanged)
        visibilityControl.translatesAutoresizingMaskIntoConstraints = false
        visCard.addSubview(visibilityControl)

        // Group code field (hidden by default)
        Theme.applyCard(to: groupCodeContainer, cornerRadius: 10)
        groupCodeContainer.isHidden = true
        groupCodeContainer.translatesAutoresizingMaskIntoConstraints = false
        visCard.addSubview(groupCodeContainer)

        groupCodeField.attributedPlaceholder = NSAttributedString(string: "Enter group code", attributes: [.foregroundColor: Theme.textMuted])
        groupCodeField.font = .monospacedSystemFont(ofSize: 18, weight: .bold)
        groupCodeField.textColor = Theme.neon
        groupCodeField.textAlignment = .center
        groupCodeField.autocapitalizationType = .allCharacters
        groupCodeField.borderStyle = .none
        groupCodeField.translatesAutoresizingMaskIntoConstraints = false
        groupCodeContainer.addSubview(groupCodeField)

        NSLayoutConstraint.activate([
            visLabel.topAnchor.constraint(equalTo: visCard.topAnchor, constant: 12),
            visLabel.leadingAnchor.constraint(equalTo: visCard.leadingAnchor, constant: 14),
            visibilityControl.topAnchor.constraint(equalTo: visLabel.bottomAnchor, constant: 10),
            visibilityControl.leadingAnchor.constraint(equalTo: visCard.leadingAnchor, constant: 14),
            visibilityControl.trailingAnchor.constraint(equalTo: visCard.trailingAnchor, constant: -14),

            groupCodeContainer.topAnchor.constraint(equalTo: visibilityControl.bottomAnchor, constant: 10),
            groupCodeContainer.leadingAnchor.constraint(equalTo: visCard.leadingAnchor, constant: 14),
            groupCodeContainer.trailingAnchor.constraint(equalTo: visCard.trailingAnchor, constant: -14),
            groupCodeContainer.heightAnchor.constraint(equalToConstant: 44),
            groupCodeContainer.bottomAnchor.constraint(equalTo: visCard.bottomAnchor, constant: -12),

            groupCodeField.topAnchor.constraint(equalTo: groupCodeContainer.topAnchor),
            groupCodeField.leadingAnchor.constraint(equalTo: groupCodeContainer.leadingAnchor, constant: 10),
            groupCodeField.trailingAnchor.constraint(equalTo: groupCodeContainer.trailingAnchor, constant: -10),
            groupCodeField.bottomAnchor.constraint(equalTo: groupCodeContainer.bottomAnchor)
        ])

        // Need a bottom constraint for when group code is hidden
        let visBottom = visibilityControl.bottomAnchor.constraint(equalTo: visCard.bottomAnchor, constant: -12)
        visBottom.priority = .defaultLow
        visBottom.isActive = true

        stack.addArrangedSubview(visCard)

        // AI Difficulty card
        Theme.applyCard(to: difficultyContainer)
        difficultyContainer.translatesAutoresizingMaskIntoConstraints = false

        let aiIcon = UIImageView(image: UIImage(systemName: "brain.head.profile"))
        aiIcon.tintColor = Theme.accent
        aiIcon.contentMode = .scaleAspectFit
        aiIcon.translatesAutoresizingMaskIntoConstraints = false

        let aiTitle = UILabel()
        aiTitle.text = "AI Difficulty Rating"
        aiTitle.font = .systemFont(ofSize: 14, weight: .medium)
        aiTitle.textColor = Theme.textDim
        aiTitle.translatesAutoresizingMaskIntoConstraints = false

        difficultyLabel.text = "—"
        difficultyLabel.font = .rounded(ofSize: 36, weight: .heavy)
        difficultyLabel.textColor = Theme.accent
        difficultyLabel.textAlignment = .center
        difficultyLabel.translatesAutoresizingMaskIntoConstraints = false

        aiLoadingIndicator.hidesWhenStopped = true
        aiLoadingIndicator.color = Theme.accent
        aiLoadingIndicator.translatesAutoresizingMaskIntoConstraints = false

        difficultyDotsStack.axis = .horizontal
        difficultyDotsStack.spacing = 5
        difficultyDotsStack.distribution = .fillEqually
        difficultyDotsStack.translatesAutoresizingMaskIntoConstraints = false

        for _ in 0..<10 {
            let dot = UIView()
            dot.backgroundColor = Theme.border
            dot.layer.cornerRadius = 4
            dot.heightAnchor.constraint(equalToConstant: 8).isActive = true
            difficultyDotsStack.addArrangedSubview(dot)
        }

        difficultyContainer.addSubview(aiIcon)
        difficultyContainer.addSubview(aiTitle)
        difficultyContainer.addSubview(difficultyLabel)
        difficultyContainer.addSubview(aiLoadingIndicator)
        difficultyContainer.addSubview(difficultyDotsStack)

        NSLayoutConstraint.activate([
            aiIcon.topAnchor.constraint(equalTo: difficultyContainer.topAnchor, constant: 14),
            aiIcon.leadingAnchor.constraint(equalTo: difficultyContainer.leadingAnchor, constant: 14),
            aiIcon.widthAnchor.constraint(equalToConstant: 20),
            aiIcon.heightAnchor.constraint(equalToConstant: 20),
            aiTitle.centerYAnchor.constraint(equalTo: aiIcon.centerYAnchor),
            aiTitle.leadingAnchor.constraint(equalTo: aiIcon.trailingAnchor, constant: 8),
            aiLoadingIndicator.centerYAnchor.constraint(equalTo: aiIcon.centerYAnchor),
            aiLoadingIndicator.trailingAnchor.constraint(equalTo: difficultyContainer.trailingAnchor, constant: -14),
            difficultyLabel.topAnchor.constraint(equalTo: aiIcon.bottomAnchor, constant: 8),
            difficultyLabel.centerXAnchor.constraint(equalTo: difficultyContainer.centerXAnchor),
            difficultyDotsStack.topAnchor.constraint(equalTo: difficultyLabel.bottomAnchor, constant: 8),
            difficultyDotsStack.leadingAnchor.constraint(equalTo: difficultyContainer.leadingAnchor, constant: 20),
            difficultyDotsStack.trailingAnchor.constraint(equalTo: difficultyContainer.trailingAnchor, constant: -20),
            difficultyDotsStack.bottomAnchor.constraint(equalTo: difficultyContainer.bottomAnchor, constant: -14)
        ])
        stack.addArrangedSubview(difficultyContainer)

        // Save button
        saveButton.setTitle("Add Task", for: .normal)
        saveButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        saveButton.backgroundColor = Theme.neon
        saveButton.setTitleColor(.black, for: .normal)
        saveButton.layer.cornerRadius = 28
        saveButton.layer.shadowColor = Theme.accent.cgColor
        saveButton.layer.shadowOpacity = 0.4
        saveButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        saveButton.layer.shadowRadius = 10
        saveButton.heightAnchor.constraint(equalToConstant: 54).isActive = true
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        Theme.addButtonEffect(to: saveButton)
        stack.addArrangedSubview(saveButton)
    }

    // MARK: - Helpers

    private func makeFieldCard() -> UIView {
        let card = UIView()
        Theme.applyCard(to: card)
        return card
    }

    private func styleTextField(_ field: UITextField, placeholder: String, icon: String) {
        field.borderStyle = .none
        field.textColor = Theme.text
        field.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [.foregroundColor: Theme.textMuted])
        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = Theme.textMuted
        iconView.contentMode = .scaleAspectFit
        iconView.frame = CGRect(x: 0, y: 0, width: 24, height: 20)
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 20))
        container.addSubview(iconView)
        field.leftView = container
        field.leftViewMode = .always
    }

    private func updateCategoryButton(_ btn: UIButton, selected: Bool) {
        if selected {
            btn.backgroundColor = Theme.accentDim
            btn.layer.borderColor = Theme.accent.cgColor
            btn.setTitleColor(Theme.text, for: .normal)
        } else {
            btn.backgroundColor = Theme.card
            btn.layer.borderColor = Theme.border.cgColor
            btn.setTitleColor(Theme.textDim, for: .normal)
        }
    }

    private func animateFormIn() {
        let stack = scrollView.subviews.first as? UIStackView
        stack?.arrangedSubviews.enumerated().forEach { index, view in
            view.alpha = 0
            view.transform = CGAffineTransform(translationX: 0, y: 20)
            UIView.animate(withDuration: 0.45, delay: Double(index) * 0.05, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: []) {
                view.alpha = 1
                view.transform = .identity
            }
        }
    }

    private var selectedTimeMinutes: Int {
        switch timeFrameControl.selectedSegmentIndex {
        case 0: return 0 // instant
        case 1: return 30
        case 2: return 60
        case 3: return 120
        case 4: return customTimeMinutes > 0 ? customTimeMinutes : 60
        default: return 60
        }
    }

    // MARK: - Actions

    @objc private func categoryTapped(_ sender: UIButton) {
        Theme.hapticLight()
        selectedCategory = TaskCategory.allCases[sender.tag]

        // Update all category buttons — sender is in a row stack, which is in the catCard
        if let rowStack = sender.superview as? UIStackView,
           let catCard = rowStack.superview {
            for sub in catCard.subviews {
                if let stack = sub as? UIStackView {
                    for case let btn as UIButton in stack.arrangedSubviews {
                        updateCategoryButton(btn, selected: btn.tag == sender.tag)
                    }
                }
            }
        }
        triggerDifficultyUpdate()
    }

    @objc private func visibilityChanged() {
        Theme.hapticLight()
        let isGroup = visibilityControl.selectedSegmentIndex == 3
        UIView.animate(withDuration: 0.3) {
            self.groupCodeContainer.isHidden = !isGroup
            self.groupCodeContainer.alpha = isGroup ? 1 : 0
        }
        triggerDifficultyUpdate()
    }

    @objc private func timeFrameChanged() {
        Theme.hapticLight()
        triggerDifficultyUpdate()
    }

    private func triggerDifficultyUpdate() {
        guard titleField.text != nil, !titleField.text!.isEmpty else { return }
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(requestAIDifficulty), object: nil)
        perform(#selector(requestAIDifficulty), with: nil, afterDelay: 0.5)
    }

    @objc private func textChanged() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(requestAIDifficulty), object: nil)
        perform(#selector(requestAIDifficulty), with: nil, afterDelay: 1.0)
    }

    @objc private func requestAIDifficulty() {
        guard let title = titleField.text, !title.isEmpty else { return }
        aiLoadingIndicator.startAnimating()
        difficultyLabel.text = "..."

        UIView.animate(withDuration: 0.6, delay: 0, options: [.repeat, .autoreverse]) {
            self.difficultyContainer.alpha = 0.7
        }

        let mode: CompetitionMode
        switch visibilityControl.selectedSegmentIndex {
        case 1: mode = .friends
        case 2: mode = .global
        case 3: mode = .group
        default: mode = .privateOnly
        }

        AIService.shared.rateDifficulty(
            title: title,
            description: descField.text ?? "",
            deadline: datePicker.date,
            category: selectedCategory,
            competitionMode: mode,
            timeFrameMinutes: selectedTimeMinutes
        ) { [weak self] difficulty in
            guard let self = self else { return }
            self.aiDifficulty = difficulty
            self.aiLoadingIndicator.stopAnimating()
            self.difficultyContainer.layer.removeAllAnimations()
            UIView.animate(withDuration: 0.2) { self.difficultyContainer.alpha = 1 }
            self.difficultyLabel.text = "\(difficulty)/10"
            Theme.pop(self.difficultyLabel, scale: 1.2)
            Theme.hapticLight()

            let color = Theme.difficultyColor(for: difficulty)
            for (i, dot) in self.difficultyDotsStack.arrangedSubviews.enumerated() {
                UIView.animate(withDuration: 0.3, delay: Double(i) * 0.04, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.8, options: []) {
                    dot.backgroundColor = i < difficulty ? color : Theme.border
                    dot.transform = i < difficulty ? CGAffineTransform(scaleX: 1.2, y: 1.2) : .identity
                } completion: { _ in
                    UIView.animate(withDuration: 0.2) { dot.transform = .identity }
                }
            }
        }
    }

    @objc private func saveTapped() {
        guard let title = titleField.text, !title.isEmpty else {
            Theme.hapticError()
            let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
            animation.timingFunction = CAMediaTimingFunction(name: .linear)
            animation.duration = 0.4
            animation.values = [-8, 8, -6, 6, -3, 3, 0]
            titleField.superview?.layer.add(animation, forKey: "shake")
            return
        }

        Theme.hapticSuccess()

        UIView.animate(withDuration: 0.15) {
            self.saveButton.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        } completion: { _ in
            self.saveButton.setTitle("Added!", for: .normal)
            self.saveButton.backgroundColor = Theme.success
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: []) {
                self.saveButton.transform = .identity
            }
        }

        let modeOptions: [CompetitionMode] = [.privateOnly, .friends, .global, .group]
        let mode = modeOptions[visibilityControl.selectedSegmentIndex]
        let groupCode = mode == .group ? (groupCodeField.text ?? "") : ""

        let task = TaskItem(
            title: title,
            description: descField.text ?? "",
            deadline: datePicker.date,
            timeFrameMinutes: selectedTimeMinutes,
            difficulty: aiDifficulty,
            category: selectedCategory,
            competitionMode: mode,
            assignedGroup: groupCode
        )

        TaskStore.shared.addTask(task)
        onTaskAdded?()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.dismiss(animated: true)
        }
    }

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
}
