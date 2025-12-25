import CoreData

enum TrackerStoreError: Error {
    case fetchFailed(Error)
    case saveFailed(Error)
}

final class TrackerStore: NSObject {

    private let context: NSManagedObjectContext
    private let fetchedResultsController: NSFetchedResultsController<TrackerCoreData>

    var onChange: (() -> Void)?

    init(context: NSManagedObjectContext) {
        self.context = context

        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: true)
        ]

        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )

        super.init()

        fetchedResultsController.delegate = self

        do {
            try fetchedResultsController.performFetch()
        } catch {
            assertionFailure("TrackerStore performFetch failed: \(error)")
        }
    }

    func trackers() -> [TrackerCoreData] {
        fetchedResultsController.fetchedObjects ?? []
    }

    func addTracker(_ tracker: Tracker) throws {
        let trackerCD = TrackerCoreData(context: context)
        trackerCD.id = tracker.id
        trackerCD.name = tracker.title
        trackerCD.emoji = tracker.emoji
        trackerCD.colorHex = tracker.color.toHexString()

        do {
            try context.save()
        } catch {
            throw TrackerStoreError.saveFailed(error)
        }
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        onChange?()
    }
}
