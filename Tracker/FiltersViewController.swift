import UIKit

enum TrackersFilter: Int, CaseIterable {
    case all
    case today
    case completed
    case uncompleted

    var title: String {
        switch self {
        case .all: return NSLocalizedString("Все трекеры", comment: "")
        case .today: return NSLocalizedString("Трекеры на сегодня", comment: "")
        case .completed: return NSLocalizedString("Завершённые", comment: "")
        case .uncompleted: return NSLocalizedString("Не завершённые", comment: "")
        }
    }

    var showsCheckmark: Bool {
        switch self {
        case .completed, .uncompleted: return true
        case .all, .today: return false
        }
    }
}

final class FiltersViewController: UIViewController {

    var onSelect: ((TrackersFilter) -> Void)?

    private let selectedFilter: TrackersFilter

    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isScrollEnabled = false
        return tv
    }()

    init(selectedFilter: TrackersFilter) {
        self.selectedFilter = selectedFilter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("Фильтры", comment: "")
        view.backgroundColor = .systemBackground

        tableView.dataSource = self
        tableView.delegate = self

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension FiltersViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        TrackersFilter.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)

        guard let filter = TrackersFilter(rawValue: indexPath.row) else { return cell }

        cell.textLabel?.text = filter.title
        cell.textLabel?.font = .systemFont(ofSize: 17)
        cell.selectionStyle = .default

        if filter.showsCheckmark && filter == selectedFilter {
            cell.accessoryType = .checkmark
            cell.tintColor = .systemBlue
        } else {
            cell.accessoryType = .none
        }

        return cell
    }
}

extension FiltersViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let filter = TrackersFilter(rawValue: indexPath.row) else { return }

        onSelect?(filter)
        dismiss(animated: true)
    }
}
