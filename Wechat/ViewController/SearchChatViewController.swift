//
//  SearchChatViewController.swift
//  Wechat
//
//  Created by Max Wen on 12/28/20.
//

import UIKit
import JGProgressHUD

class SearchChatViewController: UIViewController {
    
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
        table.register(RecentChatTableViewCell.self, forCellReuseIdentifier: RecentChatTableViewCell.identifier)
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
    
    //MARK:-Vars
    private let spinner = JGProgressHUD(style: .dark)
    public var recentChats:[RecentChat] = []
    private var results:[RecentChat] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white

        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        tableView.register(RecentChatTableViewCell.self, forCellReuseIdentifier: RecentChatTableViewCell.identifier)
        tableView.tableFooterView = UIView()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissSelf))
        navigationController?.navigationBar.topItem?.titleView = searchBar
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
    

    

    //MARK:- Navigation
    @objc private func dismissSelf(){
        dismiss(animated: true, completion: nil)
    }
    
    private func goToChat(recent:RecentChat){
        restartChat(chatRoomId: recent.chatRoomId, memerIds: recent.memberIds)
        
        let chatView = ChatViewController(chatId: recent.chatRoomId, recipientId: recent.receiverId, recipientName: recent.receiverName)
        chatView.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(chatView, animated: true)
    }

}
extension SearchChatViewController: UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RecentChatTableViewCell.identifier,for: indexPath) as! RecentChatTableViewCell
        cell.generateCell(recentChat: results[indexPath.row])
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        goToChat(recent: self.results[indexPath.row])
        
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{

            let recent = self.results[indexPath.row]
            self.results.remove(at: indexPath.row)
            recent.deletRecent()
 
            tableView.reloadData()
        }
    }
}

extension SearchChatViewController:UISearchBarDelegate{
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
        for recentChat in recentChats {
            if recentChat.receiverName.lowercased().hasPrefix(query.lowercased()){
                self.results.append(recentChat)
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
