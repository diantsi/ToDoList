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
    
    func configure(with task: TodoTask) {
        nameLabel.text = task.name
        dueDateLabel.text = task.dueDate.formatted(date: .abbreviated, time: .omitted)
        
    }
    
}
