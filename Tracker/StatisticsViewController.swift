import UIKit

final class StatisticsViewController: UIViewController {

    private let recordStore: TrackerRecordStore

    private let emptyContainer = UIView()
    private let emptyImageView = UIImageView()
    private let emptyLabel = UILabel()

    private let contentScrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let completedCard = StatCardView(title: NSLocalizedString("Трекеров завершено", comment: ""))

    init(recordStore: TrackerRecordStore) {
        self.recordStore = recordStore
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        title = NSLocalizedString("Статистика", comment: "")
        navigationController?.navigationBar.prefersLargeTitles = true

        setupEmptyState()
        setupContent()

        recordStore.onChange = { [weak self] in
            self?.updateUI()
        }

        updateUI()
    }

    private func setupEmptyState() {
        emptyContainer.translatesAutoresizingMaskIntoConstraints = false
        emptyImageView.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false

        emptyImageView.image = UIImage(named: "sadSmile")
        emptyImageView.contentMode = .scaleAspectFit

        emptyLabel.text = NSLocalizedString("Анализировать пока нечего", comment: "")
        emptyLabel.textAlignment = .center
        emptyLabel.font = .systemFont(ofSize: 12, weight: .medium)
        emptyLabel.textColor = .secondaryLabel

        view.addSubview(emptyContainer)
        emptyContainer.addSubview(emptyImageView)
        emptyContainer.addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            emptyContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            emptyImageView.centerXAnchor.constraint(equalTo: emptyContainer.centerXAnchor),
            emptyImageView.topAnchor.constraint(equalTo: emptyContainer.topAnchor),
            emptyImageView.widthAnchor.constraint(equalToConstant: 80),
            emptyImageView.heightAnchor.constraint(equalToConstant: 80),

            emptyLabel.topAnchor.constraint(equalTo: emptyImageView.bottomAnchor, constant: 8),
            emptyLabel.leadingAnchor.constraint(equalTo: emptyContainer.leadingAnchor),
            emptyLabel.trailingAnchor.constraint(equalTo: emptyContainer.trailingAnchor),
            emptyLabel.bottomAnchor.constraint(equalTo: emptyContainer.bottomAnchor)
        ])
    }

    private func setupContent() {
        contentScrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        contentStack.axis = .vertical
        contentStack.spacing = 12
        contentStack.alignment = .fill
        contentStack.distribution = .fill

        view.addSubview(contentScrollView)
        contentScrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            contentScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            contentScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: contentScrollView.contentLayoutGuide.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: contentScrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: contentScrollView.frameLayoutGuide.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: contentScrollView.contentLayoutGuide.bottomAnchor),
        ])

        contentStack.addArrangedSubview(completedCard)
    }

    private func updateUI() {
        let completed = recordStore.totalCompletedCount()

        if completed == 0 {
            emptyContainer.isHidden = false
            contentScrollView.isHidden = true
            return
        }

        emptyContainer.isHidden = true
        contentScrollView.isHidden = false
        completedCard.setValue(completed)
    }
}

final class StatCardView: UIView {

    private let valueLabel = UILabel()
    private let titleLabel = UILabel()

    init(title: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        layer.cornerRadius = 16
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemGray4.cgColor

        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        valueLabel.font = .systemFont(ofSize: 34, weight: .bold)
        valueLabel.textColor = .label

        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = .secondaryLabel
        titleLabel.text = title

        addSubview(valueLabel)
        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 90),

            valueLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            valueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            valueLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -12),

            titleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 4),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -12)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setValue(_ value: Int) {
        valueLabel.text = "\(value)"
    }
}
