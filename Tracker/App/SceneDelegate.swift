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

        let window = UIWindow(windowScene: windowScene)

        let root = RootTabBarController(
            trackerStore: trackerStore,
            categoryStore: categoryStore,
            recordStore: recordStore
        )

        if UserDefaults.standard.bool(forKey: Keys.didShowOnboarding) {
            window.rootViewController = root
        } else {
            let onboarding = OnboardingPageViewController(
                transitionStyle: .scroll,
                navigationOrientation: .horizontal
            )

            onboarding.onFinish = {
                UserDefaults.standard.set(true, forKey: Keys.didShowOnboarding)
                window.rootViewController = root
            }

            window.rootViewController = onboarding
        }

        self.window = window
        window.makeKeyAndVisible()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        CoreDataStack.shared.saveContext()
    }
}
