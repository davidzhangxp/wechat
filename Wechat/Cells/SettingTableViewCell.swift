//
//  SettingTableViewCell.swift
//  Wechat
//
//  Created by Max Wen on 1/2/21.
//

import UIKit

class SettingTableViewCell: UITableViewCell {
    static let identifier = "SettingTableViewCell"
    
    private let iconContainer: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()
    private let iconImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let label:UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label
    }()
    public let mySwitch:UISwitch = {
        let mySwitch = UISwitch()
        mySwitch.onTintColor = .systemBlue
        mySwitch.isOn = false
        mySwitch.isHidden = true
        return mySwitch
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(iconContainer)
        iconContainer.addSubview(iconImageView)
        contentView.addSubview(label)
        contentView.clipsToBounds = true
        contentView.addSubview(mySwitch)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    
    override func layoutSubviews() {
        super.layoutSubviews()
        let size = contentView.height - 12
        iconContainer.frame = CGRect(x: 15, y: 6, width: size, height: size)
        let imageSize = size/1.5
        iconImageView.frame = CGRect(x: (size-imageSize)/2, y: (size-imageSize)/2, width: imageSize, height: imageSize)

        label.frame = CGRect(x: iconContainer.right + 15, y: 0, width: contentView.width - 25 - iconContainer.width, height: contentView.height)
        mySwitch.frame = CGRect(x: contentView.width - mySwitch.width - 20, y: (contentView.height - mySwitch.height)/2, width: mySwitch.width, height: mySwitch.height)
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    public func configure(with model:SettingOption){
        label.text = model.title
        iconImageView.image = model.icon
        iconContainer.backgroundColor = model.iconBackgroundColor
    }

    public func generateCell(with model:SettingSwitchOption){
        label.text = model.title
        iconImageView.image = model.icon
        iconContainer.backgroundColor = model.iconBackgroundColor
        mySwitch.isOn = model.isOn
    }
}
