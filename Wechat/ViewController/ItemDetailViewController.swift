//
//  ItemDetailViewController.swift
//  Wechat
//
//  Created by Max Wen on 12/31/20.
//

import UIKit
import SKPhotoBrowser

class ItemDetailViewController: UIViewController {
    
    private let userAvatarView:UIImageView = {
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
    
    private let textView : UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .white
        textView.layer.cornerRadius = 5
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.lightGray.cgColor
        return textView
    }()
    
    //Vars
    private let sectionInsets = UIEdgeInsets(top: 1.0, left: 1.0, bottom: 1.0, right: 1.0)
    var itemImages: [UIImage?] = []
    var collectionView:UICollectionView?
    var shareItem:ShareItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
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
        view.addSubview(collectionView)
        
        setupUI()
        
    }
    
    
    private func setupUI(){
        view.addSubview(textView)
        view.addSubview(userAvatarView)
        view.addSubview(userNameLabel)
        
        userAvatarView.frame = CGRect(x: 10, y: 10, width: 60, height: 60)
        userNameLabel.frame = CGRect(x: userAvatarView.right + 10, y: 20, width: view.width - 100, height: 30)
        
        if shareItem.description != ""{
            textView.frame = CGRect(x: userAvatarView.right + 5, y: userNameLabel.bottom + 30, width: view.width - 100, height: 120)
            collectionView?.frame = CGRect(x: userAvatarView.right + 5, y: textView.bottom + 15, width: view.width - 100, height: view.width - 100)
            textView.text = shareItem.description
        }else{
            collectionView?.frame = CGRect(x: userAvatarView.right + 10, y: userNameLabel.bottom + 45, width: view.width - 100, height: view.width - 100)
        }
        if shareItem.avatarLink != ""{
            setAvatar(avatarLink: shareItem.avatarLink!)
        }
        userNameLabel.text = shareItem.userName
        if shareItem.imageLinks != nil {
            setImages(imageArray: shareItem.imageLinks!)
        }
    }
    
    private func setAvatar(avatarLink: String){
        StorageManager.shared.downloadImage(imageUrl: avatarLink) { (avatarImage) in
            DispatchQueue.main.async {
                self.userAvatarView.image = avatarImage
            }
        }
    }
    private func setImages(imageArray:[String]){
        StorageManager.shared.downloadImages(imageUrls: imageArray) { (allImages) in
            DispatchQueue.main.async {
                self.itemImages = allImages
                self.collectionView?.reloadData()
            }
        }
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

extension ItemDetailViewController: UICollectionViewDelegate,UICollectionViewDataSource{
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
        if itemImages.count > 0 {
            showImage(itemImages as! [UIImage], startIndex: indexPath.row)
        }
    }
}

extension ItemDetailViewController:UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.width/3 - 4, height: collectionView.width/3 - 4)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}
