//
//  MainTabBarController.swift
//  ChatApp
//
//  Created by Василий Тихонов on 15.06.2024.
//

import Foundation
import UIKit
 
final class MainTabBarController: UITabBarController {

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
    }
    
    func setupTabBar() {
        let conversationViewController = createNavController(vc: ConversationViewController(), itemName: "Chat", itemImage: "message.circle.fill")
        let profileViewController = createNavController(vc: ProfileViewController(), itemName: "Profile", itemImage: "person.crop.circle")
        
        viewControllers = [conversationViewController, profileViewController]
    }
    
    
    func createNavController(vc: UIViewController, itemName: String, itemImage: String) -> UINavigationController {
        
        let item = UITabBarItem(title: itemName, image: UIImage(systemName: itemImage)?.withAlignmentRectInsets(.init(top: 10,
                                                                                                                      left: 0,
                                                                                                                      bottom: 0,
                                                                                                                      right: 0)), tag: 0)
        item.titlePositionAdjustment = .init(horizontal: 0, vertical: 0)
        let navController = UINavigationController(rootViewController: vc)
        navController.tabBarItem = item
        return navController
        
        
    }


}

/*
 
 
 Ты IOS разработчик. У нас в приложении добавлена функция регистрации через google акаунт, но проблема в том что при входе в акаунт через Google данные не сохраняются в Realtime Database. Данные там сохраняются когда мы регистрируемся обычным способом.Нужно сделать так, чтобы при входе через Google у нас была такая же логика как в "registerButtonTapped".
 
 
 You are an iOS developer. We have added the registration function via Google account in our application, but the problem is that when logging in to the account via Google, the data is not saved in the Realtime Database. The data is stored there when we register in the usual way.We need to make sure that when logging in via Google, we have the same logic as in "registerButtonTapped".
 
 import UIKit
 import Firebase
 import GoogleSignIn


 @main
 class AppDelegate: UIResponder, UIApplicationDelegate {



     func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

         FirebaseApp.configure()
         
         let signInConfig = GIDConfiguration(clientID: FirebaseApp.app()?.options.clientID ?? "")
                GIDSignIn.sharedInstance.configuration = signInConfig
         
         return true
     }
     func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
         return GIDSignIn.sharedInstance.handle(url)
     }
     
     // MARK: UISceneSession Lifecycle

     func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
         // Called when a new scene session is being created.
         // Use this method to select a configuration to create the new scene with.
         return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
     }

     func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
         // Called when the user discards a scene session.
         // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
         // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
     }


 }
 class RegisterViewController: UIViewController {
     
     private let spinner = JGProgressHUD(style: .dark)

     
     private let scrollView: UIScrollView = {
         let scrollView = UIScrollView()
         scrollView.clipsToBounds = true
       //  scrollView.isUserInteractionEnabled = true
         return scrollView
     }()
     
     private let imageView: UIImageView = {
         let imageView = UIImageView()
         imageView.image = UIImage(systemName: "person.circle")
         imageView.tintColor = .systemGray4
         imageView.contentMode = .scaleAspectFit
         imageView.isUserInteractionEnabled = true
         imageView.layer.masksToBounds = true
         imageView.layer.borderWidth = 2
         imageView.layer.borderColor = UIColor.lightGray.cgColor
         
         
         return imageView
     }()
     
     private let emailField: UITextField = {
        let field = UITextField()
         field.createTextField(holder: "Email Address...",
                               isSecureText: false,
                               returnKeyType: .continue)
             
         return field
     }()
     
     private let firstNameField: UITextField = {
        let field = UITextField()
         field.createTextField(holder: "First Name...",
                               isSecureText: false,
                               returnKeyType: .continue)
             
         return field
     }()
     private let lastNameField: UITextField = {
        let field = UITextField()
         field.createTextField(holder: "Last Name...",
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
     
     private let registerButton: UIButton = {
         let button = UIButton()
         button.setTitle("Register", for: .normal)
         button.backgroundColor = .systemGreen
         button.setTitleColor(.white, for: .normal)
         button.layer.cornerRadius = 12
         button.layer.masksToBounds = true
         button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
         
         return button
         
         
     }()
     
     
     override func viewDidLoad() {
         super.viewDidLoad()
         
         
         title = "Register"
         view.backgroundColor = .white

         registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
         
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
         imageView.layer.cornerRadius = imageView.width/2.0
         
         firstNameField.frame = CGRect(x: 30,
                                   y: imageView.botton + 10,
                                   width: scrollView.width-60,
                                  height: 52)
         lastNameField.frame = CGRect(x: 30,
                                   y: firstNameField.botton + 10,
                                   width: scrollView.width-60,
                                  height: 52)
         emailField.frame = CGRect(x: 30,
                                   y: lastNameField.botton + 10,
                                   width: scrollView.width-60,
                                  height: 52)
         passwordField.frame = CGRect(x: 30,
                                   y: emailField.botton + 10,
                                   width: scrollView.width-60,
                                  height: 52)
         registerButton.frame = CGRect(x: 30,
                                   y: passwordField.botton + 10,
                                   width: scrollView.width-60,
                                  height: 52)
     
     }
     
     
     
     func setupViews() {
         view.addSubview(scrollView)
         scrollView.addSubview(imageView)
         scrollView.addSubview(firstNameField)
         scrollView.addSubview(lastNameField)
         scrollView.addSubview(emailField)
         scrollView.addSubview(passwordField)
         scrollView.addSubview(registerButton)
         
         
         let gesture = UITapGestureRecognizer(target: self,
                                              action: #selector(didTapChangePrifilePic))
         
         
         
 //        gesture.numberOfTapsRequired = 1
 //        gesture.numberOfTouchesRequired = 1
         imageView.addGestureRecognizer(gesture)
         
     }
     func setupDelegate() {
         emailField.delegate = self
         passwordField.delegate = self
     }
     
     @objc private func didTapChangePrifilePic() {
         presentPhotoActionSheet()
     }
     
     @objc private func registerButtonTapped() {
         
         emailField.resignFirstResponder()
         passwordField.resignFirstResponder()
         firstNameField.resignFirstResponder()
         lastNameField.resignFirstResponder()
         
         guard let email = emailField.text,
               let password = passwordField.text,
               let firstName = firstNameField.text,
               let lastName = lastNameField.text,
               !firstName.isEmpty,
               !lastName.isEmpty,
               !email.isEmpty,
               !password.isEmpty,
               password.count >= 6 else {
               alertUserLoginError()
               return
         }
         
         spinner.show(in: view)

         // Firebase login
         
         DatabaseManager.shared.userExists(with: email) { [weak self] exist in
             guard let self = self else { return }
             
             DispatchQueue.main.async {
                 self.spinner.dismiss()
             }
             
             guard !exist else {
                 //пользователь уже существует
                 self.alertUserLoginError(message: "Looks like a user account for that email already exist.")
                 return
             }
             FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                 guard authResult != nil, error == nil else {
                    print("Error creating user")
                     return
                 }
                 let chatUser = ChatAppUser(firstName: firstName,
                                            lastName: lastName,
                                            emailAddress: email)
                 DatabaseManager.shared.insertUser(with: chatUser, completion: { sucsess in
                     if sucsess {
                         // upload image
                     }
                 })
                 self.navigationController?.dismiss(animated: true, completion: nil)

             }
         }
     }
     
     func alertUserLoginError(message: String = "default error") {
         let alert = UIAlertController(title: "Woops",
                                       message: message,
                                       preferredStyle: .alert)
         alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
         
         
         present(alert, animated: true)
         
     }
     
 }
 extension RegisterViewController: UITextFieldDelegate {
     // MARK: - этот метод отвечает за то что будет происходить после нажатия enter в текстовом поле.
     func textFieldShouldReturn(_ textField: UITextField) -> Bool {
         
         if textField == emailField {
             passwordField.becomeFirstResponder()
         }
         else if textField == passwordField {
             registerButtonTapped()
         }
         
         
         
         return true
     }
 }
 extension RegisterViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
     
     func presentPhotoActionSheet() {
         let actionSheet = UIAlertController(title: "Profile Picture",
                                             message: "How would you like to select a picture?",
                                             preferredStyle: .actionSheet)
         
         actionSheet.addAction(UIAlertAction(title: "Cancel",
                                             style: .cancel,
                                             handler: nil))
         
         actionSheet.addAction(UIAlertAction(title: "Take Photo",
                                             style: .default,
                                             handler: { [weak self] _ in
             self?.presentCamera()
             
         }))
         
         actionSheet.addAction(UIAlertAction(title: "Chose Photo",
                                             style: .default,
                                             handler: { [weak self] _ in
             self?.presentPhotoPicker()
             
         }))
         
         present(actionSheet, animated: true)
     }
     
     func presentCamera() {
         let vc = UIImagePickerController()
         vc.sourceType = .camera
         vc.delegate = self
         vc.allowsEditing = true
         present(vc, animated: true)
     }
     
     func presentPhotoPicker() {
         let vc = UIImagePickerController()
         vc.sourceType = .photoLibrary
         vc.delegate = self
         vc.allowsEditing = true
         present(vc, animated: true)
         
     }
     
     func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
         picker.dismiss(animated: true, completion: nil)
         // фото которое мы выбираем в альбоме
         guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }

         self.imageView.image = selectedImage
     
     }
     
     func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
         
         picker.dismiss(animated: true, completion: nil)
         
     }
 }

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
         // тут нужно сделать такую же логику как в registerButtonTapped()
           
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
               
               Auth.auth().signIn(with: credential) { authResult, error in
                   if let error = error {
                       print("Firebase sign-in with Google credential failed: \(error)")
                       return
                   }
                   
                   guard let user = authResult?.user else { return }
                   print("Logged In User: \(user)")
                   NotificationCenter.default.post(name: .didLogInNotification, object: nil)

                   
                   
                   

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


 
 */
