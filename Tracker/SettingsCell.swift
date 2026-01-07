import UIKit

final class SettingsCell: UIControl {

    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    private let arrowImageView = UIImageView(image: UIImage(systemName: "chevron.right"))

    init(title: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 17)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        valueLabel.font = UIFont.systemFont(ofSize: 17)
        valueLabel.textColor = .secondaryLabel
        valueLabel.textAlignment = .right
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        valueLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        arrowImageView.tintColor = .systemGray
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(titleLabel)
        addSubview(valueLabel)
        addSubview(arrowImageView)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 60),

            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            arrowImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            arrowImageView.centerYAnchor.constraint(equalTo: centerYAnchor),

            valueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 12),
            valueLabel.trailingAnchor.constraint(equalTo: arrowImageView.leadingAnchor, constant: -8),
            valueLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }
    
// MARK: - Public
    
    func setValue(_ text: String?) {
        let trimmed = (text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        valueLabel.text = trimmed.isEmpty ? nil : trimmed
    }
}
