import UIKit

final class CreateCategoryViewController: UIViewController {

    var onCreated: ((String) -> Void)?

    private let viewModel: CreateCategoryViewModel

    private let textField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = NSLocalizedString("create_category.placeholder", comment: "")
        tf.backgroundColor = .systemGray6
        tf.layer.cornerRadius = 16
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        tf.leftViewMode = .always
        tf.clearButtonMode = .whileEditing
        return tf
    }()

    private let doneButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle(NSLocalizedString("create_category.done", comment: ""), for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.backgroundColor = .systemGray
        b.layer.cornerRadius = 16
        b.isEnabled = false
        return b
    }()

    init(viewModel: CreateCategoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureLayout()
        configureActions()
        bindViewModel()
    }
}

private extension CreateCategoryViewController {

    func configureUI() {
        title = NSLocalizedString("create_category.title", comment: "")
        view.backgroundColor = .systemBackground
        view.addSubview(textField)
        view.addSubview(doneButton)
    }

    func configureLayout() {
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 75),

            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    func configureActions() {
        textField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
    }
}

private extension CreateCategoryViewController {

    func bindViewModel() {
        viewModel.onValidationChanged = { [weak self] isValid in
            self?.applyValidation(isValid)
        }

        viewModel.onCreated = { [weak self] title in
            self?.handleCreated(title)
        }

        viewModel.onError = { [weak self] message in
            self?.showError(message)
        }
    }
}

private extension CreateCategoryViewController {

    func applyValidation(_ isValid: Bool) {
        doneButton.isEnabled = isValid
        doneButton.backgroundColor = isValid ? .black : .systemGray
    }
}

private extension CreateCategoryViewController {

    func handleCreated(_ title: String) {
        onCreated?(title)
        navigationController?.popViewController(animated: true)
    }
}

private extension CreateCategoryViewController {

    func showError(_ message: String) {
        let alert = UIAlertController(
            title: NSLocalizedString("alert.error_title", comment: ""),
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: NSLocalizedString("common.ok", comment: ""), style: .default))
        present(alert, animated: true)
    }
}

private extension CreateCategoryViewController {

    @objc func textChanged() {
        viewModel.updateTitle(textField.text ?? "")
    }

    @objc func doneTapped() {
        viewModel.create()
    }
}
