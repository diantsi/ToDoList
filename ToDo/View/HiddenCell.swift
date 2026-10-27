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
    
    func configure(with task: TodoTask) {
        titleLabel.text = task.name
        dueDateLabel.text = task.dueDate.formatted(
            date: .numeric,
            time: .shortened
        )
    }

    @IBAction func toggleDoneButton(_ sender: UIButton) {
    }
    
}
