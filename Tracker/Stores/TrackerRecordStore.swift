import CoreData

enum TrackerRecordStoreError: Error {
    case fetchFailed(Error)
    case saveFailed(Error)
}

final class TrackerRecordStore: NSObject {

    private let context: NSManagedObjectContext
    private let fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData>

    var onChange: (() -> Void)?

    init(context: NSManagedObjectContext) {
        self.context = context

        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "date", ascending: true)
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
            assertionFailure("TrackerRecordStore performFetch failed: \(error)")
        }
    }

    func records() -> [TrackerRecordCoreData] {
        fetchedResultsController.fetchedObjects ?? []
    }

    func isCompleted(trackerId: UUID, on date: Date, calendar: Calendar = .current) -> Bool {
        let day = calendar.startOfDay(for: date)
        return records().contains { record in
            guard let recordDate = record.date else { return false }
            guard let trackerIdInRecord = record.tracker?.id else { return false }
            return trackerIdInRecord == trackerId && calendar.isDate(recordDate, inSameDayAs: day)
        }
    }

    func completedCount(trackerId: UUID) -> Int {
        records().filter { $0.tracker?.id == trackerId }.count
    }

    func totalCompletedCount() -> Int {
        records().count
    }

    func addRecord(trackerId: UUID, date: Date, calendar: Calendar = .current) throws {
        let day = calendar.startOfDay(for: date)
        guard !isCompleted(trackerId: trackerId, on: day, calendar: calendar) else { return }

        let trackerRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        trackerRequest.predicate = NSPredicate(format: "id == %@", trackerId as CVarArg)
        trackerRequest.fetchLimit = 1

        do {
            guard let trackerCD = try context.fetch(trackerRequest).first else { return }

            let record = TrackerRecordCoreData(context: context)
            record.id = UUID()
            record.date = day
            record.tracker = trackerCD

            try context.save()
        } catch {
            throw TrackerRecordStoreError.saveFailed(error)
        }
    }

    func deleteRecord(trackerId: UUID, date: Date, calendar: Calendar = .current) throws {
        let day = calendar.startOfDay(for: date)

        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "tracker.id == %@ AND date == %@", trackerId as CVarArg, day as CVarArg)

        do {
            let results = try context.fetch(request)
            results.forEach { context.delete($0) }
            try context.save()
        } catch {
            throw TrackerRecordStoreError.fetchFailed(error)
        }
    }
}

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        onChange?()
    }
}
