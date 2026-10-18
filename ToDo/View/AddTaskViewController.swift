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

    @IBOutlet weak var toNotifySwitch: UISwitch!
    
    var isSubtask: Bool = false
    
    var onSave: ((String, Date, Bool) throws -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        do {
            try onSave?(name, dueDatePicker.date, toNotifySwitch.isOn)
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
