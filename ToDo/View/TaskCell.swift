//
//  TaskCell.swift
//  ToDo
//
//  Created by Діана Цісарук on 12.10.2026.
//
import UIKit

final class TaskCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var cellStackView: UIStackView!
    @IBOutlet weak var textStackView: UIStackView!
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!

    var onToggle: (() -> Void)?
    var onDelete: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        registerForTraitChanges(
            [UITraitPreferredContentSizeCategory.self]
        ) { (self: Self, _: UITraitCollection) in
            self.updateDynamicTypeLayout()
        }

        updateDynamicTypeLayout()
    }

    func configure(with task: TodoTask) {
        nameLabel.text = task.name
        dueDateLabel.text = task.dueDate.formatted(
            date: .abbreviated,
            time: .shortened
        )
        configureDoneButton(isDone: task.isDone)

        configureAccessibility(with: task)
    }

    private func configureAccessibility(with task: TodoTask) {
        isAccessibilityElement = true

        nameLabel.isAccessibilityElement = false
        dueDateLabel.isAccessibilityElement = false
        doneButton.isAccessibilityElement = false

        accessibilityLabel = [
            task.name,
            "Термін виконання \(task.dueDate.voiceOverFormatted)",
            task.subtasks.isEmpty
                ? "Підзавдань немає"
                : "Є підзавдання",
        ].joined(separator: ". ")

        accessibilityValue = task.isDone ? "Виконано" : "Не виконано"
        accessibilityHint = "Двічі торкніться, щоб відкрити деталі завдання"
        accessibilityTraits = .button

        accessibilityCustomActions = [
            UIAccessibilityCustomAction(
                name: task.isDone
                    ? "Позначити невиконаним"
                    : "Позначити виконаним"
            ) { [weak self] _ in
                self?.onToggle?()
                return true
            },
            UIAccessibilityCustomAction(
                name: "Видалити"
            ) { [weak self] _ in
                self?.onDelete?()
                return true
            },
        ]
    }

    private func configureDoneButton(isDone: Bool) {
        let imageName = isDone
            ? "checkmark.square.fill"
            : "square"

        var configuration = doneButton.configuration
        configuration?.image = UIImage(systemName: imageName)
        doneButton.configuration = configuration
    }

    func updateDynamicTypeLayout() {
        let usesAccessibilityCategory = traitCollection
            .preferredContentSizeCategory.isAccessibilityCategory

        cellStackView.axis = usesAccessibilityCategory ? .vertical : .horizontal
        cellStackView.alignment = usesAccessibilityCategory ? .fill : .center
        doneButton.contentHorizontalAlignment =
            usesAccessibilityCategory ? .leading : .center

        let metrics = UIFontMetrics(forTextStyle: .body)

        cellStackView.spacing = metrics.scaledValue(for: 12)
        textStackView.spacing = metrics.scaledValue(for: 10)

        let constraint = metrics.scaledValue(for: 10)
        trailingConstraint.constant = constraint
        leadingConstraint.constant = constraint
        topConstraint.constant = constraint
        bottomConstraint.constant = constraint

        var configuration = doneButton.configuration
        configuration?.contentInsets = .zero
        doneButton.configuration = configuration
    }

    @IBAction func toggleTaskIsDone(_ sender: UIButton) {
        onToggle?()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onToggle = nil
        onDelete = nil
        accessibilityCustomActions = nil
    }
}
