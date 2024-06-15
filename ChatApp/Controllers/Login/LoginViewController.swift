//
//  LoginViewController.swift
//  ChatApp
//
//  Created by Василий Тихонов on 14.06.2024.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "messenger-logo")
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    private let emailField: UITextField = {
       let field = UITextField()
        field.createTextField(holder: "Email Address...",
                              isSecureText: false,
                              returnKeyType: .continue)
            
        return field
    }()
    
    private let passwordField: UITextField = {
        let field = UITextField()
        field.createTextField(holder: "Password...",
                              isSecureText: true,
                              returnKeyType: .done)
        
        return field
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log In", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        
        return button
        
        
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        title = "Login"
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapRegister))
        
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        
        setupViews()
        setupDelegate()
    }
 
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let size = scrollView.width/3
        imageView.frame = CGRect(x: (scrollView.width-size)/2,
                                 y: 20,
                                 width: size,
                                 height: size)
        
        emailField.frame = CGRect(x: 30,
                                  y: imageView.botton + 10,
                                  width: scrollView.width-60,
                                 height: 52)
        passwordField.frame = CGRect(x: 30,
                                  y: emailField.botton + 10,
                                  width: scrollView.width-60,
                                 height: 52)
        loginButton.frame = CGRect(x: 30,
                                  y: passwordField.botton + 10,
                                  width: scrollView.width-60,
                                 height: 52)
    
    }
    
    
    
    func setupViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
        
    }
    func setupDelegate() {
        emailField.delegate = self
        passwordField.delegate = self
    }
    
    @objc private func didTapRegister() {
        
    let vc = RegisterViewController()
        vc.title = "Create Account"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func loginButtonTapped() {
        //MARK: - убирает клавиатуру
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let email = emailField.text, let password = passwordField.text,
              !email.isEmpty, !password.isEmpty, password.count >= 6 else {
              alertUserLoginError()
              return
        }
        //MARK: - Firebase login
        
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) {[weak self] authResult, error in
            guard let self = self else { return }
            
            guard let result = authResult, error == nil else {
                print("Failed to log in user with email: \(email)")
                return
            }
            let user = result.user
            print("Logged In User: \(user)")
            self.navigationController?.dismiss(animated: true, completion: nil)
            
            
        }
        
    }
    
    func alertUserLoginError() {
        let alert = UIAlertController(title: "Woops",
                                      message: "Please enter all information to log in",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        
        
        present(alert, animated: true)
        
    }
    
}
extension LoginViewController: UITextFieldDelegate {
    // MARK: - этот метод отвечает за то что будет происходить после нажатия enter в текстовом поле.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailField {
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField {
            loginButtonTapped()
        }
        
        
        
        return true
    }
    
    
}
