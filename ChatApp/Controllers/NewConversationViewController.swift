//
//  NewConversationViewController.swift
//  ChatApp
//
//  Created by Василий Тихонов on 14.06.2024.
//

import UIKit
import JGProgressHUD

class NewConversationViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private var users = [[String: String]]()
    private var results = [[String: String]]()
    private var hasFetched = false
    
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        
        searchBar.placeholder = "Search for Users..."
        return searchBar
    }()
    
    private let tableView: UITableView = {
     let tableView = UITableView()
        tableView.isHidden = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "NewConversationCell")
        return tableView
    }()
    
    private let noResultsLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = "No Results"
        label.textAlignment = .center
        label.textColor = .green
        label.font = .systemFont(ofSize: 21,weight: .medium)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        searchBar.delegate = self
        view.backgroundColor = .white
        
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(dismissSelf))
        // чтобы клавиатура сразу вылезала
        searchBar.becomeFirstResponder()
        
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.frame = view.bounds
        noResultsLabel.frame = CGRect(x: view.width/4,
                                      y: (view.height-200)/2,
                                      width: view.width/2,
                                      height: 200)
    }
    
    
    
    func setupViews() {
        view.addSubview(noResultsLabel)
        view.addSubview(tableView)
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    @objc func dismissSelf() {
        dismiss(animated: true)
    }
    
    
}
extension NewConversationViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else { return }
        
        
        searchBar.resignFirstResponder()
        
        results.removeAll()
        spinner.show(in: view)
        self.searchUsers(query: text)
    }
    
    func searchUsers(query: String) {
        // check if array has fiebase result
        if hasFetched {
         // if it does : filter
            filterUsers(with: query)
        } else {
            // if not,fetch then filter
            DatabaseManager.shared.getAllUsers {[weak self] result in
              //  guard let self = self else { return }
                switch result {
                    
                case .success(let usersCollection):
                    self?.hasFetched = true
                    self?.users = usersCollection
                    self?.filterUsers(with: query)
                    
                case .failure(let error):
                    print("Failed to get users: \(error)")
                    
                }
            }
        }
    }
    
    func filterUsers(with term: String) {
        // update te UI : either show results or show no results label

        guard hasFetched else {
            return
        }
        self.spinner.dismiss()
        
        let results: [[String:String]] = self.users.filter {
            guard let name = $0["name"]?.lowercased() else {
                return false
            }
            return name.hasPrefix(term.lowercased())
        }
        
        self.results = results
        updateUI()
    }
     func updateUI() {
         if results.isEmpty {
             self.noResultsLabel.isHidden = false
             self.tableView.isHidden = true
         }
         else {
             self.noResultsLabel.isHidden = true
             self.tableView.isHidden = false
             self.tableView.reloadData()
         }
    }
 
}

extension NewConversationViewController: UITableViewDelegate {
    
}
extension NewConversationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewConversationCell", for: indexPath)
        
        cell.textLabel?.text = results[indexPath.row]["name"]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // start conversetion
    }
    
    
}
