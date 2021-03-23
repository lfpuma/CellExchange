//
//  AuthorizeViewController.swift
//  CellExchange
//
//  Created by Alexander Hudym on 28.09.17.
//  Copyright © 2017 CellExchange. All rights reserved.
//

import UIKit
import SVProgressHUD
import FirebaseInstanceID
import RxSwift

class LoginViewController: UIViewController {

    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var formView: UIStackView!
    @IBOutlet weak var signUpContainer: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        formView.alpha = 0
        loginButton.alpha = 0
        forgotPasswordButton.alpha = 0
        signUpContainer.alpha = 0
        UIView.animate(withDuration: 1.0, delay: 1.0, options: .curveEaseIn, animations: { [unowned self] in
            self.logoImageView.transform = CGAffineTransform(translationX: 0, y: -(self.view.frame.height - self.logoImageView.frame.height) / 2 + 100)
            self.formView.alpha = 1
            self.loginButton.alpha = 1
            self.signUpContainer.alpha = 1
            self.forgotPasswordButton.alpha = 1
        }, completion: nil)
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        emailTextField.rightView = UIImageView(image: #imageLiteral(resourceName: "ic_warning"))
        passwordTextField.rightView = UIImageView(image: #imageLiteral(resourceName: "ic_warning"))
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(outsideDidClick)))
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func outsideDidClick() {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let userInfo = notification.userInfo, let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect {
            if loginButton.frame.maxY > keyboardFrame.minY {
                UIView.animate(withDuration: 0.3) {
                    self.view.transform = CGAffineTransform(translationX: 0, y: -(self.loginButton.frame.maxY - keyboardFrame.minY + 20) )
                }
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.view.transform = CGAffineTransform(translationX: 0, y: 0)
        }
    }

    @IBAction func loginDidClick(_ sender: UIButton) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            if email.isEmpty {
                emailTextField.rightViewMode = .always
                let alertEmailEmpty = UIAlertController(title: "Sign In", message: "Enter your email", preferredStyle: .alert)
                alertEmailEmpty.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alertEmailEmpty, animated: true, completion: nil)
                return
            } else {
                emailTextField.rightViewMode = .never
            }
            if password.isEmpty {
                passwordTextField.rightViewMode = .always
                let alertEmailEmpty = UIAlertController(title: "Sign In", message: "Enter your password", preferredStyle: .alert)
                alertEmailEmpty.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alertEmailEmpty, animated: true, completion: nil)

                return
            } else {
                passwordTextField.rightViewMode = .never
            }
            
            
            _ = UserManager.instance.signIn(email: email, password: password)
                .do(onSubscribe: { SVProgressHUD.show() }, onDispose: { SVProgressHUD.dismiss() })
                .flatMap { respose -> Observable<Any> in
                    if let result = respose as? NSDictionary {
                        if let token = result["token"] as? String, let userId = result["user_id"] as? Int {
                            UserManager.instance.token = token
                            UserManager.instance.currentUserId = userId
                        }
                    }
                    let firebaseToken = InstanceID.instanceID().token() ?? ""
                    return UserManager.instance.sendFirebaseToken(token: firebaseToken)
                }
                .subscribe(onNext: { [weak self] response in
                    print(response)
                    self?.present(MainViewController(rootViewController: HomeViewController()), animated: true, completion: nil)
                }, onError: { [weak self] error in
                    print(error)
                    let loginFailedAlert = UIAlertController(title: "Sign In", message: "Could not log in. Verify that you entered the correct data and try again.", preferredStyle: .alert)
                    loginFailedAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self?.present(loginFailedAlert, animated: true, completion: nil)
                })
        }
    }
    
    @IBAction func registerDidClick(_ sender: UIButton) {
        if let registerViewController = storyboard?.instantiateViewController(withIdentifier: "register") as? RegisterViewController {
            present(registerViewController, animated: false, completion: nil)
        }
    }
    
    @IBAction func forgetPasswordDidClick(_ sender: UIButton) {
        let forgetAlert = UIAlertController(title: "Forget password", message: "Please enter your email to reset your password", preferredStyle: .alert)
        forgetAlert.addTextField { textField in
            textField.placeholder = "Email"
            textField.keyboardType = .emailAddress
        }
        forgetAlert.addAction(UIAlertAction(title: "Submit", style: .default) { _ in
            if let textFields = forgetAlert.textFields {
                let emailTextField = textFields[0]
                if let email = emailTextField.text, !email.isEmpty {
                    _ = UserManager.instance.forgotPassword(email: email)
                        .do(onSubscribe: {SVProgressHUD.show()}, onDispose: {SVProgressHUD.dismiss()})
                        .subscribe(onNext: { [weak self] response in
                            let forgotPasswordAlert = UIAlertController(title: "Forgot password", message: "Password reset link sent to your email. Please check your email", preferredStyle: .alert)
                            forgotPasswordAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self?.present(forgotPasswordAlert, animated: true, completion: nil)
                        }, onError: { [weak self] error in
                            print(error)
                            let forgotPasswordAlert = UIAlertController(title: "Forgot password", message: "Reset password was failed. Try again later", preferredStyle: .alert)
                            forgotPasswordAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self?.present(forgotPasswordAlert, animated: true, completion: nil)
                        })
                }
            }
        })
        forgetAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(forgetAlert, animated: true, completion: nil)
    }

}

extension LoginViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            passwordTextField.resignFirstResponder()
        }
        return true
    }
}
