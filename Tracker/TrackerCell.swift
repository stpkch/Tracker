import UIKit

protocol TrackerCellDelegate: AnyObject {
    func trackerCellDidTapToggle(_ cell: TrackerCell)
}

final class TrackerCell: UICollectionViewCell {

    static let reuseIdentifier = "TrackerCell"

    weak var delegate: TrackerCellDelegate?

    private let emojiLabel = UILabel()
    private let titleLabel = UILabel()
    private let countLabel = UILabel()
    private let toggleButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        emojiLabel.text = nil
        titleLabel.text = nil
        countLabel.text = nil
        toggleButton.setImage(nil, for: .normal)
    }

    private func setupViews() {
        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true
        contentView.backgroundColor = .secondarySystemBackground

        emojiLabel.font = .systemFont(ofSize: 30)
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.numberOfLines = 2
        titleLabel.textColor = .white

        countLabel.font = .systemFont(ofSize: 13)
        countLabel.textColor = .secondaryLabel

        toggleButton.addTarget(self, action: #selector(toggleButtonTapped), for: .touchUpInside)
        toggleButton.tintColor = .white
        toggleButton.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        toggleButton.layer.cornerRadius = 17
        toggleButton.layer.masksToBounds = true

        [emojiLabel, titleLabel, countLabel, toggleButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            emojiLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),

            titleLabel.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),

            countLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            countLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),

            toggleButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            toggleButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            toggleButton.widthAnchor.constraint(equalToConstant: 34),
            toggleButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }

    @objc
    private func toggleButtonTapped() {
        delegate?.trackerCellDidTapToggle(self)
    }

    func configure(
        with tracker: Tracker,
        isCompletedOnSelectedDate: Bool,
        completedCount: Int
    ) {
        emojiLabel.text = tracker.emoji
        titleLabel.text = tracker.title
        contentView.backgroundColor = tracker.color

        _ = NSLocalizedString("days_count", comment: "")
        countLabel.text = Plurals.days(completedCount)


        let imageName = isCompletedOnSelectedDate ? "checkmark" : "plus"
        let image = UIImage(systemName: imageName)
        toggleButton.setImage(image, for: .normal)
    }
}
