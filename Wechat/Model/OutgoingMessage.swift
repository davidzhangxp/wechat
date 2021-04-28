//
//  OutgoingMessage.swift
//  Wechat
//
//  Created by Max Wen on 12/27/20.
//

import Foundation
import UIKit

class OutgoingMessage {
    var messageDictionary: [String:Any]
    //MARK:-Initializers
    init(message:Message,text:String,memberIds:[String]){
        message.type = kTEXT
        message.message = text
        
        messageDictionary = message.dictionary as! [String:Any]
    }
    init(message:Message,photo:UIImage,photoURL:String,memberIds:[String]) {
        message.type = kPICTURE
        message.message = "Picture Message"
        message.photoWidth = Int(photo.size.width)
        message.photoHeight = Int(photo.size.height)
        message.mediaURL = photoURL
        messageDictionary = message.dictionary as! [String:Any]
    }
    
    class func send(chatId:String,text:String?,photo:UIImage?,memberIds:[String]){
        let currentUser = FUser.currentUser()!
        let message = Message()
        message.id = UUID().uuidString
        message.chatRoomId = chatId
        message.senderId = currentUser.objectId
        message.senderName = currentUser.userName
        
        message.sentDate = Date()
        message.senderInitials = String(currentUser.userName.first!)
        message.status = kSENT
        message.message = text ?? "picture message"
        message.avatarLink = currentUser.avatarLink

        if text != nil {
            let outgoingMessage = OutgoingMessage(message: message, text: text!, memberIds: memberIds)
            outgoingMessage.sendMessage(chatRoomId: chatId, messageId: message.id, memberIds: memberIds)

        }else{
            //picture message
            if photo != nil{
                StorageManager.shared.uploadImage(image: photo!) { (imageURL) in
                    if imageURL != nil{
                        let outgoingMessage = OutgoingMessage(message: message, photo: photo!, photoURL: imageURL, memberIds: memberIds)
                        outgoingMessage.sendMessage(chatRoomId: chatId, messageId: message.id, memberIds: memberIds)
                    }
                }
            }
        }
        //send push notification
        FirebaseListener.shared.updateRecents(chatRoomId: chatId, lastMessage: message.message)
    }
    
    
    func sendMessage(chatRoomId:String,messageId:String,memberIds:[String]){
        for userId in memberIds{
            FirebaseReference(.Messages).document(userId).collection(chatRoomId).document(messageId).setData(messageDictionary)
        }
    }
    
    class func updateMessageStatus(withId:String,chatRoomId:String,memberIds:[String]){
        let values = [kSTATUS:kREAD] as [String:Any]
        for userId in memberIds {
            FirebaseReference(.Messages).document(userId).collection(chatRoomId).document(withId).updateData(values)
        }
    }
}
