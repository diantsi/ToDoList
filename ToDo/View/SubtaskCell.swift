//
//  SubtaskCell.swift
//  ToDo
//
//  Created by Діана Цісарук on 13.10.2026.
//

import UIKit

final class SubtaskCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var notificationSwitch: UISwitch!

    var onToggle: (() -> Void)?
    var onNotificationChange: ((Bool) -> Void)?
    var onDelete: (() -> Void)?

    func configure(with subtask: TodoSubtask) {
        nameLabel.text = subtask.name
        dueDateLabel.text = subtask.dueDate.formatted(
            date: .abbreviated,
            time: .shortened
        )
        notificationSwitch.isOn = subtask.needToNotify
        configureDoneButton(isDone: subtask.isDone)

        configureAccessibility(with: subtask)
    }

    private func configureAccessibility(with subtask: TodoSubtask) {
        isAccessibilityElement = true

        accessibilityLabel =
            "Підзавдання \(subtask.name). "
            + "Термін виконання \(subtask.dueDate.voiceOverFormatted)"

        accessibilityValue = [
            subtask.isDone ? "Виконано" : "Не виконано",
            subtask.needToNotify
                ? "Сповіщення увімкнені"
                : "Сповіщення вимкнені",
        ].joined(separator: ". ")

        accessibilityCustomActions = [
            UIAccessibilityCustomAction(
                name: subtask.isDone
                    ? "Позначити невиконаним"
                    : "Позначити виконаним"
            ) { [weak self] _ in
                self?.onToggle?()
                return true
            },

            UIAccessibilityCustomAction(
                name: subtask.needToNotify
                    ? "Вимкнути сповіщення"
                    : "Увімкнути сповіщення"
            ) { [weak self] _ in
                self?.onNotificationChange?(!subtask.needToNotify)
                return true
            },
            UIAccessibilityCustomAction(
                name: "Видалити підзавдання"
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

    @IBAction func toggleSubtaskIsDone(_ sender: UIButton) {
        onToggle?()
    }

    @IBAction func notificationSwitchChanged(_ sender: UISwitch) {
        onNotificationChange?(sender.isOn)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onToggle = nil
        onNotificationChange = nil
        onDelete = nil
        accessibilityCustomActions = nil
    }
}
