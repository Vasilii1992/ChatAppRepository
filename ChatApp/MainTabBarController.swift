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
 
 
 Ты IOS разработчик. У нас в приложении необходимо добавить функцию входа при помощи google акаунта,но проблема в том что при нажатии на кнопку,выдается вот такая ошибка " Error signing in with Google: The user canceled the sign-in flow.". Необходимо найти причину и исправить.
 Вот код, который отвечает за эту работу:
 
 
 
 You are an iOS developer. In our application, you need to add the login function using google account, but the problem is that when you click on the button, you get this error "Error signing in with Google: The user canceled the sign-in flow.". It is necessary to find the cause and fix it.
  Here is the code that is responsible for this work:
 
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
     
     private let googleLogInButton = GIDSignInButton()
     
     
     override func viewDidLoad() {
         super.viewDidLoad()
         
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
     
     @objc private func googleLoginButtonTapped() {
         guard let presentingViewController = self.presentingViewController else { return }
         
         GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { result, error in
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
             
             let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                            accessToken: accessToken)
             
             Auth.auth().signIn(with: credential) { authResult, error in
                 if let error = error {
                     print("Firebase sign-in with Google credential failed: \(error)")
                     return
                 }
                 
                 // User is signed in
                 guard let user = authResult?.user else { return }
                 print("Logged In User: \(user)")
                 self.navigationController?.dismiss(animated: true, completion: nil)
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
