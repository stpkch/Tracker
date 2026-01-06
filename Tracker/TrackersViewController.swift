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
    
    private var currentFilter: TrackersFilter = .all

    private var baseVisibleCategories: [TrackerCategory] = []

    private let placeholderTitleLabel = UILabel()

    private lazy var filtersButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle(NSLocalizedString("Фильтры", comment: ""), for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        b.backgroundColor = .systemBlue
        b.layer.cornerRadius = 16
        b.contentEdgeInsets = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
        b.addTarget(self, action: #selector(filtersTapped), for: .touchUpInside)
        return b
    }()

    private lazy var placeholderView: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let imageView = UIImageView(image: UIImage(named: "PlaceHolder"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit

        placeholderTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        placeholderTitleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        placeholderTitleLabel.textAlignment = .center
        placeholderTitleLabel.numberOfLines = 2

        container.addSubview(imageView)
        container.addSubview(placeholderTitleLabel)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: container.topAnchor),
            imageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),

            placeholderTitleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            placeholderTitleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            placeholderTitleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
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
        setupFiltersButton()

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
        
        collectionView.alwaysBounceVertical = true
        collectionView.contentInset.bottom = 90
        collectionView.verticalScrollIndicatorInsets.bottom = 90

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupFiltersButton() {
        view.addSubview(filtersButton)

        NSLayoutConstraint.activate([
            filtersButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filtersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
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
    
    private func updateFiltersButtonVisibility() {
        filtersButton.isHidden = baseVisibleCategories.isEmpty
    }

    private func updatePlaceholderText() {
        if categories.isEmpty {
            placeholderTitleLabel.text = NSLocalizedString("trackers.placeholder.title", comment: "")
            return
        }

        if baseVisibleCategories.isEmpty || visibleCategories.isEmpty {
            placeholderTitleLabel.text = NSLocalizedString("Ничего не найдено", comment: "")
            return
        }

        placeholderTitleLabel.text = NSLocalizedString("trackers.placeholder.title", comment: "")
    }

    private func updateFiltersButtonAppearance() {
        let isActive = currentFilter == .completed || currentFilter == .uncompleted
        filtersButton.backgroundColor = isActive ? .systemRed : .systemBlue
    }


    private func applyFilters() {
        let weekday = Weekday.from(date: selectedDate, calendar: calendar)
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        let base: [TrackerCategory] = categories.compactMap { category in
            var trackersForDay = category.trackers.filter { $0.schedule.contains(weekday) }

            if !query.isEmpty {
                trackersForDay = trackersForDay.filter { $0.title.lowercased().contains(query) }
            }

            guard !trackersForDay.isEmpty else { return nil }
            return TrackerCategory(title: category.title, trackers: trackersForDay)
        }

        baseVisibleCategories = base

        let filteredByStatus: [TrackerCategory]
        switch currentFilter {
        case .completed:
            filteredByStatus = base.compactMap { category in
                let t = category.trackers.filter { isCompletedOnSelectedDate($0) }
                return t.isEmpty ? nil : TrackerCategory(title: category.title, trackers: t)
            }
        case .uncompleted:
            filteredByStatus = base.compactMap { category in
                let t = category.trackers.filter { !isCompletedOnSelectedDate($0) }
                return t.isEmpty ? nil : TrackerCategory(title: category.title, trackers: t)
            }
        case .all, .today:
            filteredByStatus = base
        }

        visibleCategories = filteredByStatus

        updateFiltersButtonVisibility()
        updatePlaceholderText()
        updateFiltersButtonAppearance()
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

extension TrackersViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]

        return UIContextMenuConfiguration(identifier: tracker.id as NSUUID, previewProvider: nil) { [weak self] _ in
            guard let self else { return UIMenu(title: "", children: []) }

            let edit = UIAction(title: NSLocalizedString("Редактировать", comment: "")) { [weak self] _ in
                self?.presentEdit(tracker: tracker)
            }

            let delete = UIAction(title: NSLocalizedString("Удалить", comment: ""), attributes: [.destructive]) { [weak self] _ in
                self?.confirmDelete(tracker: tracker)
            }

            return UIMenu(title: "", children: [edit, delete])
        }
    }

    private func presentEdit(tracker: Tracker) {
        let vc = NewHabitViewController(trackerStore: trackerStore, trackerToEdit: tracker)
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }

    private func confirmDelete(tracker: Tracker) {
        let alert = UIAlertController(
            title: NSLocalizedString("Удалить трекер?", comment: ""),
            message: nil,
            preferredStyle: .actionSheet
        )

        alert.addAction(UIAlertAction(title: NSLocalizedString("Удалить", comment: ""), style: .destructive) { [weak self] _ in
            guard let self else { return }
            do {
                try self.trackerStore.deleteTracker(with: tracker.id)
            } catch {
                let errAlert = UIAlertController(
                    title: NSLocalizedString("alert.error_title", comment: ""),
                    message: error.localizedDescription,
                    preferredStyle: .alert
                )
                errAlert.addAction(UIAlertAction(title: NSLocalizedString("common.ok", comment: ""), style: .default))
                self.present(errAlert, animated: true)
            }
        })

        alert.addAction(UIAlertAction(title: NSLocalizedString("Отмена", comment: ""), style: .cancel))

        if let popover = alert.popoverPresentationController,
           let indexPath = visibleCategories.firstIndex(where: { $0.trackers.contains(where: { $0.id == tracker.id }) }) {
            popover.sourceView = collectionView
            popover.sourceRect = collectionView.layoutAttributesForItem(at: IndexPath(item: 0, section: indexPath))?.frame ?? collectionView.bounds
        }

        present(alert, animated: true)
    }
    
    @objc private func filtersTapped() {
        let vc = FiltersViewController(selectedFilter: currentFilter)
        vc.onSelect = { [weak self] filter in
            guard let self else { return }
            self.applySelectedFilter(filter)
        }

        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .pageSheet
        present(nav, animated: true)
    }

    private func applySelectedFilter(_ filter: TrackersFilter) {
        switch filter {
        case .today:
            let today = calendar.startOfDay(for: Date())
            selectedDate = today
            datePicker.setDate(today, animated: true)
            currentFilter = .all
        case .all:
            currentFilter = .all
        case .completed, .uncompleted:
            currentFilter = filter
        }
        applyFilters()
    }

}

