import UIKit

class CompeteViewController: UIViewController {

    private let segmentControl = UISegmentedControl(items: ["Leaderboard", "Friends", "Groups", "Challenges"])
    private let containerView = UIView()
    private var currentChild: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Compete"
        view.backgroundColor = Theme.bg
        navigationItem.largeTitleDisplayMode = .always
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Always reload the current tab so Firebase data is fresh
        showTab(segmentControl.selectedSegmentIndex)
    }

    private func setupUI() {
        segmentControl.selectedSegmentIndex = 0
        segmentControl.selectedSegmentTintColor = Theme.accent
        segmentControl.setTitleTextAttributes([.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 11, weight: .semibold)], for: .selected)
        segmentControl.setTitleTextAttributes([.foregroundColor: Theme.textDim, .font: UIFont.systemFont(ofSize: 11, weight: .medium)], for: .normal)
        segmentControl.backgroundColor = Theme.card
        segmentControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(segmentControl)

        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)

        NSLayoutConstraint.activate([
            segmentControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            segmentControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            segmentControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),

            containerView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    @objc private func segmentChanged() {
        Theme.hapticLight()
        showTab(segmentControl.selectedSegmentIndex)
    }

    private func showTab(_ index: Int) {
        // Remove old child
        if let child = currentChild {
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
            currentChild = nil
        }

        let vc: UIViewController
        switch index {
        case 0: vc = LeaderboardViewController()
        case 1: vc = FriendsViewController()
        case 2: vc = GroupsViewController()
        case 3: vc = ChallengesViewController()
        default: return
        }

        addChild(vc)
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(vc.view)
        NSLayoutConstraint.activate([
            vc.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            vc.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            vc.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            vc.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        vc.didMove(toParent: self)
        currentChild = vc
    }
}
