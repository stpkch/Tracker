import UIKit

final class NewHabitViewController: UIViewController {

    var onCreateTracker: ((Tracker) -> Void)?

    private let trackerStore: TrackerStore
    private var selectedSchedule: Set<Weekday> = []

    // MARK: UI (Scroll container)

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.alwaysBounceVertical = true
        sv.keyboardDismissMode = .interactive
        return sv
    }()

    private let contentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    // MARK: UI

    private let nameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Введите название трекера"
        tf.backgroundColor = .systemGray6
        tf.layer.cornerRadius = 16
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        tf.leftViewMode = .always
        tf.clearButtonMode = .whileEditing
        return tf
    }()

    private let containerView: UIView = {
        let v = UIView()
        v.backgroundColor = .systemGray6
        v.layer.cornerRadius = 16
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let categoryCell = SettingsCell(title: "Категория")
    private let scheduleCell = SettingsCell(title: "Расписание")

    private let separatorLine: UIView = {
        let v = UIView()
        v.backgroundColor = .systemGray4
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let cancelButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Отменить", for: .normal)
        b.setTitleColor(.systemRed, for: .normal)
        b.layer.cornerRadius = 16
        b.layer.borderWidth = 1
        b.layer.borderColor = UIColor.systemRed.cgColor
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let createButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Создать", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.setTitleColor(.white, for: .disabled)
        b.backgroundColor = .systemGray
        b.layer.cornerRadius = 16
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let emojiLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Emoji"
        l.textColor = .label
        l.font = UIFont.boldSystemFont(ofSize: 19)
        return l
    }()

    private let colorLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Цвет"
        l.textColor = .label
        l.font = UIFont.boldSystemFont(ofSize: 19)
        return l
    }()

    private let emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        cv.isScrollEnabled = false
        return cv
    }()

    private let colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        cv.isScrollEnabled = false
        return cv
    }()

    private var emojiCollectionHeight: NSLayoutConstraint!
    private var colorCollectionHeight: NSLayoutConstraint!

    // MARK: Data

    private let emojis: [String] = [
        "🙂","😍","🌺","🐶","❤️","😱",
        "😇","😡","🥶","🤔","🙌","🍔",
        "🥦","🏓","🥇","🎸","🏝","😴"
    ]

    private let colors: [UIColor] = [
        UIColor(red: 0.93, green: 0.32, blue: 0.30, alpha: 1.0),
        UIColor(red: 0.96, green: 0.57, blue: 0.21, alpha: 1.0),
        UIColor(red: 0.22, green: 0.47, blue: 0.92, alpha: 1.0),
        UIColor(red: 0.38, green: 0.28, blue: 0.88, alpha: 1.0),
        UIColor(red: 0.40, green: 0.78, blue: 0.43, alpha: 1.0),
        UIColor(red: 0.85, green: 0.47, blue: 0.82, alpha: 1.0),

        UIColor(red: 0.95, green: 0.84, blue: 0.84, alpha: 1.0),
        UIColor(red: 0.33, green: 0.66, blue: 0.98, alpha: 1.0),
        UIColor(red: 0.44, green: 0.90, blue: 0.67, alpha: 1.0),
        UIColor(red: 0.20, green: 0.22, blue: 0.45, alpha: 1.0),
        UIColor(red: 0.95, green: 0.46, blue: 0.35, alpha: 1.0),
        UIColor(red: 0.98, green: 0.65, blue: 0.82, alpha: 1.0),

        UIColor(red: 0.94, green: 0.79, blue: 0.54, alpha: 1.0),
        UIColor(red: 0.48, green: 0.59, blue: 0.98, alpha: 1.0),
        UIColor(red: 0.41, green: 0.22, blue: 0.90, alpha: 1.0),
        UIColor(red: 0.60, green: 0.35, blue: 0.88, alpha: 1.0),
        UIColor(red: 0.53, green: 0.53, blue: 0.93, alpha: 1.0),
        UIColor(red: 0.35, green: 0.78, blue: 0.33, alpha: 1.0)
    ]

    private var selectedEmojiIndexPath: IndexPath?
    private var selectedColorIndexPath: IndexPath?

    // MARK: Consts

    private enum Const {
        static let emojiCellReuseID = "emojiCell"
        static let colorCellReuseID = "colorCell"
        static let itemsPerRow: CGFloat = 6
        static let spacing: CGFloat = 8
        static let cornerRadius: CGFloat = 8
    }

    // MARK: Init

    init(trackerStore: TrackerStore) {
        self.trackerStore = trackerStore
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Создание привычки"
        view.backgroundColor = .systemBackground

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        view.addSubview(cancelButton)
        view.addSubview(createButton)

        contentView.addSubview(nameTextField)
        contentView.addSubview(containerView)
        contentView.addSubview(emojiLabel)
        contentView.addSubview(emojiCollectionView)
        contentView.addSubview(colorLabel)
        contentView.addSubview(colorCollectionView)

        containerView.addSubview(categoryCell)
        containerView.addSubview(separatorLine)
        containerView.addSubview(scheduleCell)

        categoryCell.addTarget(self, action: #selector(categoryTapped), for: .touchUpInside)
        scheduleCell.addTarget(self, action: #selector(scheduleTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(createTapped), for: .touchUpInside)
        nameTextField.addTarget(self, action: #selector(nameChanged), for: .editingChanged)

        emojiCollectionView.dataSource = self
        emojiCollectionView.delegate = self
        emojiCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: Const.emojiCellReuseID)

        colorCollectionView.dataSource = self
        colorCollectionView.delegate = self
        colorCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: Const.colorCellReuseID)

        emojiCollectionHeight = emojiCollectionView.heightAnchor.constraint(equalToConstant: 1)
        colorCollectionHeight = colorCollectionView.heightAnchor.constraint(equalToConstant: 1)

        NSLayoutConstraint.activate([
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),

            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            createButton.bottomAnchor.constraint(equalTo: cancelButton.bottomAnchor),
            createButton.heightAnchor.constraint(equalToConstant: 60),

            cancelButton.trailingAnchor.constraint(equalTo: createButton.leadingAnchor, constant: -8),
            cancelButton.widthAnchor.constraint(equalTo: createButton.widthAnchor),

            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -16),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            nameTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),

            containerView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 24),
            containerView.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor),

            categoryCell.topAnchor.constraint(equalTo: containerView.topAnchor),
            categoryCell.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            categoryCell.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),

            separatorLine.topAnchor.constraint(equalTo: categoryCell.bottomAnchor),
            separatorLine.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            separatorLine.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            separatorLine.heightAnchor.constraint(equalToConstant: 1),

            scheduleCell.topAnchor.constraint(equalTo: separatorLine.bottomAnchor),
            scheduleCell.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            scheduleCell.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            scheduleCell.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),

            emojiLabel.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 24),
            emojiLabel.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),

            emojiCollectionView.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 12),
            emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            emojiCollectionHeight,

            colorLabel.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 24),
            colorLabel.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),

            colorCollectionView.topAnchor.constraint(equalTo: colorLabel.bottomAnchor, constant: 12),
            colorCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            colorCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            colorCollectionHeight,
            colorCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])

        createButton.isEnabled = false
        createButton.backgroundColor = .systemGray
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateCollectionHeights()
    }

    // MARK: Actions

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }

    @objc private func nameChanged() {
        updateCreateButtonState()
    }

    @objc private func createTapped() {
        let title = (nameTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        guard !title.isEmpty,
              let emojiIndexPath = selectedEmojiIndexPath,
              let colorIndexPath = selectedColorIndexPath
        else { return }

        let emoji = emojis[emojiIndexPath.item]
        let color = colors[colorIndexPath.item]

        let trackerModel = Tracker(
            id: UUID(),
            title: title,
            color: color,
            emoji: emoji,
            schedule: selectedSchedule
        )

        do {
            try trackerStore.addTracker(trackerModel)
        } catch {
            assertionFailure("Failed to save tracker: \(error)")
        }

        onCreateTracker?(trackerModel)
        dismiss(animated: true)
    }

    @objc private func scheduleTapped() {
        let vc = ScheduleViewController()
        vc.selectedDays = selectedSchedule
        vc.onDone = { [weak self] days in
            self?.selectedSchedule = days
        }
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func categoryTapped() {
        // По чек-листу спринта 15 переходы по кнопке "Категория" не нужны
    }

    // MARK: UI helpers

    private func updateCreateButtonState() {
        let title = (nameTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let isEnabled = !title.isEmpty
        && selectedEmojiIndexPath != nil
        && selectedColorIndexPath != nil

        createButton.isEnabled = isEnabled
        createButton.backgroundColor = isEnabled ? .black : .systemGray
    }

    private func updateCollectionHeights() {
        emojiCollectionHeight.constant = estimatedGridHeight(itemCount: emojis.count, in: emojiCollectionView)
        colorCollectionHeight.constant = estimatedGridHeight(itemCount: colors.count, in: colorCollectionView)
    }

    private func estimatedGridHeight(itemCount: Int, in collectionView: UICollectionView) -> CGFloat {
        let rows = ceil(CGFloat(itemCount) / Const.itemsPerRow)
        let side = gridItemSide(in: collectionView)
        let totalSpacing = Const.spacing * max(0, rows - 1)
        return floor(rows * side + totalSpacing)
    }

    private func gridItemSide(in collectionView: UICollectionView) -> CGFloat {
        let totalSpacing = Const.spacing * (Const.itemsPerRow - 1)
        let available = collectionView.bounds.width - totalSpacing
        return floor(available / Const.itemsPerRow)
    }
}

// MARK: - UICollectionViewDataSource

extension NewHabitViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView === emojiCollectionView { return emojis.count }
        return colors.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if collectionView === emojiCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Const.emojiCellReuseID, for: indexPath)

            let labelTag = 100
            let label: UILabel
            if let existing = cell.contentView.viewWithTag(labelTag) as? UILabel {
                label = existing
            } else {
                let newLabel = UILabel()
                newLabel.tag = labelTag
                newLabel.translatesAutoresizingMaskIntoConstraints = false
                newLabel.textAlignment = .center
                newLabel.font = UIFont.systemFont(ofSize: 32)
                cell.contentView.addSubview(newLabel)

                NSLayoutConstraint.activate([
                    newLabel.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
                    newLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
                ])
                label = newLabel
            }

            label.text = emojis[indexPath.item]
            cell.contentView.layer.cornerRadius = Const.cornerRadius
            cell.contentView.clipsToBounds = true
            cell.contentView.backgroundColor = (indexPath == selectedEmojiIndexPath) ? .systemGray5 : .clear

            return cell
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Const.colorCellReuseID, for: indexPath)
        let color = colors[indexPath.item]

        cell.contentView.layer.cornerRadius = Const.cornerRadius
        cell.contentView.clipsToBounds = true
        cell.contentView.backgroundColor = color

        if indexPath == selectedColorIndexPath {
            cell.contentView.layer.borderWidth = 3
            cell.contentView.layer.borderColor = UIColor.systemGray3.cgColor
        } else {
            cell.contentView.layer.borderWidth = 0
            cell.contentView.layer.borderColor = nil
        }

        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension NewHabitViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if collectionView === emojiCollectionView {
            let previousIndexPath = selectedEmojiIndexPath
            selectedEmojiIndexPath = indexPath
            collectionView.reloadItems(at: [previousIndexPath, indexPath].compactMap { $0 })
            updateCreateButtonState()
            return
        }

        let previousIndexPath = selectedColorIndexPath
        selectedColorIndexPath = indexPath
        collectionView.reloadItems(at: [previousIndexPath, indexPath].compactMap { $0 })
        updateCreateButtonState()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension NewHabitViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let side = gridItemSide(in: collectionView)
        return CGSize(width: side, height: side)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        Const.spacing
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        Const.spacing
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        .zero
    }
}

// MARK: - UIColor HEX

extension UIColor {
    func toHexString() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb = (Int(r * 255) << 16) |
                  (Int(g * 255) << 8) |
                  Int(b * 255)
        return String(format: "#%06X", rgb)
    }
}
