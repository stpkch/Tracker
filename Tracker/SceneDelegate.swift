import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    // Core Data
    private lazy var context = CoreDataStack.shared.context

    // Stores
    private lazy var trackerStore = TrackerStore(context: context)
    private lazy var categoryStore = TrackerCategoryStore(context: context)
    private lazy var recordStore = TrackerRecordStore(context: context)

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)

        window.rootViewController = RootTabBarController(
            trackerStore: trackerStore,
            categoryStore: categoryStore,
            recordStore: recordStore
        )

        self.window = window
        window.makeKeyAndVisible()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        CoreDataStack.shared.saveContext()
    }
}
