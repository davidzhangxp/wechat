//
//  NewFriendApplicationViewController.swift
//  Wechat
//
//  Created by Max Wen on 12/26/20.
//

import UIKit
import JGProgressHUD

class NewFriendApplicationViewController: UIViewController {
    

    private var tableView:UITableView = {
        let view = UITableView()
        view.register(ContactsTableViewCell.self,forCellReuseIdentifier:ContactsTableViewCell.identifier)
        return view
    }()
    //MARK:- Vars
    var allUsers:[FUser] = []
    let spinner = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "New Friends"

        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if FUser.currentUser() != nil{
            downloadLikes()
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        view.addSubview(tableView)
        tableView.frame = view.bounds
    }

    //Load Items
    private func downloadLikes(){
        spinner.show(in: view)
        
        FirebaseListener.shared.downloadLikedUsers { (allUserIds) in
   
            var applicationUserIds:[String] = []
            if allUserIds.count > 0 {
                FirebaseListener.shared.downloadUserMatches { (matchUserIds) in
                    for userId in allUserIds{
                        if !matchUserIds.contains(userId){
                            applicationUserIds.append(userId)

                        }
                    }
                    FirebaseListener.shared.downloadUsersFromFirebase(withIds: applicationUserIds) { (allUsers) in
                        self.spinner.dismiss()
                        self.allUsers = allUsers
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }


    //MARK:-Navigation
    private func showUserProfile(user:FUser){
        let vc = UserProfileViewController()
        vc.userObject = user
        vc.isMatch = false
        vc.needApprove = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension NewFriendApplicationViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = allUsers[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ContactsTableViewCell.identifier, for: indexPath) as! ContactsTableViewCell
        cell.accessoryType = .disclosureIndicator
        cell.configure(with: model)
        cell.generateMessage(with: model)
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        showUserProfile(user: allUsers[indexPath.row])
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

}

