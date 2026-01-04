import UIKit

final class CategoryCell: UITableViewCell {

    static let reuseId = "CategoryCell"

    func configure(title: String, isSelected: Bool) {
        textLabel?.text = title
        accessoryType = isSelected ? .checkmark : .none
        selectionStyle = .default
    }
}
