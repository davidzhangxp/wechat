//
//  UserProfileViewController.swift
//  Wechat
//
//  Created by Max Wen on 12/26/20.
//

import UIKit
import SKPhotoBrowser
import ProgressHUD

class UserProfileViewController: UIViewController {

    private let backgroundView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.backgroundColor = .systemOrange
        return view
    }()
    private let informationLabel:UILabel = {
        let label = UILabel()
        label.text = "Information"
        label.textAlignment = .left
        label.textColor = .black
        label.font = .systemFont(ofSize: 28, weight: .medium)
        return label
    }()

    private let genderLabel:UILabel = {
        let label = UILabel()
        label.text = "Gender:"
        label.textAlignment = .left
        label.textColor = .black
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    private let genderField: UITextField = {
        let field = UITextField()
        field.returnKeyType = .continue
        field.placeholder = "Male or Female"
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        return field
    }()
    private let jobLabel:UILabel = {
        let label = UILabel()
        label.text = "Job:"
        label.textAlignment = .left
        label.textColor = .black
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    private let jobField: UITextField = {
        let field = UITextField()
        field.returnKeyType = .continue
        field.placeholder = "Job title"
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        return field
    }()

    private let aboutLabel:UILabel = {
        let label = UILabel()
        label.text = "About"
        label.layer.masksToBounds = true
        label.textAlignment = .left
        label.textColor = .black
        label.font = .systemFont(ofSize: 28, weight: .medium)
        return label
    }()

    private let aboutTextView: UITextView = {
        let field = UITextView()
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.text = "User information"
        field.backgroundColor = .white
        return field
    }()
    private let ApplyButton: UIButton = {
        let button = UIButton()
        button.setTitle("Apply to add friend", for: .normal)
        button.backgroundColor = .systemRed
        button.isHidden = true
        button.layer.cornerRadius = 20
        return button
    }()
    private let ApprovedButton: UIButton = {
        let button = UIButton()
        button.setTitle("Agree to add friend", for: .normal)
        button.backgroundColor = .systemGreen
        button.isHidden = true
        button.layer.cornerRadius = 20
        return button
    }()
    //MARK:-Vars
    var userObject: FUser?
    var allImages:[UIImage] = []
    private let sectionInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 5.0)
    var isMatch = false
    var needApprove = false
    var collectionView:UICollectionView?
    var alertTextField : UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        layout.itemSize = CGSize(width: view.frame.size.width, height: 380)
        layout.estimatedItemSize = CGSize(width: view.width - 20, height: 200)
        layout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        guard let collectionView = collectionView else {
            return
        }
        collectionView.register(ProfileCollectionViewCell.self, forCellWithReuseIdentifier: ProfileCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        
        checkIsMatch()
        ApplyButton.addTarget(self, action: #selector(sendApplication), for: .touchUpInside)
        ApprovedButton.addTarget(self, action: #selector(approvedFunction), for: .touchUpInside)

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if userObject != nil{
            checkIsMatch()
            showUserDetails()
            loadImage()
            
        }
    }
    

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let scrollView = UIScrollView(frame: view.bounds)
        view.addSubview(scrollView)

        backgroundView.frame = CGRect(x: 0, y: 0, width: scrollView.width, height: 380)
        collectionView!.frame = CGRect(x: 0, y: 0, width: scrollView.width, height: 380)
        informationLabel.frame = CGRect(x: 20, y: backgroundView.bottom + 10, width: view.width - 40, height: 36)
        genderLabel.frame = CGRect(x: 20, y: informationLabel.bottom + 5, width: 75, height: 28)
        genderField.frame = CGRect(x: genderLabel.right + 5, y: informationLabel.bottom + 5, width: view.width - 45 - genderLabel.width, height: 28)
        jobLabel.frame = CGRect(x: 20, y: genderLabel.bottom + 5, width: 75, height: 28)
        jobField.frame = CGRect(x: jobLabel.right + 5, y: genderLabel.bottom + 5, width: view.width - 45 - jobLabel.width, height: 28)
        aboutLabel.frame = CGRect(x: 20, y: jobLabel.bottom + 10, width: view.width - 40, height: 36)
        aboutTextView.frame = CGRect(x: 20, y: aboutLabel.bottom + 5, width: view.width - 40, height: 100)
        ApplyButton.frame = CGRect(x: 20, y: aboutTextView.bottom + 10, width: view.width - 40, height: 40)
        ApprovedButton.frame = CGRect(x: 20, y: aboutTextView.bottom + 10, width: view.width - 40, height: 40)
        scrollView.addSubview(backgroundView)
        backgroundView.addSubview(collectionView!)
        scrollView.addSubview(informationLabel)
        scrollView.addSubview(genderLabel)
        scrollView.addSubview(genderField)
        scrollView.addSubview(jobLabel)
        scrollView.addSubview(jobField)
        scrollView.addSubview(aboutLabel)
        scrollView.addSubview(aboutTextView)
        scrollView.addSubview(ApplyButton)
        scrollView.addSubview(ApprovedButton)
        scrollView.contentSize = CGSize(width: view.width, height: ApplyButton.bottom + 20)
    }
    
    //MARK:- downUser and showUser
    private func showUserDetails(){
        aboutTextView.text = userObject!.about != "" ? userObject!.about : "A little bit about me..."
        jobField.text = userObject!.jobTitle
        genderField.text = userObject!.isMale ? "Male" : "Female"
        aboutTextView.isEditable = false
        jobField.isEnabled = false
        genderField.isEnabled = false
    }
    
    private func loadImage(){
        if userObject?.avatarLink != "" {
            StorageManager.shared.downloadImage(imageUrl: userObject?.avatarLink ?? "") { (avatar) in
                guard let avatar = avatar else {
                    return
                }
                self.allImages = [avatar]
                DispatchQueue.main.async {
                    self.collectionView!.reloadData()
                }
            }
        }
    }
    
    @objc private func approvedFunction(){
        FirebaseListener.shared.saveMatch(userId: userObject!.objectId)
        //add likedUserArray
        saveLikeToUser(userId: userObject!.objectId,message:"")
        gotoChat()
    }

    @objc private func sendApplication(){
        let alerController = UIAlertController(title: "Sending Application", message: "You can leave a messasge", preferredStyle: .actionSheet)
        alerController.addAction(UIAlertAction(title: "Just send application", style: .default, handler: { (alert) in
            self.checkForLikesWith(userId: self.userObject!.objectId,message: "")
        }))
        alerController.addAction(UIAlertAction(title: "Leave message", style: .default, handler: { (alert) in
            self.showMessageField(value: "Message")
        }))
        alerController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (alert) in
            print("cancel")
        }))
        present(alerController, animated: true, completion: nil)
    }

    private func showMessageField(value:String){
        let alertView = UIAlertController(title: "Leave \(value)", message: "Please write your \(value)", preferredStyle: .alert)
        alertView.addTextField { (textField) in
            self.alertTextField = textField
            self.alertTextField.placeholder = "\(value)"
        }
        alertView.addAction(UIAlertAction(title: "Send", style: .destructive, handler: { (action) in
            self.checkForLikesWith(userId: self.userObject!.objectId,message: self.alertTextField.text!)
        }))
        alertView.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertView, animated: true, completion: nil)
    }

    //MARK:- Helpers check like and match
    private func checkForLikesWith(userId: String, message:String){
        if !didLikeuserWith(userId: userId){
            saveLikeToUser(userId: userId,message:message)
            ProgressHUD.showSuccess("You send application successfully")
        }
    }
    //MARK:- Update UI
    private func updateApplyButtonStates(){
        if self.isMatch{
            showStartChatButton()
            ApprovedButton.isHidden = true
            ApprovedButton.isEnabled = false
            ApplyButton.isHidden = true
            ApplyButton.isEnabled = false
        }else if self.needApprove{
            ApplyButton.isEnabled = false
            ApplyButton.isHidden = true
            ApprovedButton.isHidden = false
            ApprovedButton.isEnabled = true
        }else {
            ApplyButton.isEnabled = true
            ApplyButton.isHidden = false
            ApprovedButton.isHidden = true
            ApprovedButton.isEnabled = false
        }
    }
    private func checkIsMatch(){
        if didLikeuserWith(userId: userObject!.objectId){
            FirebaseListener.shared.checkIfUserLikedUs(userId: userObject!.objectId) { (isLike) in
                if isLike {
                    self.isMatch = true
                    self.updateApplyButtonStates()
                }else{
                    self.isMatch = false
                    self.updateApplyButtonStates()
                }
            }
        }else{
            FirebaseListener.shared.checkIfUserLikedUs(userId: userObject!.objectId) { (isLike) in
                if isLike {
                    self.needApprove = true
                    self.updateApplyButtonStates()
                }else{
                    self.needApprove = false
                    self.updateApplyButtonStates()
                }
            }
        }
    }
    private func showStartChatButton(){
        let messageButton = UIBarButtonItem(title: "Send message", style: .done, target: self, action: #selector(startChatButton))
        FirebaseListener.shared.checkIfUserLikedUs(userId: userObject!.objectId) { (isLike) in
            if isLike {
                self.isMatch = true
                self.navigationItem.rightBarButtonItem = self.isMatch ? messageButton : nil
            }else{
                
                self.navigationItem.rightBarButtonItem = self.isMatch ? messageButton : nil
            }
        }
    }
    
    @objc func startChatButton(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.gotoChat()
        }
    }
    private func gotoChat(){
        let chatRoomId = startChat(user1: FUser.currentUser()!, user2: userObject!)

        let chatView = ChatViewController(chatId: chatRoomId, recipientId: userObject!.objectId, recipientName: userObject!.userName)

        chatView.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(chatView, animated: true)
    }
    //MARK:- SKPhotoBrower
    private func showImage(_ images:[UIImage],startIndex: Int){
        var SKImages: [SKPhoto] = []
        for image in images {
            SKImages.append(SKPhoto.photoWithImage(image))
        }
        let browser = SKPhotoBrowser(photos: SKImages)
        browser.initializePageIndex(startIndex)
        self.present(browser, animated: true, completion: nil)
    }
}

extension UserProfileViewController: UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allImages.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfileCollectionViewCell.identifier, for: indexPath) as! ProfileCollectionViewCell
        let countryCity = "Country " + userObject!.country + "," + "City " + userObject!.city
        let nameAge = userObject!.userName
        cell.setupCell(image: allImages[indexPath.row], country: countryCity, nameAge: nameAge, indexPath: indexPath)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        showImage(allImages, startIndex: indexPath.row)
    }
    
}

extension UserProfileViewController:UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.width, height: 380.0)
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        setSelectedPageTo(page: indexPath.row)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}


