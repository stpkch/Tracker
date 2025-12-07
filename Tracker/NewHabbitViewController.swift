import UIKit

final class SettingsCell: UIControl {

    private let titleLabel = UILabel()
    private let arrowImageView = UIImageView(image: UIImage(systemName: "chevron.right"))

    init(title: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 17)
        arrowImageView.tintColor = .systemGray
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(titleLabel)
        addSubview(arrowImageView)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 60),

            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            arrowImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            arrowImageView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }
}

final class NewHabitViewController: UIViewController {

    var onCreateTracker: ((Tracker) -> Void)?
    private var selectedSchedule: Set<Weekday> = []

    private let nameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Введите название трекера"
        tf.backgroundColor = UIColor.systemGray6
        tf.layer.cornerRadius = 16
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        tf.leftViewMode = .always
        return tf
    }()

    private let containerView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.systemGray6
        v.layer.cornerRadius = 16
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let categoryCell = SettingsCell(title: "Категория")
    private let scheduleCell = SettingsCell(title: "Расписание")

    private let separatorLine: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.systemGray4
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
        b.backgroundColor = .systemGray
        b.layer.cornerRadius = 16
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Новая привычка"
        view.backgroundColor = .systemBackground

        view.addSubview(nameTextField)
        view.addSubview(containerView)
        view.addSubview(cancelButton)
        view.addSubview(createButton)

        containerView.addSubview(categoryCell)
        containerView.addSubview(separatorLine)
        containerView.addSubview(scheduleCell)

        categoryCell.addTarget(self, action: #selector(categoryTapped), for: .touchUpInside)
        scheduleCell.addTarget(self, action: #selector(scheduleTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(createTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            nameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
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

            cancelButton.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),

            createButton.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor),
            createButton.bottomAnchor.constraint(equalTo: cancelButton.bottomAnchor),
            createButton.heightAnchor.constraint(equalToConstant: 60),

            cancelButton.trailingAnchor.constraint(equalTo: createButton.leadingAnchor, constant: -8),
            cancelButton.widthAnchor.constraint(equalTo: createButton.widthAnchor)
        ])
    }

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }

    @objc private func createTapped() {
        guard let title = nameTextField.text, !title.isEmpty else { return }

        let tracker = Tracker(
            id: UUID(),
            title: title,
            color: .systemBlue,
            emoji: "⭐️",
            schedule: selectedSchedule
        )

        onCreateTracker?(tracker)
        dismiss(animated: true)
    }

    @objc private func scheduleTapped() {
        let vc = ScheduleViewController()
        vc.selectedDays = selectedSchedule
        vc.onDone = { [weak self] days in self?.selectedSchedule = days }
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func categoryTapped() {}
}
