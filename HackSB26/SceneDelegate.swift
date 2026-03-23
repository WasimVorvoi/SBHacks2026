import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        window.overrideUserInterfaceStyle = .dark

        if TaskStore.shared.onboarded {
            window.rootViewController = MainTabBarController()
        } else {
            let onboarding = OnboardingViewController()
            onboarding.onComplete = { [weak window] in
                let tabBar = MainTabBarController()
                window?.rootViewController = tabBar
                UIView.transition(with: window!, duration: 0.4, options: .transitionCrossDissolve, animations: nil)
            }
            window.rootViewController = onboarding
        }

        window.makeKeyAndVisible()
        self.window = window
    }

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}
