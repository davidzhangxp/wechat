//
//  IncomingMessage.swift
//  Wechat
//
//  Created by Max Wen on 12/27/20.
//

import Foundation
import MessageKit
import Firebase

class IncomingMessage{
    var messageColletionView:MessagesViewController
    
    init(collectionView_:MessagesViewController) {
        messageColletionView = collectionView_
    }
    
    func createMessage(messageDictionary:[String:Any])-> MKMessage?{
        let message = Message(dictionary: messageDictionary)
        let mkMessage = MKMessage(message: message)
        if message.type == kPICTURE{
            let photoItem = PhotoMessage(path: message.mediaURL)
            mkMessage.photoItem = photoItem
            mkMessage.kind = MessageKind.photo(photoItem)
            
            StorageManager.shared.downloadImage(imageUrl: messageDictionary[kMEDIAURL] as! String) { (image) in
                mkMessage.photoItem?.image = image
                DispatchQueue.main.async {
                    self.messageColletionView.messagesCollectionView.reloadData()
                }
            }
        }
        return mkMessage
    }
}
