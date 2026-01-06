import UIKit

final class CategoriesViewController: UIViewController {

    var onPickCategory: ((String) -> Void)?

    private let viewModel: CategoriesViewModel
    private let tableView = UITableView(frame: .zero, style: .plain)

    private let emptyStateLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = NSLocalizedString("categories.empty", comment: "")
        l.textAlignment = .center
        l.textColor = .secondaryLabel
        l.numberOfLines = 0
        return l
    }()

    private let addButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle(NSLocalizedString("categories.add", comment: ""), for: .normal)
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
        configureUI()
        configureTableView()
        configureLayout()
        configureActions()
        configureBindings()
        updateUI()
    }
}

private extension CategoriesViewController {

    func configureUI() {
        title = NSLocalizedString("categories.title", comment: "")
        view.backgroundColor = .systemBackground
    }

    func configureTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.reuseId)
    }

    func configureLayout() {
        view.addSubview(tableView)
        view.addSubview(emptyStateLabel)
        view.addSubview(addButton)

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

    func configureActions() {
        addButton.addTarget(self, action: #selector(addCategoryTapped), for: .touchUpInside)
    }

    func configureBindings() {
        viewModel.onUpdate = { [weak self] in
            self?.updateUI()
        }

        viewModel.onPick = { [weak self] title in
            self?.handlePick(title: title)
        }

        viewModel.onError = { [weak self] message in
            self?.presentError(message)
        }
    }
}

private extension CategoriesViewController {

    func updateUI() {
        tableView.reloadData()
        refreshEmptyState()
    }

    func refreshEmptyState() {
        let isEmpty = viewModel.isEmpty()
        emptyStateLabel.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }
}

private extension CategoriesViewController {

    func handlePick(title: String) {
        onPickCategory?(title)
        navigationController?.popViewController(animated: true)
    }

    func presentError(_ message: String) {
        let alert = UIAlertController(
            title: NSLocalizedString("alert.error_title", comment: ""),
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: NSLocalizedString("common.ok", comment: ""), style: .default))
        present(alert, animated: true)
    }

    @objc func addCategoryTapped() {
        let createVM = CreateCategoryViewModel(
            store: TrackerCategoryStore(context: CoreDataStack.shared.context)
        )
        let vc = CreateCategoryViewController(viewModel: createVM)
        vc.onCreated = { [weak self] _ in
            self?.updateUI()
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension CategoriesViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRows()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CategoryCell.reuseId,
            for: indexPath
        ) as? CategoryCell else {
            return UITableViewCell()
        }

        cell.configure(
            title: viewModel.title(at: indexPath.row),
            isSelected: viewModel.isSelected(at: indexPath.row)
        )

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.selectRow(at: indexPath.row)
    }
}
