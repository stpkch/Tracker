import UIKit

final class RootTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let trackersVC = TrackersViewController()
        let trackersNav = UINavigationController(rootViewController: trackersVC)
        trackersNav.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(systemName: "list.bullet"),
            selectedImage: UIImage(systemName: "list.bullet")
        )

        let statisticsVC = StatisticsViewController()
        let statisticsNav = UINavigationController(rootViewController: statisticsVC)
        statisticsNav.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(systemName: "chart.bar"),
            selectedImage: UIImage(systemName: "chart.bar.fill")
        )

        viewControllers = [trackersNav, statisticsNav]
    }
}
