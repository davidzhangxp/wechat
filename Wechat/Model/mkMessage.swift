//
//  mkMessage.swift
//  Wechat
//
//  Created by Max Wen on 12/27/20.
//

import Foundation
import MessageKit
import UIKit

struct MKSender :SenderType,Equatable{
    var senderId: String
    var displayName: String
}

class MKMessage:NSObject,MessageType{
    
    var sender: SenderType {return mksender}
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
    var incoming: Bool
    var mksender: MKSender
    var sengderInitials: String
    //photo
    var photoItem:PhotoMessage?
    var avatarLink:String?
    var status: String
    
    init(message:Message) {
        self.messageId = message.id
        self.mksender = MKSender(senderId: message.senderId, displayName: message.senderName)
        self.status = message.status
        self.kind = MessageKind.text(message.message)
        self.sengderInitials = message.senderInitials
        self.sentDate = message.sentDate
        self.incoming = FUser.currentId() != mksender.senderId
        self.avatarLink = message.avatarLink
    }
    
}

enum MessageDefaults {
    static let bubbleColorOutgoing = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
    static let bubbleColorIncoming = UIColor(red: 230/255, green: 229/255, blue: 231/255, alpha: 1)
}

