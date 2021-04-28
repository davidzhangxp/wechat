//
//  ContactsViewController.swift
//  Wechat
//
//  Created by Max Wen on 12/25/20.
//

import UIKit
import JGProgressHUD

class SearchContactsViewController: UIViewController {
    
    private let searchBar :UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.setImage(UIImage(systemName: "magnifyingglass"), for: .search, state: .normal)
        searchBar.placeholder = "Search users"
        searchBar.autocapitalizationType = .none
        return searchBar
    }()

    private let tableView :UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(ContactsTableViewCell.self,forCellReuseIdentifier:ContactsTableViewCell.identifier)
        return table
    }()
    private let noResultsLabel:UILabel = {
        let label = UILabel()
        label.text = "No Results"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
    }()
//MARK:-VARS
    
    private let spinner = JGProgressHUD(style: .dark)
    public var users :[FUser] = []
    private var results = [FUser]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        searchBar.delegate = self
        navigationController?.navigationBar.topItem?.titleView = searchBar
        view.backgroundColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissSelf))
        searchBar.becomeFirstResponder()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.addSubview(tableView)
        view.addSubview(noResultsLabel)
        tableView.frame = view.bounds
        noResultsLabel.frame = CGRect(x: view.width/4,
                                      y: view.height/2,
                                      width: view.width/2,
                                      height: 100)
    }

    @objc private func dismissSelf(){
        dismiss(animated: true, completion: nil)
    }
    //MARK:-Navigation
    private func showUserProfile(user:FUser){
        let vc = UserProfileViewController()
        vc.userObject = user
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension SearchContactsViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ContactsTableViewCell.identifier, for: indexPath) as! ContactsTableViewCell
        cell.configure(with: results[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        showUserProfile(user: results[indexPath.row])
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
}
extension SearchContactsViewController:UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
        searchBar.resignFirstResponder()
        results.removeAll()
        spinner.show(in: view)
        self.searchUsers(query: text)
    }
    func searchUsers(query: String){
        self.spinner.dismiss()
        for user in users {
            if user.userName.lowercased().hasPrefix(query.lowercased()){
                self.results.append(user)
            }
        }
        updateUI()
    }

    func updateUI(){
        if results.isEmpty{
            self.tableView.isHidden = true
            self.noResultsLabel.isHidden = false
            tableView.reloadData()
        }else{
            self.tableView.isHidden = false
            self.noResultsLabel.isHidden = true
            tableView.reloadData()
        }
    }
}
