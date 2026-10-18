//
//  TaskCell.swift
//  ToDo
//
//  Created by Діана Цісарук on 12.10.2026.
//
import UIKit

class TaskCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!

    @IBAction func remindSwitched(_ sender: UISwitch) {
        onRemind?(sender.isOn)
    }
    
    var onToggle: (() -> Void)?
    var onRemind: ((Bool) -> Void)?

    func configure(with task: TodoTask) {
        nameLabel.text = task.name
        dueDateLabel.text = task.dueDate.formatted(
            date: .abbreviated,
            time: .shortened
        )
        configureDoneButton(isDone: task.isDone)
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
        onRemind = nil
    }
}
