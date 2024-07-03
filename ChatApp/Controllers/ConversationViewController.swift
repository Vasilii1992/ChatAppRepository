//
//  ViewController.swift
//  ChatApp
//
//  Created by Василий Тихонов on 14.06.2024.
//

import UIKit
import FirebaseAuth
import JGProgressHUD


class ConversationViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private var conversations = [Conversation]()
    
    private let tableView: UITableView = {
          let tableView = UITableView()
          tableView.isHidden = true
          tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ConversationTableViewCell.self,
                           forCellReuseIdentifier: ConversationTableViewCell.identifier)

          return tableView
      }()
    
    private let noConversationsLabel: UILabel = {
        let label = UILabel()
        label.text = "No Conversations!"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // создаем кнопку на навигации справа
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(didTapComposeButton))
        
        title = "Chat"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .white
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.frame = view.bounds
        
        
        noConversationsLabel.frame = CGRect(x: 10,
                                            y: (view.height - 100)/2,
                                            width: view.width - 20,
                                            height: 100)
    }
    
    private var loginObserver: NSObjectProtocol?

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupViews()
        setupTableView()
        validateAuth()
      //  fetchConversations()
        startListeningForConversations()
        
        loginObserver = NotificationCenter.default.addObserver(forName: .didLogInNotification, object: nil, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            self.startListeningForConversations()
        }
        
    }
    
    private func startListeningForConversations() {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else { return }
        
        if let observer = loginObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        DatabaseManager.shared.getAllConversations(for: safeEmail) {[weak self] result in
            switch result {
                
            case .success(let conversations):
                guard !conversations.isEmpty else {
                    self?.tableView.isHidden = true
                    self?.noConversationsLabel.isHidden = false

                    return
                }
                self?.noConversationsLabel.isHidden = true
                self?.tableView.isHidden = false
                self?.conversations = conversations
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
                
                
                
            case .failure(let error):
                self?.tableView.isHidden = true
                self?.noConversationsLabel.isHidden = false
                print("failed to get convos: \(error)")
            }
        }
        
    }
    
    @objc func didTapComposeButton() {
        let vc = NewConversationViewController()
        
        vc.completion = { [weak self] result in
            guard let self = self else { return }
            
            let currentConversations = self.conversations
            if let targetConversation = currentConversations.first(where: {
                $0.otherUserEmail == DatabaseManager.safeEmail(emailAddress: result.email)
            }) {
                let vc = ChatViewController(with: targetConversation.otherUserEmail,id: targetConversation.id)
                vc.isNewConversation = false
                vc.title = targetConversation.name
                vc.navigationItem.largeTitleDisplayMode = .never
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else {
                self.createNewConversation(result: result)
            }
        }
        
        let navVc = UINavigationController(rootViewController: vc)
        present(navVc,animated: true)
    }
    
    private func createNewConversation(result: SearchResult) {
        let name = result.name
        let email = DatabaseManager.safeEmail(emailAddress: result.email)
        
        // check in database if conversation with these two users exist
        // if it does, reuse conversation id
        // otherwise use existing code
        
        DatabaseManager.shared.conversationExist(with: email) { [weak self] result in
            guard let  self = self else {
                return
            }
            switch result {
                
            case .success(let conversationId):
                let vc = ChatViewController(with: email,id: conversationId)
                vc.isNewConversation = false
                vc.title = name
                vc.navigationItem.largeTitleDisplayMode = .never
                self.navigationController?.pushViewController(vc, animated: true)
            case .failure(_):
                let vc = ChatViewController(with: email,id: nil)
                vc.isNewConversation = true
                vc.title = name
                vc.navigationItem.largeTitleDisplayMode = .never
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    private func setupViews() {
        view.addSubview(tableView)
        view.addSubview(noConversationsLabel)
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func validateAuth() {
        
        
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }
        
    }
}

extension ConversationViewController: UITableViewDelegate {
    
}

extension ConversationViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
      if editingStyle == .delete {
          // begin delete
          let conversationId = conversations[indexPath.row].id
          tableView.beginUpdates()
          
          DatabaseManager.shared.deleteConversation(conversationId: conversationId) { [weak self] succses in
              
              if succses {
                  self?.conversations.remove(at: indexPath.row)
                 tableView.deleteRows(at: [indexPath], with: .left)
              }
              
          }

          
          tableView.endUpdates()
      }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = conversations[indexPath.row]
        openConversation(model)

    }
    
    func openConversation(_ model: Conversation) {
        let vc = ChatViewController(with: model.otherUserEmail,id: model.id)
        vc.title = model.name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = conversations[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationTableViewCell.identifier,
                                                 for: indexPath) as! ConversationTableViewCell
        
        
        cell.configure(with: model)

        
        
        return cell
    }
}
