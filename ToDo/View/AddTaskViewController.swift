//
//  AddTaskViewController.swift
//  ToDo
//
//  Created by Діана Цісарук on 13.10.2026.
//
import UIKit

final class AddTaskViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var dueDatePicker: UIDatePicker!

    var persistenceService: (any PersistenceService)!
    
    var onTaskAdded: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }

    @IBAction func saveTapped(_ sender: UIBarButtonItem) {
        guard
            let name = nameTextField.text?
                .trimmingCharacters(in: .whitespacesAndNewlines),
            !name.isEmpty
        else {
            return
        }

        let task = TodoTask(
            name: name,
            dueDate: dueDatePicker.date
        )

        do {
            try persistenceService.addTask(task)
            onTaskAdded?()
            dismiss(animated: true)
        } catch {
            let alert = UIAlertController(
                title: "Save Failed",
                message: error.localizedDescription,
                preferredStyle: .alert
            )
            alert.addAction(
                UIAlertAction(title: "OK", style: .default)
            )
            present(alert, animated: true)
        }
    }

}
