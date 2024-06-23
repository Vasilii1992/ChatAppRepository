//
//  LoginViewController.swift
//  ChatApp
//
//  Created by Василий Тихонов on 14.06.2024.
//

import UIKit
import FirebaseAuth
import GoogleSignIn
import JGProgressHUD

class LoginViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
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
        button.backgroundColor = .systemCyan
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        
        return button
        
        
    }()
    
    private let googleLogInButton = GIDSignInButton()
    
    private var loginObserver: NSObjectProtocol?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        loginObserver = NotificationCenter.default.addObserver(forName: .didLogInNotification, object: nil, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            self.navigationController?.dismiss(animated: true)
        }
        
        
        title = "Login"
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapRegister))
        
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        googleLogInButton.addTarget(self, action: #selector(googleLoginButtonTapped), for: .touchUpInside)


        
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
        googleLogInButton.frame = CGRect(x: 30,
                                  y: loginButton.botton + 10,
                                  width: scrollView.width-60,
                                 height: 52)
    
    }
    
    
    
    func setupViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
        scrollView.addSubview(googleLogInButton)
        
    }
    
    deinit {
        if let observer = loginObserver {
            NotificationCenter.default.removeObserver(observer)
        }
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
        
        spinner.show(in: view)
        
        //MARK: - Firebase login
        
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) {[weak self] authResult, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.spinner.dismiss()
            }
            
            
            guard let result = authResult, error == nil else {
                print("Failed to log in user with email: \(email)")
                return
            }
            let user = result.user
            
            let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
            DatabaseManager.shared.getDataFor(path: safeEmail) { result in
                switch result {
                    
                case .success(let data):
                    guard let userData = data as? [String: Any],
                    let firstName = userData["first_name"] as? String,
                    let lastName = userData["last_name"] as? String else {
                        return
                    }
                      UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")

                case .failure(let error):
                    print("Failed to read data with error \(error)")
                }
            }
            
            
            UserDefaults.standard.set(email, forKey: "email")
            // чтобы получать данные о своем имяни в приложении

            
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
    
    @objc private func googleLoginButtonTapped() {
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { result, error in
            guard error == nil else {
                print("Error signing in with Google: \(error!.localizedDescription)")
                return
            }
            
            guard let result = result else {
                print("Google sign-in result not available")
                return
            }
            
            let user = result.user
            let idToken = user.idToken?.tokenString
            let accessToken = user.accessToken.tokenString
            
            guard let idToken = idToken else {
                print("Google ID token or access token not available")
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            
            Auth.auth().signIn(with: credential) { [weak self] authResult, error in
                guard let self = self else { return }
                if let error = error {
                    print("Firebase sign-in with Google credential failed: \(error)")
                    return
                }
                
                guard let user = authResult?.user else { return }
                print("Logged In User: \(user)")

                let email = user.email ?? ""
                let firstName = result.user.profile?.givenName ?? ""
                let lastName = result.user.profile?.familyName ?? ""
                
                UserDefaults.standard.set(email, forKey: "email")
                
                UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")


                
                DatabaseManager.shared.userExists(with: email) { exist in
                    if !exist {
                        let chatUser = ChatAppUser(firstName: firstName,
                                                   lastName: lastName,
                                                   emailAddress: email)
                        DatabaseManager.shared.insertUser(with: chatUser, completion: { success in
                            if success {
                                // upload image
                                if ((result.user.profile?.hasImage) != nil) {
                                    guard let url = result.user.profile?.imageURL(withDimension: 200) else { return }
                                    URLSession.shared.dataTask(with: url) { data, _, _ in
                                        guard let data = data else { return }
                                        let fileName = chatUser.profilePictureFileName
                                        StorageManager.shaed.uploadProfilePicture(with: data, fileName: fileName) { result in
                                            switch result {
                                            case .success(let downloadUrl):
                                                UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                                                print(downloadUrl)
                                            case .failure(let error):
                                                print("Storage manager error: \(error)")
                                            }
                                        }
                                    }.resume()
                                }
                            }
                        })
                    }
                    NotificationCenter.default.post(name: .didLogInNotification, object: nil)
                    self.navigationController?.dismiss(animated: true, completion: nil)
                }
            }
        }
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
