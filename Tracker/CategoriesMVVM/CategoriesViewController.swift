import UIKit

final class CategoriesViewController: UIViewController {

    var onPickCategory: ((String) -> Void)?

    private let viewModel: CategoriesViewModel

    private let tableView = UITableView(frame: .zero, style: .plain)

    private let emptyStateLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Привычки и события можно\nобъединить по смыслу"
        l.textAlignment = .center
        l.textColor = .secondaryLabel
        l.numberOfLines = 0
        return l
    }()

    private let addButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("Добавить категорию", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.backgroundColor = .black
        b.layer.cornerRadius = 16
        return b
    }()

    init(viewModel: CategoriesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Категория"
        view.backgroundColor = .systemBackground

        setupTable()
        layoutUI()
        bindViewModel()

        refreshEmptyState()
    }

    private func setupTable() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
    }

    private func layoutUI() {
        view.addSubview(tableView)
        view.addSubview(emptyStateLabel)
        view.addSubview(addButton)

        addButton.addTarget(self, action: #selector(addCategoryTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addButton.heightAnchor.constraint(equalToConstant: 60),

            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -8),

            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 16),
            emptyStateLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -16)
        ])
    }

    private func bindViewModel() {
        viewModel.onUpdate = { [weak self] in
            guard let self else { return }
            self.tableView.reloadData()
            self.refreshEmptyState()
        }

        viewModel.onPick = { [weak self] title in
            self?.onPickCategory?(title)
            self?.navigationController?.popViewController(animated: true)
        }

        viewModel.onError = { [weak self] message in
            let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ок", style: .default))
            self?.present(alert, animated: true)
        }
    }

    private func refreshEmptyState() {
        let isEmpty = viewModel.isEmpty()
        emptyStateLabel.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }

    @objc private func addCategoryTapped() {
        let createVM = CreateCategoryViewModel(store: TrackerCategoryStore(context: CoreDataStack.shared.context))
        let vc = CreateCategoryViewController(viewModel: createVM)
        vc.onCreated = { [weak self] _ in
            self?.refreshEmptyState()
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension CategoriesViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRows()
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let id = "CategoryCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: id)
            ?? UITableViewCell(style: .default, reuseIdentifier: id)

        cell.textLabel?.text = viewModel.title(at: indexPath.row)
        cell.accessoryType = viewModel.isSelected(at: indexPath.row) ? .checkmark : .none
        cell.selectionStyle = .default

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.selectRow(at: indexPath.row)
    }
}
