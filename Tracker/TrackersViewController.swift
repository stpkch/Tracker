import UIKit

final class TrackersViewController: UIViewController {

    private let calendar = Calendar.current

    private let trackerStore: TrackerStore
    private let categoryStore: TrackerCategoryStore
    private let recordStore: TrackerRecordStore

    private var selectedDate: Date = Calendar.current.startOfDay(for: Date())
    private var searchText: String = ""

    private let searchController = UISearchController(searchResultsController: nil)

    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.maximumDate = Date()
        picker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        picker.date = selectedDate
        return picker
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 9
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.reuseIdentifier)
        return collectionView
    }()

    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []

    private var visibleCategories: [TrackerCategory] = [] {
        didSet {
            updateIsEmptyState()
            collectionView.reloadData()
        }
    }

    private var isEmpty: Bool = true {
        didSet {
            updatePlaceholderVisibility()
        }
    }

    private let placeholderView: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let imageView = UIImageView(image: UIImage(named: "PlaceHolder"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = NSLocalizedString("trackers.placeholder.title", comment: "")
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textAlignment = .center

        container.addSubview(imageView)
        container.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: container.topAnchor),
            imageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),

            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
        ])

        return container
    }()

    init(trackerStore: TrackerStore,
         categoryStore: TrackerCategoryStore,
         recordStore: TrackerRecordStore) {
        self.trackerStore = trackerStore
        self.categoryStore = categoryStore
        self.recordStore = recordStore
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        setupNavigationBar()
        setupCollectionView()
        setupPlaceholder()

        trackerStore.onChange = { [weak self] in
            self?.reloadFromCoreData()
        }

        reloadFromCoreData()
        updatePlaceholderVisibility()
    }

    private func reloadFromCoreData() {
        let trackersCD = trackerStore.trackers()
        let trackers = trackersCD.map(mapTracker)

        let categoryTitle = NSLocalizedString("trackers.category.habits", comment: "")
        categories = trackers.isEmpty ? [] : [TrackerCategory(title: categoryTitle, trackers: trackers)]

        applyFilters()
    }

    private func mapTracker(_ cd: TrackerCoreData) -> Tracker {
        let id = cd.id ?? UUID()
        let title = cd.name ?? ""
        let emoji = cd.emoji ?? "🙂"
        let color = UIColor(hex: cd.colorHex ?? "#000000") ?? .black
        let schedule = Set(Weekday.allCases)
        return Tracker(id: id, title: title, color: color, emoji: emoji, schedule: schedule)
    }

    private func setupNavigationBar() {
        title = NSLocalizedString("trackers.title", comment: "")

        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addTrackerTapped)
        )
        navigationItem.leftBarButtonItem = addButton

        let datePickerItem = UIBarButtonItem(customView: datePicker)
        navigationItem.rightBarButtonItem = datePickerItem

        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = NSLocalizedString("trackers.search.placeholder", comment: "")
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }

    private func setupCollectionView() {
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupPlaceholder() {
        view.addSubview(placeholderView)

        NSLayoutConstraint.activate([
            placeholderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 16),
            placeholderView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -16)
        ])
    }

    private func updatePlaceholderVisibility() {
        placeholderView.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
    }

    private func updateIsEmptyState() {
        isEmpty = visibleCategories.isEmpty
    }

    private func applyFilters() {
        let weekday = Weekday.from(date: selectedDate, calendar: calendar)
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        let filtered: [TrackerCategory] = categories.compactMap { category in
            var trackersForDay = category.trackers.filter { $0.schedule.contains(weekday) }

            if !query.isEmpty {
                trackersForDay = trackersForDay.filter { $0.title.lowercased().contains(query) }
            }

            guard !trackersForDay.isEmpty else { return nil }
            return TrackerCategory(title: category.title, trackers: trackersForDay)
        }

        visibleCategories = filtered
    }

    private func toggleTracker(_ tracker: Tracker, on date: Date) {
        let day = calendar.startOfDay(for: date)
        let today = calendar.startOfDay(for: Date())

        guard day <= today else { return }

        if let index = completedTrackers.firstIndex(where: { record in
            record.trackerId == tracker.id &&
            calendar.isDate(record.date, inSameDayAs: day)
        }) {
            completedTrackers.remove(at: index)
        } else {
            let record = TrackerRecord(trackerId: tracker.id, date: day)
            completedTrackers.append(record)
        }
    }

    private func isCompletedOnSelectedDate(_ tracker: Tracker) -> Bool {
        completedTrackers.contains { record in
            record.trackerId == tracker.id &&
            calendar.isDate(record.date, inSameDayAs: selectedDate)
        }
    }

    private func completedCount(for tracker: Tracker) -> Int {
        completedTrackers.filter { $0.trackerId == tracker.id }.count
    }

    @objc private func addTrackerTapped() {
        let newHabitVC = NewHabitViewController(trackerStore: trackerStore)
        newHabitVC.onCreateTracker = { _ in }
        let nav = UINavigationController(rootViewController: newHabitVC)
        present(nav, animated: true)
    }

    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        selectedDate = calendar.startOfDay(for: sender.date)
        applyFilters()
    }
}

extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        searchText = searchController.searchBar.text ?? ""
        applyFilters()
    }
}

extension TrackersViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        visibleCategories.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        visibleCategories[section].trackers.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCell.reuseIdentifier,
            for: indexPath
        ) as? TrackerCell else {
            return UICollectionViewCell()
        }

        let category = visibleCategories[indexPath.section]
        let tracker = category.trackers[indexPath.item]

        let isCompleted = isCompletedOnSelectedDate(tracker)
        let count = completedCount(for: tracker)

        cell.configure(with: tracker,
                       isCompletedOnSelectedDate: isCompleted,
                       completedCount: count)
        cell.delegate = self

        return cell
    }
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 16 * 2 + 9
        let availableWidth = collectionView.bounds.width - padding
        let width = availableWidth / 2
        return CGSize(width: width, height: 140)
    }
}

extension TrackersViewController: TrackerCellDelegate {
    func trackerCellDidTapToggle(_ cell: TrackerCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }

        let category = visibleCategories[indexPath.section]
        let tracker = category.trackers[indexPath.item]

        toggleTracker(tracker, on: selectedDate)
        collectionView.reloadItems(at: [indexPath])
    }
}
