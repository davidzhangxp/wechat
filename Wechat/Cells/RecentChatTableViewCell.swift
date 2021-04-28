//
//  RecentChatTableViewCell.swift
//  Wechat
//
//  Created by Max Wen on 12/26/20.
//

import UIKit

class RecentChatTableViewCell: UITableViewCell {

    static let identifier = "RecentChatTableViewCell"
    
    private let avatarImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "logo")
        imageView.layer.cornerRadius = 30
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let userNameLabel:UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        
        return label
    }()
    private let lastMessageLabel:UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        
        label.numberOfLines = 1
        return label
    }()
    private let unreadMessageCountLabel:UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.backgroundColor = .red
        label.textColor = .white
        label.textAlignment = .center
        label.layer.masksToBounds = true
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    private let dateLabel:UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.adjustsFontSizeToFitWidth = true
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
        contentView.addSubview(avatarImageView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(lastMessageLabel)
        contentView.addSubview(unreadMessageCountLabel)
        contentView.addSubview(dateLabel)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        avatarImageView.frame = CGRect(x: 10, y: 10, width: 60, height: 60)
        userNameLabel.frame = CGRect(x: avatarImageView.right + 10,
                                     y: 5,
                                     width: contentView.width - avatarImageView.width - 60,
                                     height: 30)
        lastMessageLabel.frame = CGRect(x: avatarImageView.right + 10,
                                        y: userNameLabel.bottom + 5,
                                        width: contentView.width - avatarImageView.width - 60,
                                        height: contentView.height - 40)
        unreadMessageCountLabel.frame = CGRect(x: userNameLabel.right + 5, y: 10, width: 30, height: 30)
        unreadMessageCountLabel.layer.cornerRadius = 15
        dateLabel.frame = CGRect(x: lastMessageLabel.right + 5, y: unreadMessageCountLabel.bottom + 5, width: 45, height: 30)
    }
    
    func generateCell(recentChat: RecentChat){
        userNameLabel.text = recentChat.receiverName
        lastMessageLabel.text = recentChat.lastMessage
        lastMessageLabel.adjustsFontSizeToFitWidth = false
        if recentChat.unreadCounter != 0 {
            self.unreadMessageCountLabel.text = "\(recentChat.unreadCounter)"
            self.unreadMessageCountLabel.isHidden = false
       
        }else{
            self.unreadMessageCountLabel.isHidden = true
            
        }
        if recentChat.avatarLink != ""{
            setAvatar(avatarLink: recentChat.avatarLink)
        }
        
        dateLabel.text = timeElapsed(recentChat.date)
        dateLabel.adjustsFontSizeToFitWidth = true
        
    }
    
    private func setAvatar(avatarLink:String){
        StorageManager.shared.downloadImage(imageUrl: avatarLink) { (avatarImage) in
            if avatarImage != nil{
                DispatchQueue.main.async {
                    self.avatarImageView.image = avatarImage?.circleMasked
                }
            }
        }
    }
    
    func timeElapsed(_ date:Date)->String{
        let seconds = Date().timeIntervalSince(date)
        var dateText = ""
        if seconds < 60 {
            dateText = "Just now"
        }else if seconds < 3600 {
            let minutes = Int(seconds/60)
            let minText = minutes > 1 ? "mins" : "min"
            dateText = "\(minutes) \(minText)"
        }else if seconds < 24 * 3600 {
            let hours = Int(seconds/3600)
            let hourText = hours > 1 ? "hours" : "hour"
            dateText = "\(hours) \(hourText)"
        }else{
            dateText = date.longDate()
        }
        
        return dateText
    }

}





