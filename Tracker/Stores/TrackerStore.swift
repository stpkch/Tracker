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
    
    func updateTracker(_ tracker: Tracker) throws {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        request.fetchLimit = 1

        do {
            let existing = try context.fetch(request).first
            let trackerCD = existing ?? TrackerCoreData(context: context)
            trackerCD.id = tracker.id
            trackerCD.name = tracker.title
            trackerCD.emoji = tracker.emoji
            trackerCD.colorHex = tracker.color.toHexString()
            try context.save()
        } catch {
            throw TrackerStoreError.saveFailed(error)
        }
    }

    func deleteTracker(with id: UUID) throws {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1

        do {
            if let tracker = try context.fetch(request).first {
                context.delete(tracker)
                try context.save()
            }
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
