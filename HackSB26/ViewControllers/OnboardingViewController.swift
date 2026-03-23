import UIKit

class OnboardingViewController: UIViewController {

    var onComplete: (() -> Void)?
    private var step = 0
    private let container = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.bg
        container.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(container)
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            container.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        showStep(0)
    }

    private func showStep(_ step: Int) {
        self.step = step
        container.subviews.forEach { $0.removeFromSuperview() }

        switch step {
        case 0: buildWelcome()
        case 1: buildFeatures()
        case 2: buildProfileSetup()
        default: finish()
        }
    }

    // MARK: - Step 0: Welcome

    private func buildWelcome() {
        let logo = UILabel()
        logo.text = "CLUTCH"
        logo.font = .rounded(ofSize: 48, weight: .heavy)
        logo.textColor = Theme.neon
        logo.textAlignment = .center
        logo.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(logo)

        let tagline = UILabel()
        tagline.text = "Grind To Game"
        tagline.font = .systemFont(ofSize: 18, weight: .semibold)
        tagline.textColor = Theme.textDim
        tagline.textAlignment = .center
        tagline.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(tagline)

        let bolt = UILabel()
        bolt.text = "⚡"
        bolt.font = .systemFont(ofSize: 80)
        bolt.textAlignment = .center
        bolt.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(bolt)

        let nextBtn = makeNextButton(title: "Get Started")
        container.addSubview(nextBtn)

        NSLayoutConstraint.activate([
            bolt.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            bolt.centerYAnchor.constraint(equalTo: container.centerYAnchor, constant: -80),

            logo.topAnchor.constraint(equalTo: bolt.bottomAnchor, constant: 16),
            logo.centerXAnchor.constraint(equalTo: container.centerXAnchor),

            tagline.topAnchor.constraint(equalTo: logo.bottomAnchor, constant: 8),
            tagline.centerXAnchor.constraint(equalTo: container.centerXAnchor),

            nextBtn.bottomAnchor.constraint(equalTo: container.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            nextBtn.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            nextBtn.widthAnchor.constraint(equalToConstant: 260),
            nextBtn.heightAnchor.constraint(equalToConstant: 56)
        ])

        logo.alpha = 0; tagline.alpha = 0; bolt.alpha = 0
        UIView.animate(withDuration: 0.6, delay: 0.1) { bolt.alpha = 1 }
        UIView.animate(withDuration: 0.6, delay: 0.3) { logo.alpha = 1 }
        UIView.animate(withDuration: 0.6, delay: 0.5) { tagline.alpha = 1 }
    }

    // MARK: - Step 1: Features

    private func buildFeatures() {
        let titleLabel = UILabel()
        titleLabel.text = "How It Works"
        titleLabel.font = .rounded(ofSize: 28, weight: .bold)
        titleLabel.textColor = Theme.text
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(titleLabel)

        let features: [(String, String)] = [
            ("checkmark.circle.fill", "Add tasks with deadlines"),
            ("brain.head.profile", "AI rates difficulty (1-10)"),
            ("star.fill", "Earn points — harder = bigger rewards"),
            ("trophy.fill", "Compete & climb leaderboards"),
            ("person.3.fill", "Challenge friends & groups")
        ]

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(stack)

        for (i, (icon, text)) in features.enumerated() {
            let row = UIStackView()
            row.axis = .horizontal
            row.spacing = 14
            row.alignment = .center

            let circle = UIView()
            circle.backgroundColor = Theme.accentDim
            circle.layer.cornerRadius = 22
            circle.translatesAutoresizingMaskIntoConstraints = false
            circle.widthAnchor.constraint(equalToConstant: 44).isActive = true
            circle.heightAnchor.constraint(equalToConstant: 44).isActive = true

            let iconView = UIImageView(image: UIImage(systemName: icon))
            iconView.tintColor = Theme.accent
            iconView.contentMode = .scaleAspectFit
            iconView.translatesAutoresizingMaskIntoConstraints = false
            circle.addSubview(iconView)
            NSLayoutConstraint.activate([
                iconView.centerXAnchor.constraint(equalTo: circle.centerXAnchor),
                iconView.centerYAnchor.constraint(equalTo: circle.centerYAnchor),
                iconView.widthAnchor.constraint(equalToConstant: 22),
                iconView.heightAnchor.constraint(equalToConstant: 22)
            ])

            let label = UILabel()
            label.text = text
            label.font = .systemFont(ofSize: 16, weight: .medium)
            label.textColor = Theme.text
            label.numberOfLines = 0

            row.addArrangedSubview(circle)
            row.addArrangedSubview(label)
            stack.addArrangedSubview(row)

            row.alpha = 0
            UIView.animate(withDuration: 0.4, delay: 0.1 + Double(i) * 0.1) { row.alpha = 1 }
        }

        let nextBtn = makeNextButton(title: "Next")
        container.addSubview(nextBtn)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),

            stack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 32),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -32),

            nextBtn.bottomAnchor.constraint(equalTo: container.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            nextBtn.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            nextBtn.widthAnchor.constraint(equalToConstant: 260),
            nextBtn.heightAnchor.constraint(equalToConstant: 56)
        ])
    }

    // MARK: - Step 2: Profile Setup

    private var selectedEmoji = "⚡"
    private var nameTextField: UITextField!

    private func buildProfileSetup() {
        let titleLabel = UILabel()
        titleLabel.text = "Create Your Profile"
        titleLabel.font = .rounded(ofSize: 28, weight: .bold)
        titleLabel.textColor = Theme.text
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(titleLabel)

        let subtitleLabel = UILabel()
        subtitleLabel.text = "Pick your avatar"
        subtitleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        subtitleLabel.textColor = Theme.textDim
        subtitleLabel.textAlignment = .center
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(subtitleLabel)

        // Emoji grid (4x3)
        let emojiGrid = UIStackView()
        emojiGrid.axis = .vertical
        emojiGrid.spacing = 10
        emojiGrid.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(emojiGrid)

        let avatars = UserProfile.avatarOptions
        for row in 0..<3 {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 10
            rowStack.distribution = .fillEqually
            for col in 0..<4 {
                let idx = row * 4 + col
                guard idx < avatars.count else { continue }
                let btn = UIButton(type: .custom)
                btn.setTitle(avatars[idx], for: .normal)
                btn.titleLabel?.font = .systemFont(ofSize: 28)
                btn.backgroundColor = avatars[idx] == selectedEmoji ? Theme.accentDim : Theme.card
                btn.layer.cornerRadius = 12
                btn.layer.borderWidth = avatars[idx] == selectedEmoji ? 2 : 1
                btn.layer.borderColor = avatars[idx] == selectedEmoji ? Theme.accent.cgColor : Theme.border.cgColor
                btn.tag = idx
                btn.addTarget(self, action: #selector(emojiTapped(_:)), for: .touchUpInside)
                btn.heightAnchor.constraint(equalToConstant: 52).isActive = true
                rowStack.addArrangedSubview(btn)
            }
            emojiGrid.addArrangedSubview(rowStack)
        }

        // Name field
        let nameLabel = UILabel()
        nameLabel.text = "Your Name"
        nameLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        nameLabel.textColor = Theme.textDim
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(nameLabel)

        nameTextField = UITextField()
        nameTextField.placeholder = "Enter your name"
        nameTextField.font = .systemFont(ofSize: 18, weight: .semibold)
        nameTextField.textColor = Theme.text
        nameTextField.backgroundColor = Theme.card
        nameTextField.layer.cornerRadius = 12
        nameTextField.layer.borderWidth = 1
        nameTextField.layer.borderColor = Theme.border.cgColor
        nameTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        nameTextField.leftViewMode = .always
        nameTextField.attributedPlaceholder = NSAttributedString(string: "Enter your name", attributes: [.foregroundColor: Theme.textMuted])
        nameTextField.returnKeyType = .done
        nameTextField.addTarget(self, action: #selector(nameFieldReturn), for: .editingDidEndOnExit)
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(nameTextField)

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        container.addGestureRecognizer(tap)

        let startBtn = makeNextButton(title: "Let's Go!")
        startBtn.removeTarget(self, action: #selector(nextStep), for: .touchUpInside)
        startBtn.addTarget(self, action: #selector(finishOnboarding), for: .touchUpInside)
        container.addSubview(startBtn)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),

            emojiGrid.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 24),
            emojiGrid.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 32),
            emojiGrid.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -32),

            nameLabel.topAnchor.constraint(equalTo: emojiGrid.bottomAnchor, constant: 28),
            nameLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 32),

            nameTextField.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            nameTextField.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 32),
            nameTextField.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -32),
            nameTextField.heightAnchor.constraint(equalToConstant: 50),

            startBtn.bottomAnchor.constraint(equalTo: container.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            startBtn.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            startBtn.widthAnchor.constraint(equalToConstant: 260),
            startBtn.heightAnchor.constraint(equalToConstant: 56)
        ])
    }

    @objc private func emojiTapped(_ sender: UIButton) {
        Theme.hapticLight()
        let avatars = UserProfile.avatarOptions
        guard sender.tag < avatars.count else { return }
        selectedEmoji = avatars[sender.tag]

        // Update all emoji buttons
        func findEmojiButtons(in view: UIView) {
            for sub in view.subviews {
                if let btn = sub as? UIButton, btn.tag < avatars.count, btn.currentTitle != nil, avatars.contains(btn.currentTitle!) {
                    let isSelected = btn.currentTitle == selectedEmoji
                    btn.backgroundColor = isSelected ? Theme.accentDim : Theme.card
                    btn.layer.borderWidth = isSelected ? 2 : 1
                    btn.layer.borderColor = isSelected ? Theme.accent.cgColor : Theme.border.cgColor
                    if isSelected { Theme.pop(btn, scale: 1.1) }
                }
                findEmojiButtons(in: sub)
            }
        }
        findEmojiButtons(in: container)
    }

    @objc private func nameFieldReturn() {
        nameTextField.resignFirstResponder()
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func finishOnboarding() {
        let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !name.isEmpty else {
            nameTextField.layer.borderColor = Theme.danger.cgColor
            Theme.hapticError()
            return
        }
        Theme.hapticSuccess()
        TaskStore.shared.profile = UserProfile(name: name, emoji: selectedEmoji)
        TaskStore.shared.onboarded = true
        finish()
    }

    private func finish() {
        onComplete?()
    }

    // MARK: - Helpers

    private func makeNextButton(title: String) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle(title, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        btn.setTitleColor(.black, for: .normal)
        btn.backgroundColor = Theme.neon
        btn.layer.cornerRadius = 28
        btn.translatesAutoresizingMaskIntoConstraints = false
        Theme.addButtonEffect(to: btn)
        btn.addTarget(self, action: #selector(nextStep), for: .touchUpInside)
        return btn
    }

    @objc private func nextStep() {
        Theme.hapticLight()
        UIView.transition(with: container, duration: 0.3, options: .transitionCrossDissolve) {
            self.showStep(self.step + 1)
        }
    }
}
