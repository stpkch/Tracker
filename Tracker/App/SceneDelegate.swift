import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    private lazy var context = CoreDataStack.shared.context
    private lazy var trackerStore = TrackerStore(context: context)
    private lazy var categoryStore = TrackerCategoryStore(context: context)
    private lazy var recordStore = TrackerRecordStore(context: context)

    private enum Keys {
        static let didShowOnboarding = "didShowOnboarding"
    }

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = makeWindow(for: windowScene)
        let root = makeRootController()

        window.rootViewController = makeInitialController(root: root, window: window)

        self.window = window
        window.makeKeyAndVisible()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        CoreDataStack.shared.saveContext()
    }
}

// MARK: - Window

private extension SceneDelegate {

    func makeWindow(for windowScene: UIWindowScene) -> UIWindow {
        UIWindow(windowScene: windowScene)
    }
}

// MARK: - Root

private extension SceneDelegate {

    func makeRootController() -> UIViewController {
        RootTabBarController(
            trackerStore: trackerStore,
            categoryStore: categoryStore,
            recordStore: recordStore
        )
    }
}

// MARK: - Onboarding

private extension SceneDelegate {

    func makeInitialController(root: UIViewController, window: UIWindow) -> UIViewController {
        shouldShowOnboarding ? makeOnboardingController(root: root, window: window) : root
    }

    var shouldShowOnboarding: Bool {
        !UserDefaults.standard.bool(forKey: Keys.didShowOnboarding)
    }

    func makeOnboardingController(root: UIViewController, window: UIWindow) -> UIViewController {
        let onboarding = OnboardingPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal
        )

        onboarding.onFinish = { [weak window] in
            UserDefaults.standard.set(true, forKey: Keys.didShowOnboarding)
            window?.rootViewController = root
        }

        return onboarding
    }
}
