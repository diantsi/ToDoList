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

    var onToggle: (() -> Void)?
    var onDelete: (() -> Void)?

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
