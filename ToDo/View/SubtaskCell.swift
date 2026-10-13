//
//  SubtaskCell.swift
//  ToDo
//
//  Created by Діана Цісарук on 13.10.2026.
//

import UIKit

final class SubtaskCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!

    var onToggle: (() -> Void)?

    func configure(with subtask: TodoSubtask) {
        nameLabel.text = subtask.name
        configureDoneButton(isDone: subtask.isDone)
    }

    private func configureDoneButton(isDone: Bool) {
        let imageName = isDone
            ? "checkmark.square.fill"
            : "square"

        var configuration = doneButton.configuration
        configuration?.image = UIImage(systemName: imageName)
        doneButton.configuration = configuration
    }

    @IBAction func toggleSubtaskIsDone(_ sender: UIButton) {
        onToggle?()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onToggle = nil
    }
}
