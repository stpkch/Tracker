import Foundation

final class CreateCategoryViewModel {

    var onValidationChanged: ((Bool) -> Void)?
    var onCreated: ((String) -> Void)?
    var onError: ((String) -> Void)?

    private let store: TrackerCategoryStore
    private var title: String = "" {
        didSet { onValidationChanged?(isValid) }
    }

    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    init(store: TrackerCategoryStore) {
        self.store = store
    }

    func updateTitle(_ text: String) {
        title = text
    }

    func create() {
        guard isValid else { return }
        do {
            try store.addCategory(title: title)
            onCreated?(title.trimmingCharacters(in: .whitespacesAndNewlines))
        } catch {
            onError?("Не удалось сохранить категорию: \(error)")
        }
    }
}
