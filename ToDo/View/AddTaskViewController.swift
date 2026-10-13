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

    var isSubtask: Bool = false
    
    var onSave: ((String, Date?) throws -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dueDatePicker.isHidden = isSubtask
        
        navigationItem.title = isSubtask
                    ? "Додати підзавдання"
                    : "Додати завдання"
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
        let dueDate = isSubtask ? nil : dueDatePicker.date

        do {
            try onSave?(name, dueDate)
            dismiss(animated: true)
        } catch {
            showSaveError(error)
        }
    }

    private func showSaveError(_ error: Error) {
        let alert = UIAlertController(
            title: "Не вдалося зберегти",
            message: error.localizedDescription,
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(
                title: "OK",
                style: .default
            )
        )

        present(alert, animated: true)
    }

}
