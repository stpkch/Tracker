import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackersSnapshotTests: XCTestCase {

    func testTrackersViewController_light() {
        let nav = makeSUT()
        assertSnapshot(of: nav, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    func testTrackersViewController_dark() {
        let nav = makeSUT()
        assertSnapshot(of: nav, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }

    private func makeSUT() -> UINavigationController {
        let context = CoreDataStack.shared.context

        let trackerStore = TrackerStore(context: context)
        let categoryStore = TrackerCategoryStore(context: context)
        let recordStore = TrackerRecordStore(context: context)

        let vc = TrackersViewController(
            trackerStore: trackerStore,
            categoryStore: categoryStore,
            recordStore: recordStore
        )

        let nav = UINavigationController(rootViewController: vc)
        nav.view.frame = CGRect(x: 0, y: 0, width: 393, height: 852)
        return nav
    }
}
