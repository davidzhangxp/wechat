import Foundation
import FirebaseStorage
import ProgressHUD

final class StorageManager {
    
    static let shared = StorageManager()
    private let storage = Storage.storage()
    
    //MARK:-upload avatar/images
    func uploadImages(images:[UIImage?],completion: @escaping (_ imageLinks: [String]) -> Void){
        
            var uploaderImagesCount = 0
            var imageLinkArray: [String] = []
            var nameSuffix = 0
            
            for image in images {
                let fileName = "Images/" + FUser.currentId() + "/" + "\(nameSuffix)" + ".jpg"
                
                saveImageInFirestorage(image:image!, fileName: fileName) { (imageLink) in
                    if imageLink != nil {
                        imageLinkArray.append(imageLink!)
                        
                        uploaderImagesCount += 1
                        if uploaderImagesCount == images.count {
                            completion(imageLinkArray)
                        }
                    }
                }
                nameSuffix += 1
            }
    }
    
    func uploadAvatar(image:UIImage, completion: @escaping (_ avatarLink: String) -> Void){
        ProgressHUD.show()
        let fileName = "Avatars/" + FUser.currentId() + ".jpg"
        
        saveImageInFirestorage(image:image, fileName: fileName) { (avatarLink) in
            ProgressHUD.dismiss()
            if avatarLink != nil {
                completion(avatarLink!)
            }
        }
    }
    func uploadImage(image:UIImage, completion: @escaping (_ imageLink: String) -> Void){
        ProgressHUD.show()
        let fileName = "MediaMesssages/photo/" + FUser.currentId() + "_\(Date().stringDate())" + ".jpg"
        
        saveImageInFirestorage(image:image, fileName: fileName) { (imageLink) in
            ProgressHUD.dismiss()
            if imageLink != nil {
                completion(imageLink!)
            }
        }
    }
    func uploadShareItemImages(images:[UIImage?],completion: @escaping (_ imageLinks: [String]) -> Void){
        
            var uploaderImagesCount = 0
            var imageLinkArray: [String] = []
            var nameSuffix = 0
            
        for image in images {
                let fileName = "ShareItem/" + FUser.currentId() + "\(nameSuffix)" + "/" + "\(Date())" + ".jpg"
                
                saveImageInFirestorage(image:image!, fileName: fileName) { (imageLink) in
                    if imageLink != nil {
                        imageLinkArray.append(imageLink!)
                        
                        uploaderImagesCount += 1
                        if uploaderImagesCount == images.count {
                            completion(imageLinkArray)
                        }
                    }
                }
                nameSuffix += 1
            }
    }


    func saveImageInFirestorage(image: UIImage, fileName: String, completion: @escaping (_ imageLink: String?) -> Void) {
        let imageData = image.jpegData(compressionQuality: 0.6)
        var task: StorageUploadTask!
        
        let storageRef = storage.reference(forURL: kFILEREFERENCE).child(fileName)
        
        task = storageRef.putData(imageData!, metadata: nil, completion: { (metadata, error) in
            
            task.removeAllObservers()
            ProgressHUD.dismiss()
            if error != nil {
                print("Error uploading image", error!.localizedDescription)
                completion(nil)
                return
            }
            
            storageRef.downloadURL { (url, error) in
                guard let downloadUrl = url else {
                    completion(nil)
                    return
                }
                completion(downloadUrl.absoluteString)
            }
        })
        task.observe(StorageTaskStatus.progress) { (snapshot) in
            let progress = snapshot.progress!.completedUnitCount / snapshot.progress!.totalUnitCount
            ProgressHUD.showProgress(CGFloat(progress))
        }
    }
    
    
    //MARK:-download image

    func downloadImages(imageUrls: [String], completion: @escaping (_ images: [UIImage?]) -> Void) {
        var imageArray: [UIImage] = []
        var downloadCounter = 0
        for link in imageUrls {
            let url = NSURL(string: link)
            let downloadQueue = DispatchQueue(label: "imagesDownloadQueue")
            downloadQueue.async {
                downloadCounter += 1
                let data = NSData(contentsOf: url! as URL)
                if data != nil {
                    imageArray.append(UIImage(data: data! as Data)!)
                    
                    if downloadCounter == imageArray.count {
                        DispatchQueue.main.async {
                            completion(imageArray)
                        }
                    }
                } else {
                    print("Couldn't download images")
                    completion(imageArray)
                }
            }
        }
    }

    func downloadImage(imageUrl:String,completion: @escaping (_ image: UIImage?)->Void){
        var image = UIImage()
        let url = NSURL(string: imageUrl)
        let downloadQueue = DispatchQueue(label: "imageDownloadQueue")
        downloadQueue.async {
            let data = NSData(contentsOf: url! as URL)
            if data != nil {
                image = UIImage(data: data! as Data)!
                completion(image)
            }else{
                print("couldn't download image")
                completion(image)
            }
        }
    }
}
