//
//  HiddenCell.swift
//  ToDo
//
//  Created by Діана Цісарук on 25.10.2026.
//
import UIKit

class HiddenCell : UITableViewCell {

    @IBOutlet weak var isDone: UIButton!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!

    var onToggle: (() -> Void)?
    
    func configure(with task: TodoTask) {
        titleLabel.text = task.name
        dueDateLabel.text = task.dueDate.formatted(
            date: .numeric,
            time: .shortened
        )
        configureDoneButton(isDone: task.isDone)
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
    }
}
