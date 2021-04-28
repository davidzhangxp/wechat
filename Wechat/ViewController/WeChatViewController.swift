//
//  ChatsViewController.swift
//  Wechat
//
//  Created by Max Wen on 12/25/20.
//

import UIKit
import FirebaseAuth

class WeChatViewController: UIViewController {
    
    private var tableView:UITableView = {
        let view = UITableView()
        view.register(RecentChatTableViewCell.self, forCellReuseIdentifier: RecentChatTableViewCell.identifier)
        return view
    }()
    private let searchBarButton :UIButton = {
        let button = UIButton()
        button.setTitle("Search", for: .normal)
        button.setTitleColor(.darkGray, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .systemGray6
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.lightGray.cgColor
        return button
    }()
    
    //MARK:-Vars
    var recentChats:[RecentChat] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "WeChat"
        view.backgroundColor = .white
        validateAuth()
        
        downloadRecentChats()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewContact))
        searchBarButton.addTarget(self, action: #selector(showSearchChatView), for: .touchUpInside)
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.addSubview(tableView)
        view.addSubview(searchBarButton)
 
        searchBarButton.frame = CGRect(x: 0, y: 5, width: view.width, height: 32)
        tableView.frame = CGRect(x: 0, y: searchBarButton.bottom + 10, width: view.width, height: view.height - 47)
        
    }
    
    
    //MARK:-loginAuth
    private func validateAuth(){
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true, completion: nil)
        }
    }
    @objc private func addNewContact(){
        //show add new user view
        let vc = AddNewContactViewController()
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    @objc private func showSearchChatView(){
        let vc = SearchChatViewController()
        let nav = UINavigationController(rootViewController: vc)
        vc.recentChats = self.recentChats
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    //MARK:-download
    
    private func downloadRecentChats(){
        FirebaseListener.shared.downloadRecentChatsFromFirestore { (allChats) in
            self.recentChats = allChats
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    //MARK:- Navigation
    private func goToChat(recent:RecentChat){
        restartChat(chatRoomId: recent.chatRoomId, memerIds: recent.memberIds)
        
        let chatView = ChatViewController(chatId: recent.chatRoomId, recipientId: recent.receiverId, recipientName: recent.receiverName)
        chatView.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(chatView, animated: true)
    }

}
extension WeChatViewController: UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentChats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RecentChatTableViewCell.identifier,for: indexPath) as! RecentChatTableViewCell
        cell.generateCell(recentChat: recentChats[indexPath.row])
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        goToChat(recent: self.recentChats[indexPath.row])
        
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{

            let recent = self.recentChats[indexPath.row]
            self.recentChats.remove(at: indexPath.row)
            recent.deletRecent()
 
            tableView.reloadData()
        }
    }
}
