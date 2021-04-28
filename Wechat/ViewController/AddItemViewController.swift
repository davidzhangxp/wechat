//
//  AddItemViewController.swift
//  Wechat
//
//  Created by Max Wen on 12/28/20.
//

import UIKit
import Gallery
import JGProgressHUD
import MobileCoreServices

class AddItemViewController: UIViewController {

    private let textView : UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .white
        textView.text = "Say something ..."
        textView.layer.cornerRadius = 5
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.lightGray.cgColor
        return textView
    }()

    
    //Vars
    private let sectionInsets = UIEdgeInsets(top: 2.0, left: 2.0, bottom: 2.0, right: 2.0)
    let spinner = JGProgressHUD(style: .dark)
    var gallery: GalleryController!
    var itemImages: [UIImage?] = []
    var collectionView:UICollectionView?
    var addPhotoImage:UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(saveToFirebase))


        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 2
        layout.scrollDirection = .vertical
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        guard let collectionView = collectionView else {
            return
        }
        collectionView.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: PhotoCollectionViewCell.identifier)
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
        collectionView.dragInteractionEnabled = true
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.addSubview(textView)

        guard let collectionView = collectionView else {
            return
        }
        textView.frame = CGRect(x: 20, y: 15, width: view.width - 40, height: 120)

        collectionView.frame = CGRect(x: 20, y: textView.bottom + 18, width: view.width - 40, height: view.width - 40)

    }
    
    //Save Item
    @objc private func saveToFirebase(){
        
        spinner.show(in: view)
        let item = ShareItem()
        item.objectId = UUID().uuidString
        item.userId = FUser.currentId()
        item.userName = FUser.currentUser()?.userName ?? ""
        item.description = textView.text
        item.avatarLink = FUser.currentUser()?.avatarLink ?? ""
        item.date = Date()

        if itemImages.count > 0 {
            itemImages.remove(at: itemImages.count - 1)
 
            StorageManager.shared.uploadShareItemImages(images: itemImages) { (imageLinkArray) in
                item.imageLinks = imageLinkArray
                item.saveShareItemToFirebase()
                self.spinner.dismiss()
                self.navigationController?.popViewController(animated: true)
            }
        }else {
                item.saveShareItemToFirebase()
                self.spinner.dismiss()
                self.navigationController?.popViewController(animated: true)
        }
    }
    //Show Gallery
    @objc private func showCameraGallery(){
        self.gallery = GalleryController()
        self.gallery.delegate = self
        
        Config.tabsToShow = [.imageTab,.cameraTab]
        Config.Camera.imageLimit = 10 - itemImages.count
        self.present(self.gallery, animated: true, completion: nil)
        
    }
}



extension AddItemViewController: UICollectionViewDelegate,UICollectionViewDataSource{
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
        if (indexPath.row == itemImages.count - 1){
            showCameraGallery()
            
        }
    }
}

extension AddItemViewController:UICollectionViewDelegateFlowLayout{
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

extension AddItemViewController: GalleryControllerDelegate {
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        if images.count > 0 {
            Image.resolve(images: images) { (resolvedImages) in
                self.itemImages.insert(contentsOf: resolvedImages, at: self.itemImages.count - 1)
                self.collectionView?.reloadData()
            }
        }
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension AddItemViewController:UICollectionViewDragDelegate{

    func collectionView(_ collectionView: UICollectionView, itemsForBeginning
                            session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        if indexPath.row != itemImages.count - 1 {
            let provider = NSItemProvider(object: itemImages[indexPath.row]!)
            let dragItem = UIDragItem(itemProvider: provider)
            return [dragItem]
        }
        return []
    }
//    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo
//      session: UIDragSession, at indexPath: IndexPath, point: CGPoint) ->
//        [UIDragItem] {
//
//        let provider = NSItemProvider(object: itemImages[indexPath.row]!)
//        let dragItem = UIDragItem(itemProvider: provider)
//        return [dragItem]
//    }
    
}

extension AddItemViewController:UICollectionViewDropDelegate{
    
    func collectionView(_ collectionView: UICollectionView, canHandle
                               session: UIDropSession) -> Bool {

        return session.hasItemsConforming(toTypeIdentifiers:
                        [kUTTypeImage as String])
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith
                             coordinator: UICollectionViewDropCoordinator) {

        let destinationIndexPath =
           coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)

        switch coordinator.proposal.operation {
//            case .copy:
//
//                let items = coordinator.items
//
//                for item in items {
//                    item.dragItem.itemProvider.loadObject(ofClass: UIImage.self,
//                completionHandler: {(newImage, error)  -> Void in
//
//                    if var image = newImage as? UIImage {
//                        if image.size.width > 200 {
//                            image = self.scaleImage(image: image, width: 200)
//
//                        }
//
//                        self.itemImages.insert(image, at: destinationIndexPath.item)
//
//                        DispatchQueue.main.async {
//                            collectionView.insertItems(
//                                    at: [destinationIndexPath])
//                        }
//                    }
//                })
//            }
        case .move:

                    let items = coordinator.items

                    for item in items {

                        guard let sourceIndexPath = item.sourceIndexPath
                        else { return }

                        collectionView.performBatchUpdates({

                            let moveImage = itemImages[sourceIndexPath.item]
                            itemImages.remove(at: sourceIndexPath.item)
                            itemImages.insert(moveImage, at: destinationIndexPath.item)

                            collectionView.deleteItems(at: [sourceIndexPath])
                            collectionView.insertItems(at: [destinationIndexPath])
                        })
                        coordinator.drop(item.dragItem,
                                         toItemAt: destinationIndexPath)
                    }
        default: return
        }
    }

    func scaleImage (image:UIImage, width: CGFloat) -> UIImage {
        let oldWidth = image.size.width
        let scaleFactor = width / oldWidth

        let newHeight = image.size.height * scaleFactor
        let newWidth = oldWidth * scaleFactor

        UIGraphicsBeginImageContext(CGSize(width:newWidth, height:newHeight))
        image.draw(in: CGRect(x:0, y:0, width:newWidth, height:newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate
      session: UIDropSession, withDestinationIndexPath destinationIndexPath:
       IndexPath?) -> UICollectionViewDropProposal {

        if session.localDragSession != nil {
            return UICollectionViewDropProposal(operation: .move,
                    intent: .insertAtDestinationIndexPath)
        } else {
            return UICollectionViewDropProposal(operation: .copy,
                    intent: .insertAtDestinationIndexPath)
        }
    }


}
