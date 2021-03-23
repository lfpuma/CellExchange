//
//  RegisterViewController.swift
//  CellExchange
//
//  Created by Alexander Hudym on 28.09.17.
//  Copyright © 2017 CellExchange. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var verifyPasswordTextField: UITextField!
    @IBOutlet weak var formView: UIStackView!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var logoImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailTextField.delegate = self
        passwordTextField.delegate = self
        verifyPasswordTextField.delegate = self
        self.logoImageView.transform = CGAffineTransform(translationX: 0, y: -(self.view.frame.height - self.logoImageView.frame.height) / 2 + 100)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(outsideDidClick)))
        
        emailTextField.rightView = UIImageView(image: #imageLiteral(resourceName: "ic_warning"))
        passwordTextField.rightView = UIImageView(image: #imageLiteral(resourceName: "ic_warning"))
        verifyPasswordTextField.rightView = UIImageView(image: #imageLiteral(resourceName: "ic_warning"))
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillHide, object: nil)
    }

    @IBAction func registerDidClick(_ sender: UIButton) {
        if let email = emailTextField.text, let password = passwordTextField.text, let verifyPassword = passwordTextField.text {
            if email.isEmpty {
                emailTextField.rightViewMode = .always
                let alertEmailEmpty = UIAlertController(title: "Sign Up", message: "Enter your email", preferredStyle: .alert)
                alertEmailEmpty.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alertEmailEmpty, animated: true, completion: nil)
                return
            } else {
                emailTextField.rightViewMode = .never
            }
            if password.isEmpty {
                passwordTextField.rightViewMode = .always
                let alertEmailEmpty = UIAlertController(title: "Sign Up", message: "Enter your password", preferredStyle: .alert)
                alertEmailEmpty.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alertEmailEmpty, animated: true, completion: nil)
                return
            } else {
                passwordTextField.rightViewMode = .never
            }
            if verifyPassword != password {
                verifyPasswordTextField.rightViewMode = .always
                let alertEmailEmpty = UIAlertController(title: "Sign Up", message: "Passwords not equals", preferredStyle: .alert)
                alertEmailEmpty.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alertEmailEmpty, animated: true, completion: nil)
                return
            } else {
                verifyPasswordTextField.rightViewMode = .never
            }
            
            let registerSecondStageViewController = RegisterSecondStageViewController()
            registerSecondStageViewController.email = email
            registerSecondStageViewController.password = password
            registerSecondStageViewController.delegate = self
            let navigationController = UINavigationController(rootViewController: registerSecondStageViewController)
            present(navigationController, animated: true, completion: nil)
            
        }
        
    }
    
    @IBAction func haveAccountDidClick(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
    }
    
    @objc func outsideDidClick() {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let userInfo = notification.userInfo, let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect {
            if registerButton.frame.maxY > keyboardFrame.minY {
                UIView.animate(withDuration: 0.3) {
                    self.view.transform = CGAffineTransform(translationX: 0, y: -(self.registerButton.frame.maxY - keyboardFrame.minY + 20) )
                }
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.view.transform = CGAffineTransform(translationX: 0, y: 0)
        }
    }
    
}

extension RegisterViewController : RegisterSecondStageDelegate {
    func onSuccess() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.dismiss(animated: false, completion: nil)
        }
    }
}

extension RegisterViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            verifyPasswordTextField.becomeFirstResponder()
        } else if textField == verifyPasswordTextField {
            verifyPasswordTextField.resignFirstResponder()
        }
        return true
    }
    
}
