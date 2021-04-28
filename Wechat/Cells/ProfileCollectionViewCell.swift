//
//  ProfileCollectionViewCell.swift
//  Wechat
//
//  Created by Max Wen on 12/26/20.
//


import UIKit

class ProfileCollectionViewCell: UICollectionViewCell {
    static let identifier = "CustomCollectionViewCell"
    private let profileImage:UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.gray.cgColor
        imageView.layer.cornerRadius = 6
        return imageView
    }()

    private let backgroundPlaceholder :UIImageView = {
        let imageView = UIImageView()

        imageView.clipsToBounds = true
        return imageView
    }()
    private let nameAgeLabel :UILabel = {
        let label = UILabel()
        label.text = "Name and Age"
        label.tintColor = .white
        label.textColor = .white
        label.textAlignment = .left
        return label
    }()
    private let cityCountryLabel :UILabel = {
        let label = UILabel()
        label.text = "Country and city"
        label.tintColor = .white
        label.textColor = .white
        label.textAlignment = .left
        return label
    }()
    var indexPath: IndexPath!
    let gradientLayer = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .white
        contentView.addSubview(profileImage)
        profileImage.addSubview(backgroundPlaceholder)
        profileImage.addSubview(nameAgeLabel)
        profileImage.addSubview(cityCountryLabel)
        contentView.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        profileImage.frame = CGRect(x: 0, y: 0, width: contentView.width, height: contentView.height)
        backgroundPlaceholder.frame = CGRect(x: 5, y: contentView.height - 100 , width: contentView.frame.size.width - 10, height: 100)
        nameAgeLabel.frame = CGRect(x: 20, y: contentView.height - 80, width: contentView.width - 40, height: 32)
        cityCountryLabel.frame = CGRect(x: 20, y: contentView.height - 40, width: contentView.width - 40, height: 30)
    }
    

    
    override func awakeFromNib() {

    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if indexPath.row == 0 {
            backgroundPlaceholder.isHidden = false
            setGradientBackground()
        }else{
            backgroundPlaceholder.isHidden = true
        }
    }
    

    func setupCell(image:UIImage,country:String,nameAge:String,indexPath:IndexPath){
        self.indexPath = indexPath
        profileImage.image = image
        nameAgeLabel.text = nameAge
        cityCountryLabel.text = country
        
    }
    func setGradientBackground(){
        gradientLayer.removeFromSuperlayer()
        let colorTop = UIColor.clear.cgColor
        let colorBottom = UIColor.black.cgColor
        
        gradientLayer.colors = [colorTop,colorBottom]
        gradientLayer.locations = [0.0,1.0]
        gradientLayer.cornerRadius = 5
        gradientLayer.maskedCorners = [.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
        gradientLayer.frame = self.backgroundPlaceholder.bounds
        self.backgroundPlaceholder.layer.insertSublayer(gradientLayer, at: 0)
    }
    
}
