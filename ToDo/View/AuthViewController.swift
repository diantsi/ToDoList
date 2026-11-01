//
//  AuthViewController.swift
//  ToDo
//
//  Created by Діана Цісарук on 24.10.2026.
//

import UIKit

final class AuthViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    @IBOutlet weak var saveButton: UIButton!
    
    var onAuthorize: ((String, String) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.accessibilityTraits.insert(.header)

        usernameTextField.accessibilityLabel = "Електронна пошта"
        
        passwordTextField.accessibilityLabel = "Пароль"
        
        saveButton.accessibilityLabel = "Увійти"
        
        
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        UIAccessibility.post(
            notification: .screenChanged,
            argument: titleLabel
        )
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @IBAction func saveButtonTapped(_ sender: UIButton) {
        let email =
            usernameTextField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let password =
            passwordTextField.text?.trimmingCharacters(in: .whitespaces) ?? ""

        guard !email.isEmpty else {
            UIAccessibility.post(
                notification: .layoutChanged,
                argument: "поле електронної пошти порожнє"
            )
            return
        }
        guard !password.isEmpty else {
            UIAccessibility.post(
                notification: .layoutChanged,
                argument: "поле паролю порожнє"
            )
            return
        }

        onAuthorize?(email, password)
    }
}
