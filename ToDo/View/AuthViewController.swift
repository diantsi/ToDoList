//
//  AuthViewController.swift
//  ToDo
//
//  Created by Діана Цісарук on 24.10.2026.
//

import UIKit

final class AuthViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var onAuthorize: ((String, String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        let email = usernameTextField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let password = passwordTextField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        
        guard !email.isEmpty else {
            return
        }
        guard !password.isEmpty else {
            return
        }
        
        onAuthorize?(email, password)
    }
}
