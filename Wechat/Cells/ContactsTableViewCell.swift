//
//  ContactsTableViewCell.swift
//  Wechat
//
//  Created by Max Wen on 12/25/20.
//

import UIKit

class ContactsTableViewCell: UITableViewCell {

    static let identifier = "contactsTableViewCell"
    
    private let userImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "logo")
        imageView.layer.cornerRadius = 30
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let userNameLabel:UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 26, weight: .semibold)
        return label
    }()

    private let messageLabel:UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(messageLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        userImageView.frame = CGRect(x: 10, y: 10, width: 60, height: 60)
        userNameLabel.frame = CGRect(x: userImageView.right + 10,
                                     y: 10,
                                     width: contentView.width - userImageView.width - 20,
                                     height: contentView.height - 30)
        messageLabel.frame = CGRect(x: userImageView.right + 10,
                                    y: userNameLabel.bottom + 2,
                                     width: contentView.width - userImageView.width - 20,
                                     height: 16)
    }
    public func configure(with model:FUser){
        self.userNameLabel.text = model.userName
        if model.avatarLink != ""{
        setAvatar(avatarLink: model.avatarLink)
        }
    }
    public func generateMessage(with model:FUser){
        setMessage(userId: model.objectId)
    }
    
    private func setAvatar(avatarLink: String){
        StorageManager.shared.downloadImage(imageUrl: avatarLink) { (avatarImage) in
            DispatchQueue.main.async {
                self.userImageView.image = avatarImage
            }
        }
        
    }

    private func setMessage(userId:String){
        FirebaseListener.shared.downloadLikesMessage(userId: userId) { (messageArray) in
            if !messageArray.isEmpty{
                DispatchQueue.main.async {
                    self.messageLabel.text = "Message: " + messageArray.first!
                }
            }
        }
    }
}

