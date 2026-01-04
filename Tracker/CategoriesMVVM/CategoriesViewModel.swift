import Foundation

final class CategoriesViewModel {

    var onUpdate: (() -> Void)?
    var onError: ((String) -> Void)?
    var onPick: ((String) -> Void)?

    
    private let store: TrackerCategoryStore
    private(set) var selectedTitle: String?

    init(store: TrackerCategoryStore, selectedTitle: String? = nil) {
        self.store = store
        self.selectedTitle = selectedTitle

        self.store.onChange = { [weak self] in
            self?.onUpdate?()
        }
    }

    func numberOfRows() -> Int {
        store.categories().count
    }

    func title(at index: Int) -> String {
        guard index >= 0, index < store.categories().count else { return "" }
        return store.categories()[index].title ?? ""
    }

    func isSelected(at index: Int) -> Bool {
        title(at: index) == selectedTitle
    }

    func selectRow(at index: Int) {
        let title = title(at: index)
        selectedTitle = title
        onPick?(title)
        onUpdate?()
    }

    func isEmpty() -> Bool {
        store.categories().isEmpty
    }
}
