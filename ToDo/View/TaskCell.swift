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

    var onToggle: (() -> Void)?
    var onDelete: (() -> Void)?

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
        let imageName =
            isDone
            ? "checkmark.square.fill"
            : "square"

        var configuration = doneButton.configuration
        configuration?.image = UIImage(systemName: imageName)
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
