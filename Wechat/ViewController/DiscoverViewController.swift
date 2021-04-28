//
//  DiscoverViewController.swift
//  Wechat
//
//  Created by Max Wen on 12/28/20.
//

import UIKit
import Gallery
import FirebaseAuth
import SKPhotoBrowser

class DiscoverViewController: UIViewController {
    
    private var tableView:UITableView = {
        let view = UITableView()
        view.register(ShareItemTableViewCell.self, forCellReuseIdentifier: ShareItemTableViewCell.identifier)
        return view
    }()
    private let cameraButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "camera.fill")
        button.tintColor = .gray
        button.layer.masksToBounds = true
        button.setBackgroundImage(image, for: .normal)
        return button
    }()


    //vars
    var addPhotoImage = UIImage(named: "plus")
    var gallery: GalleryController!
    var shareItems:[ShareItem] = []
    var itemImages:[UIImage?] = []
    var shareItemIds:[String] = []

    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Moments"
        
        validateAuth()
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
        tableView.tableFooterView = UIView()


        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(addTextItem(gestureRecognizer:)))
        longPressGesture.minimumPressDuration = 1.5
        cameraButton.addGestureRecognizer(longPressGesture)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(actionAttachPhoto))
        cameraButton.addGestureRecognizer(tapGesture)
        //3. Create A UIBarButton Item & Initialize With The UIButton
        let barButton = UIBarButtonItem(customView: cameraButton)
        //4. Add It To The Navigation Bar
        navigationItem.rightBarButtonItem = barButton
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        downloadAllShareItems()

    }

    private func validateAuth(){
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true, completion: nil)
        }
    }
    @objc private func addTextItem(gestureRecognizer:UILongPressGestureRecognizer){
        if gestureRecognizer.state == .began {
            let vc = AddItemViewController()
            navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    @objc private func actionAttachPhoto(){
        let alerController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alerController.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (alert) in
            self.showImageGalleryFor(camera: true)
        }))
        alerController.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (alert) in
            self.showImageGalleryFor(camera: false)
        }))

        alerController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (alert) in
            print("cancel")
        }))
        present(alerController, animated: true, completion: nil)
        
    }

    //MARK:- Gallery
    private func showImageGalleryFor(camera:Bool){
        self.gallery = GalleryController()
        self.gallery.delegate = self
        
        Config.tabsToShow = camera ? [.cameraTab] : [.imageTab]
        Config.Camera.imageLimit = 6
        Config.initialTab = .cameraTab
        self.present(gallery, animated: true, completion: nil)
    }
    //MARK:-Download shareItems from firebase
    private func downloadAllShareItems(){
        FirebaseListener.shared.downloadShareIdsFromFirebase { (allShareItemIds) in
            FirebaseListener.shared.downloadShareItemsFromFirebase(withIds: allShareItemIds) { (allShareItems) in
                self.shareItems = allShareItems
                self.downloadSelfShareItems()
            }
        }
    }
    
    private func downloadSelfShareItems(){
        FirebaseListener.shared.downloadShareItemIds(with: FUser.currentId()) { (shareObjectIds) in
            FirebaseListener.shared.downloadShareItemsFromFirebase(withIds: shareObjectIds) { (allItems) in
                self.shareItems += allItems
                self.shareItems = self.shareItems.sorted(by: { $0.date > $1.date })
                self.tableView.reloadData()
            }
        }
    }
    //MARK:- SKPhotoBrower
    public func showImage(_ images:[UIImage],startIndex: Int){
        var SKImages: [SKPhoto] = []
        for image in images {
            SKImages.append(SKPhoto.photoWithImage(image))
        }
        let browser = SKPhotoBrowser(photos: SKImages)
        
        browser.initializePageIndex(startIndex)
        self.present(browser, animated: true, completion: nil)
    }

}
extension DiscoverViewController: UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shareItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ShareItemTableViewCell.identifier,for: indexPath) as! ShareItemTableViewCell
        
        cell.delegate = self
        cell.configure(with: shareItems[indexPath.row])

        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = ItemDetailViewController()
        vc.shareItem = shareItems[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if shareItems[indexPath.row].imageLinks != nil{
            if shareItems[indexPath.row].imageLinks!.count > 6{
                return 360
            }else if shareItems[indexPath.row].imageLinks!.count > 3{
                return 286
            }else if shareItems[indexPath.row].imageLinks!.count > 0{
                return 200
            }
        }
        return 120
    }
}
extension DiscoverViewController: GalleryControllerDelegate {
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        if images.count > 0 {
            Image.resolve(images: images) { (resolvedImages) in
                self.itemImages = resolvedImages
                self.itemImages.append(self.addPhotoImage)
                let vc = AddItemViewController()
                vc.itemImages = self.itemImages
                vc.addPhotoImage = self.addPhotoImage
                self.navigationController?.pushViewController(vc, animated: true)
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

extension DiscoverViewController:SelectImageControllerDelegate{
    func didClickImage(_ images: [UIImage], startIndex: Int) {
        self.showImage(images, startIndex: startIndex)
    }


    func sharePressed(cell: ShareItemTableViewCell) {
        guard let index = tableView.indexPath(for: cell)?.row else { return }
        //fetch the dataSource object using index
        print(index)
        
    }
    
//    func didClickImage (_ images:[UIImage?],startIndex: Int){
//        DispatchQueue.main.async {
//            print("did you call the function")
//            self.showImage(images as! [UIImage], startIndex: startIndex)
//        }
//
//    }
}
