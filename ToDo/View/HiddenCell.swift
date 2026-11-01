//
//  HiddenCell.swift
//  ToDo
//
//  Created by Діана Цісарук on 25.10.2026.
//
import UIKit

final class HiddenCell: UITableViewCell {

    @IBOutlet weak var isDone: UIButton!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
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
            [UITraitPreferredContentSizeCategory.self]) {
                (self: Self, _: UITraitCollection) in
                self.updateDynamicTypeLayout()
            }
        updateDynamicTypeLayout()
    }

    func updateDynamicTypeLayout() {
        let usesAccessibilityCategory = traitCollection
            .preferredContentSizeCategory.isAccessibilityCategory

        cellStackView.axis = usesAccessibilityCategory ? .vertical : .horizontal
        cellStackView.alignment = usesAccessibilityCategory ? .fill : .center
        isDone.contentHorizontalAlignment =
            usesAccessibilityCategory ? .leading : .center

        let metrics = UIFontMetrics(forTextStyle: .body)

        cellStackView.spacing = metrics.scaledValue(for: 12)
        textStackView.spacing = metrics.scaledValue(for: 10)

        let constraint = metrics.scaledValue(for: 10)
        trailingConstraint.constant = constraint
        leadingConstraint.constant = constraint
        topConstraint.constant = constraint
        bottomConstraint.constant = constraint

        var configuration = isDone.configuration
        configuration?.contentInsets = .zero
        isDone.configuration = configuration
    }

    func configure(with task: TodoTask) {
        titleLabel.text = task.name
        dueDateLabel.text = task.dueDate.formatted(
            date: .numeric,
            time: .shortened
        )
        configureDoneButton(isDone: task.isDone)

        configureAccessibility(with: task)
    }

    private func configureAccessibility(with task: TodoTask) {
        isAccessibilityElement = true

        accessibilityLabel = [
            task.name,
            "Термін виконання \(task.dueDate.voiceOverFormatted)",
        ].joined(separator: ". ")

        accessibilityValue = task.isDone ? "Виконано" : "Не виконано"

        accessibilityHint = "Доступні дії для зміни стану та видалення"

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

        var configuration = self.isDone.configuration
        configuration?.image = UIImage(systemName: imageName)
        self.isDone.configuration = configuration
    }

    @IBAction func toggleDoneButton(_ sender: UIButton) {
        onToggle?()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onToggle = nil
        onDelete = nil
        accessibilityCustomActions = nil
    }
}
