//
//  ProfileViewController.swift
//  ChatApp
//
//  Created by Василий Тихонов on 14.06.2024.
//

import UIKit
import FirebaseAuth
import GoogleSignIn
import SDWebImage

enum ProfileViewModelType {
    case info, logout
}

struct ProfileViewModel {
    let viewModelType: ProfileViewModelType
    let title: String
    let handler: (() -> Void)?
}


class ProfileViewController: UIViewController {
    
  private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
      tableView.register(ProfileTableViewCell.self, forCellReuseIdentifier: ProfileTableViewCell.identifire)

        return tableView
    }()
    
    func cereateTableHeader() -> UIView? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else { return nil }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        let fileName = safeEmail + "_profile_picture.png"
        
        let path = "images/"+fileName
        
        let headerView = UIView(frame: CGRect(x: 0,
                                        y: 0,
                                              width: self.view.width,
                                        height: 300))
        headerView.backgroundColor = .link
        
        let imageView = UIImageView(frame: CGRect(x: (headerView.width-150) / 2,
                                                  y: 75,
                                                  width: 150,
                                                  height: 150))
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .white
        imageView.layer.borderColor = UIColor.systemGreen.cgColor
        imageView.layer.borderWidth = 3
        imageView.layer.cornerRadius = imageView.width / 2
        imageView.layer.masksToBounds = true
        headerView.addSubview(imageView)

        
        StorageManager.shaed.downloadUrl(for: path) { result in
            switch result {
                
            case .success(let url):
                imageView.sd_setImage(with: url)
            case .failure(let error):
                print("Failed to get download url: \(error)")
            }
        }
        
        return headerView
        
    }
    

    
    var data = [ProfileViewModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        data.append(ProfileViewModel(viewModelType: .info,
                                     title: "Name: \(UserDefaults.standard.value(forKey: "name") as? String ?? "No Name")",
                                     handler: nil))
        data.append(ProfileViewModel(viewModelType: .info,
                                     title: "Email: \(UserDefaults.standard.value(forKey: "email") as? String ?? "No Email")",
                                     handler: nil))
        data.append(ProfileViewModel(viewModelType: .logout,
                                     title: "Log Out",
                                     handler: { [weak self] in
            guard let self = self else { return }
            let actionSheet = UIAlertController(title: "Log Out",
                                          message: "Do you want to get out?",
                                          preferredStyle: .actionSheet)
            actionSheet.addAction(UIAlertAction(title: "Log Out",
                                          style: .destructive,
                                                handler: { [weak self] _ in
                guard let self = self else { return }
                
                // Google log out
                GIDSignIn.sharedInstance.signOut()
                
                do {
                    try FirebaseAuth.Auth.auth().signOut()
                   // возвращаемся на экран логина
                    let vc = LoginViewController()
                    let nav = UINavigationController(rootViewController: vc)
                    nav.modalPresentationStyle = .fullScreen
                    self.present(nav, animated: true)
                }
                catch {
                   print("Failed to log out")
                }
            }))
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            present(actionSheet,animated: true)
            
        }))
        
        view.backgroundColor = .white
        title = "Profile"
        // большой тайтл
        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.tableHeaderView = cereateTableHeader()
        setupViews()
        setupConstrains()
        setupDelegate()
        

    }
    
    func setupDelegate() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func setupViews() {
        view.addSubview(tableView)
    }
    
    func setupConstrains() {
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        
        
        ])
    }
    
}
extension ProfileViewController: UITableViewDelegate {
    
    
    
}
extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let viewModel = data[indexPath.row]
      let cell = tableView.dequeueReusableCell(withIdentifier: ProfileTableViewCell.identifire, for: indexPath) as! ProfileTableViewCell
        cell.setUp(with: viewModel)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //отмена выделения строки
        tableView.deselectRow(at: indexPath, animated: true)
        data[indexPath.row].handler?()

    }
  
}

