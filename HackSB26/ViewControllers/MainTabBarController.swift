import UIKit

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self

        let tasksVC = UINavigationController(rootViewController: TaskListViewController())
        tasksVC.tabBarItem = UITabBarItem(title: "Tasks", image: UIImage(systemName: "checklist"), selectedImage: UIImage(systemName: "checklist.checked"))

        let calendarVC = UINavigationController(rootViewController: CalendarViewController())
        calendarVC.tabBarItem = UITabBarItem(title: "Calendar", image: UIImage(systemName: "calendar"), selectedImage: UIImage(systemName: "calendar.circle.fill"))

        let leaderboardVC = UINavigationController(rootViewController: CompeteViewController())
        leaderboardVC.tabBarItem = UITabBarItem(title: "Compete", image: UIImage(systemName: "trophy"), selectedImage: UIImage(systemName: "trophy.fill"))

        let profileVC = UINavigationController(rootViewController: ProfileViewController())
        profileVC.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.circle"), selectedImage: UIImage(systemName: "person.circle.fill"))

        viewControllers = [tasksVC, calendarVC, leaderboardVC, profileVC]

        // Dark tab bar with blur
        tabBar.tintColor = Theme.neon
        tabBar.unselectedItemTintColor = Theme.textMuted

        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = Theme.bgSubtle.withAlphaComponent(0.85)
        appearance.backgroundEffect = UIBlurEffect(style: .dark)

        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.selected.iconColor = Theme.neon
        itemAppearance.selected.titleTextAttributes = [.foregroundColor: Theme.neon]
        itemAppearance.normal.iconColor = Theme.textMuted
        itemAppearance.normal.titleTextAttributes = [.foregroundColor: Theme.textMuted]
        appearance.stackedLayoutAppearance = itemAppearance

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance

        // Border line on top of tab bar
        tabBar.layer.borderWidth = 0.5
        tabBar.layer.borderColor = Theme.border.cgColor

        // Nav bar styling — dark
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithTransparentBackground()
        navAppearance.backgroundColor = Theme.bg.withAlphaComponent(0.9)
        navAppearance.backgroundEffect = UIBlurEffect(style: .dark)
        navAppearance.largeTitleTextAttributes = [.foregroundColor: Theme.text]
        navAppearance.titleTextAttributes = [.foregroundColor: Theme.text]

        for vc in viewControllers ?? [] {
            if let nav = vc as? UINavigationController {
                nav.navigationBar.prefersLargeTitles = true
                nav.navigationBar.standardAppearance = navAppearance
                nav.navigationBar.scrollEdgeAppearance = navAppearance
                nav.navigationBar.compactAppearance = navAppearance
                nav.navigationBar.tintColor = Theme.neon
            }
        }
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        Theme.hapticLight()

        guard let tabBarItems = tabBar.items,
              let index = viewControllers?.firstIndex(of: viewController),
              index < tabBarItems.count else { return }

        let tabBarButtons = tabBar.subviews.filter { String(describing: type(of: $0)).contains("Button") }
        if index < tabBarButtons.count {
            let button = tabBarButtons[index]
            UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: []) {
                button.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
            } completion: { _ in
                UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.55, initialSpringVelocity: 0.4, options: []) {
                    button.transform = .identity
                }
            }
        }
    }
}
