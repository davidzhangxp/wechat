//
//  ShareItemTableViewCell.swift
//  Wechat
//
//  Created by Max Wen on 12/29/20.
//

import UIKit

protocol SelectImageControllerDelegate:class {
    func didClickImage(_ images:[UIImage],startIndex: Int)
    func sharePressed(cell: ShareItemTableViewCell)
}

class ShareItemTableViewCell: UITableViewCell {
    
    static let identifier = "shareItemTableViewCell"
    
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
        label.numberOfLines = 0
        return label
    }()
    
    private let messageLabel:UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let dateLabel:UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        return label
    }()
    
    private let sectionInsets = UIEdgeInsets(top: 1.0, left: 1.0, bottom: 1.0, right: 1.0)
    var collectionView:UICollectionView?
    var itemImages: [UIImage?] = []
    var delegate:SelectImageControllerDelegate?
    
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
        contentView.addSubview(dateLabel)

        contentView.clipsToBounds = true
        setupCollectView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        userImageView.frame = CGRect(x: 10, y: contentView.top + 10, width: 60, height: 60)

        userNameLabel.frame = CGRect(x: userImageView.right + 10,
                                     y: contentView.top + 10,
                                     width: contentView.width - 80,
                                     height: 30)
        messageLabel.frame = CGRect(x: 80,
                                    y:  userNameLabel.bottom + 5,
                                    width: contentView.width - 80,
                                    height: 30)
        collectionView?.frame = CGRect(x: 80,
                                       y: messageLabel.bottom + 5,
                                       width: contentView.width * 2/3,
                                       height: contentView.width * 2/3)
//        dateLabel.frame = CGRect(x: 80, y: collectionView?.bottom ?? messageLabel.bottom + 5, width: 80, height: 16)
        
    }
    
    public func configure(with model:ShareItem){
        self.userNameLabel.text = model.userName
        self.messageLabel.text = model.description
        if model.avatarLink != ""{
            setAvatar(avatarLink: model.avatarLink!)
        }
        if !(model.imageLinks?.isEmpty ?? true){
            setImages(imageArray:model.imageLinks!)
            if model.imageLinks!.count > 6{
                dateLabel.frame = CGRect(x: 80, y: contentView.height - 25, width: 80, height: 16)
                self.contentView.bringSubviewToFront(dateLabel)
            }else if model.imageLinks!.count > 3{
                dateLabel.frame = CGRect(x: 80, y: contentView.height - 25, width: 80, height: 16)
                self.contentView.bringSubviewToFront(dateLabel)
            }else if model.imageLinks!.count > 0{
                dateLabel.frame = CGRect(x: 80, y: contentView.height - 25, width: 80, height: 16)
            self.contentView.bringSubviewToFront(dateLabel)
            }
        }else{
            dateLabel.frame = CGRect(x: 80, y: contentView.height - 25, width: 80, height: 16)
            self.contentView.bringSubviewToFront(dateLabel)
        }
        dateLabel.text = timeElapsed(model.date)
        dateLabel.adjustsFontSizeToFitWidth = true
    }
    
    
    private func setAvatar(avatarLink: String){
        StorageManager.shared.downloadImage(imageUrl: avatarLink) { (avatarImage) in
            DispatchQueue.main.async {
                self.userImageView.image = avatarImage
            }
        }
    }
    private func setImages(imageArray:[String]){
        let imageArray = imageArray.sorted()
        StorageManager.shared.downloadImages(imageUrls: imageArray) { (allImages) in
            DispatchQueue.main.async {
                self.itemImages = allImages
                self.collectionView?.reloadData()
            }
        }
    }
    
    private func setupCollectView(){
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 2
        layout.scrollDirection = .vertical
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        guard let collectionView = collectionView else {
            return
        }
        collectionView.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: PhotoCollectionViewCell.identifier)
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        contentView.addSubview(collectionView)
        
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

extension ShareItemTableViewCell: UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.identifier, for: indexPath) as! PhotoCollectionViewCell
        if itemImages.count > 0 {
            cell.setupCell(image: itemImages[indexPath.row]!)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        delegate?.sharePressed(cell: self)
        delegate?.didClickImage(itemImages as! [UIImage], startIndex: indexPath.row)
    }
}
extension ShareItemTableViewCell:UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: (collectionView.width)/3 - 4, height: (collectionView.width)/3 - 4)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}
