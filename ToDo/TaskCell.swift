//
//  TaskCell.swift
//  ToDo
//
//  Created by Діана Цісарук on 12.10.2026.
//
import UIKit

class TaskCell: UITableViewCell {

    func configure(with task: String) {
        var configuration = UIListContentConfiguration.subtitleCell()

        configuration.text = task
        
        contentConfiguration = configuration
    }
    
}
