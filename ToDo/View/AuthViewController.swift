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
    @IBOutlet weak var authStackView: UIStackView!
    @IBOutlet weak var usernameStackView: UIStackView!
    @IBOutlet weak var passwordStackView: UIStackView!
    @IBOutlet weak var authStackCenterXConstraint: NSLayoutConstraint!
    @IBOutlet weak var authStackCenterYConstraint: NSLayoutConstraint!

    private var authStackMaxWidthConstraint: NSLayoutConstraint!
    
    var onAuthorize: ((String, String) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        authStackMaxWidthConstraint = authStackView.widthAnchor.constraint(
            lessThanOrEqualTo: view.safeAreaLayoutGuide.widthAnchor
        )
        authStackMaxWidthConstraint.isActive = true

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

        registerForTraitChanges(
            [UITraitPreferredContentSizeCategory.self]
        ) { (self: Self, _: UITraitCollection) in
            self.updateDynamicTypeLayout()
        }
        updateDynamicTypeLayout()
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

    private func updateDynamicTypeLayout() {
        let metrics = UIFontMetrics(forTextStyle: .body)

        authStackView.spacing = metrics.scaledValue(for: 12)
        usernameStackView.spacing = metrics.scaledValue(for: 7)
        passwordStackView.spacing = metrics.scaledValue(for: 7)

        let inset = metrics.scaledValue(for: 20)
        authStackMaxWidthConstraint.constant = -(inset * 2)

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
