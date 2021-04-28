//
//  PhotoCollectionViewCell.swift
//  Wechat
//
//  Created by Max Wen on 12/28/20.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "PhotoCollectionViewCell"
    private let postImage:UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.gray.cgColor
//        imageView.layer.cornerRadius = 2
        return imageView
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .white
        contentView.addSubview(postImage)
        contentView.clipsToBounds = true
        postImage.image = UIImage(named: "logo")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        postImage.frame = CGRect(x: 0, y: 0, width: contentView.width, height: contentView.height)

    }
    override func awakeFromNib() {

    }
    
    func setupCell(image:UIImage){
        
        postImage.image = image
    }
    
}
