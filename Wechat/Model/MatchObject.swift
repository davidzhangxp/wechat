//
//  MatchObject.swift
//  Wechat
//
//  Created by Max Wen on 12/26/20.
//

import Foundation

struct MatchObject {
    let id: String
    let memberIds: [String]
    let date: Date
    
    var dictionary: [String : Any] {
        return [kOBJECTID:id,kMEMBERIDS:memberIds,kDATE:date]
    }
    func saveToFirestore(){
        FirebaseReference(.Match).document(self.id).setData(self.dictionary)
    }
}
