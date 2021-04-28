//
//  LikeObject.swift
//  Wechat
//
//  Created by Max Wen on 12/26/20.
//

import Foundation

struct LikeObject {
    let id: String
    let userId: String
    let likedUserId: String
    let date: Date
    let message: String
    
    var dictionary: [String : Any] {
        return [kOBJECTID:id,kUSERID: userId, kLIKEDUSERID:likedUserId,kDATE:date,kMESSAGE:message]
    }
    func saveToFirestore(){
        FirebaseReference(.Like).document(self.id).setData(self.dictionary)
    }
    func deletLikeObject(){
        FirebaseReference(.Like).document(self.id).delete()
    }
}
