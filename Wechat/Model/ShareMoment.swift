//
//  ShareMoment.swift
//  Wechat
//
//  Created by Max Wen on 12/28/20.
//

import Foundation
import UIKit
import Firebase

class ShareItem {
    
    var objectId: String = ""
    var userId: String = ""
    var userName: String = "" 
    var description: String?
    var imageLinks: [String]?
    var avatarLink:String?
    var date = Date()
    
    var dictionary:NSDictionary{
        return NSDictionary(objects: [self.objectId,
                                      self.userId,
                                      self.userName,
                                      self.description ?? "",
                                      self.imageLinks ?? [],
                                      self.avatarLink ?? "",
                                      self.date
        ], forKeys: [kOBJECTID as NSCopying,kUSERID as NSCopying,kUSERNAME as NSCopying,kDESCRIPTION as NSCopying,kIMAGELINKS as NSCopying,kAVATARLINK as NSCopying,kDATE as NSCopying])
    }
    
    init() {}
    
    init(_dictionary: NSDictionary) {
        objectId = _dictionary[kOBJECTID] as? String ?? ""
        userId = _dictionary[kUSERID] as? String ?? ""
        userName = _dictionary[kUSERNAME] as? String ?? ""
        description = _dictionary[kDESCRIPTION] as? String ?? ""
        imageLinks = _dictionary[kIMAGELINKS] as? [String] ?? []
        avatarLink = _dictionary[kAVATARLINK] as? String ?? ""
        date = (_dictionary[kDATE] as? Timestamp)?.dateValue() ?? Date()
    }
    
    // Save items to firebase
    func saveShareItemToFirebase() {
        FirebaseReference(.ShareItem).document(self.objectId).setData(self.dictionary as! [String:Any])
    }
    
    func deletShareItem(){
        FirebaseReference(.ShareItem).document(self.objectId).delete()
    }
}
