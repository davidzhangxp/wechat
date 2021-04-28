//
//  ContactsViewController.swift
//  Wechat
//
//  Created by Max Wen on 12/25/20.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class ContactsViewController: UIViewController {

    let spinner = JGProgressHUD(style: .dark)
    
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
    private let imageView:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "logo")
        imageView.layer.cornerRadius = 30
        imageView.layer.masksToBounds = true
        return imageView
    }()
    private var newFriendButton: UIButton = {
        let button = UIButton()
        button.setTitle("New Friends", for: .normal)
//        button.backgroundColor = .systemOrange
        button.titleLabel?.font = .systemFont(ofSize: 24, weight: .bold)
        button.setTitleColor(.darkGray, for: .normal)
        button.contentHorizontalAlignment = .left
        return button
    }()
    private let messageCountLabel:UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.backgroundColor = .orange
        label.textColor = .white
        label.textAlignment = .center
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 15
        label.adjustsFontSizeToFitWidth = true
        label.isHidden = true
        return label
    }()
    private let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    private var tableView:UITableView = {
        let table = UITableView()
        table.register(ContactsTableViewCell.self,forCellReuseIdentifier:ContactsTableViewCell.identifier)
        return table
    }()
    //MARK:- Vars
    var allUsers:[FUser] = []
    var userSection = [String]()
    var userDictionary = [String:[FUser]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Contacts"

        validateAuth()
        
        tableView.tableFooterView = UIView()

        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(tableView)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewContact))
        searchBarButton.addTarget(self, action: #selector(showSearchContactView), for: .touchUpInside)
        newFriendButton.addTarget(self, action: #selector(showApplicationView), for: .touchUpInside)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        downloadMessageCounter()
        downloadMatches()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        view.addSubview(tableView)
        view.addSubview(imageView)
        view.addSubview(newFriendButton)
        view.addSubview(searchBarButton)
        view.addSubview(messageCountLabel)
        view.addSubview(lineView)
        searchBarButton.frame = CGRect(x: 0, y: 5, width: view.width, height: 32)
        imageView.frame = CGRect(x: 10, y: searchBarButton.bottom + 15, width: 60, height: 60)
        newFriendButton.frame = CGRect(x: imageView.right + 5, y: searchBarButton.bottom + 15, width: view.width - 75 - 30, height: 60)
        messageCountLabel.frame = CGRect(x: view.right - 45, y: searchBarButton.bottom + 30, width: 30, height: 30)
        lineView.frame = CGRect(x: 10, y: imageView.bottom + 6, width: view.width - 10, height: 1)
        tableView.frame = CGRect(x: 0, y: newFriendButton.bottom + 10, width: view.width, height: view.height - 15 - newFriendButton.height)
    }
    
    @objc private func addNewContact(){
        //show add new user view
        let vc = AddNewContactViewController()
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    @objc private func showSearchContactView(){
        let vc = SearchContactsViewController()
        let nav = UINavigationController(rootViewController: vc)
        vc.users = self.allUsers
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    @objc private func showApplicationView(){
        let vc = NewFriendApplicationViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    

    //MARK:-download
    private func downloadMatches(){
        FirebaseListener.shared.downloadUserMatches { (matchedUserIds) in
            if matchedUserIds.count > 0 {
                FirebaseListener.shared.downloadUsersFromFirebase(withIds: matchedUserIds) { (allUsers) in
                    self.allUsers = allUsers
                    self.sortUser()
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }else{
                print("no matches")
            }
        }
    }
    

    
    private func downloadMessageCounter(){
        FirebaseListener.shared.downloadLikedUsers { (allUserIds) in
            var applicationUserIds:[String] = []
            if allUserIds.count > 0 {
                FirebaseListener.shared.downloadUserMatches { (matchUserIds) in
                    for userId in allUserIds{
                        if !matchUserIds.contains(userId){
                            applicationUserIds.append(userId)
                            if applicationUserIds.count != 0 {
                                DispatchQueue.main.async {
                                    self.messageCountLabel.text = "\(applicationUserIds.count)"
                                    self.messageCountLabel.isHidden = false
                                }
                            }else{
                                DispatchQueue.main.async {
                                    self.messageCountLabel.isHidden = true
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    //MARK:-Auth
    private func validateAuth(){
        if FirebaseAuth.Auth.auth().currentUser == nil{
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true, completion: nil)
        }
    }
    //MARK:-Navigation
    private func showUserProfile(user:FUser){
        let vc = UserProfileViewController()
        vc.userObject = user
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func removeLikesFromFUser(userId: String) {
        let user = FUser.currentUser()!
        for i in 0..<user.likedIdArray!.count {
            if userId == user.likedIdArray![i]{
                user.likedIdArray!.remove(at: i)
                user.saveUserLocally()
                user.saveUserToFirestore()
                return
            }
        }
    }
    
    private func sortUser(){
        for user in allUsers{
            let key = "\(user.userName[user.userName.startIndex])".uppercased()
            if var userValue = self.userDictionary[key]{
                userValue.append(user)
                self.userDictionary[key]!.append(user)
            }else{
                //create new dictionary
                self.userDictionary[key] = [user]
            }
            self.userSection = [String](self.userDictionary.keys).sorted()
        }
    }

}

extension ContactsViewController: UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.userSection.count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return userSection[section].uppercased()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let userkey = userSection[section]
        if let users = userDictionary[userkey]{
            return users.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ContactsTableViewCell.identifier, for: indexPath) as! ContactsTableViewCell
        
        let userKey = self.userSection[indexPath.section]
        if let model = self.userDictionary[userKey.uppercased()]{

        cell.accessoryType = .disclosureIndicator
            cell.configure(with: model[indexPath.row])
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let userKey = self.userSection[indexPath.section]
        if let model = self.userDictionary[userKey.uppercased()]{
            showUserProfile(user: model[indexPath.row])
        }
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete{
//
//            let userId = self.allUsers[indexPath.row].objectId
//            self.allUsers.remove(at: indexPath.row)
//            tableView.reloadData()
//            self.removeLikesFromFUser(userId: userId)
//
//            FirebaseListener.shared.downloadLikesObjectId(userId: userId) { (snapshot) in
//                let objectId = snapshot.first!
//                FirebaseReference(.Like).document(objectId).delete()
//            }
//
//        }
    }
}


