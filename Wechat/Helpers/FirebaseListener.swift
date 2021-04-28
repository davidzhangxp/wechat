//
//  FirebaseListener.swift
//  Wechat
//
//  Created by Max Wen on 12/25/20.
//

import Foundation
import FirebaseFirestore

enum FCollectionReference: String {
    case User
    case Chats
    case Like
    case Match
    case Messages
    case Typing
    case ShareItem
    
}

func FirebaseReference(_ collectionReference: FCollectionReference) -> CollectionReference {
    return Firestore.firestore().collection(collectionReference.rawValue)
}

class FirebaseListener{
    static let shared = FirebaseListener()
    
    private init(){}
    
    //MARK:-FUSER
    func  downloadCurrentUserFromFirebase(userId:String,email:String) {
        FirebaseReference(.User).document(userId).getDocument { (snapshot, error) in
            guard let snapshot = snapshot else {return}
            if snapshot.exists{
                let user = FUser(_dictionary: snapshot.data()! as NSDictionary)
                user.saveUserLocally()
                
            }else{
                if let user = userDefaults.object(forKey: kCURRENTUSER){
                    FUser(_dictionary: user as! NSDictionary).saveUserToFirestore()
                }
            }
        }
    }

    func downloadUsersFromFirebase(withIds:[String],completion:@escaping (_ user:[FUser])->Void){
        var userArray:[FUser] = []
        var counter = 0

        for userId in withIds{
            FirebaseReference(.User).document(userId).getDocument { (snapshot, error) in
                guard let snapshot = snapshot else {return}
                if snapshot.exists{
                    userArray.append(FUser(_dictionary: snapshot.data()! as NSDictionary))
                    counter += 1
                    if counter == withIds.count{
                        completion(userArray)
                    }
                }else{completion(userArray)}
            }
        }
    }

    //MARK:- LIKES

    func checkIfUserLikedUs(userId:String, completion: @escaping (_ didLike: Bool)-> Void){
        FirebaseReference(.Like).whereField(kLIKEDUSERID, isEqualTo: FUser.currentId()).whereField(kUSERID, isEqualTo: userId).getDocuments { (snapshot, error) in
            guard let snapshot = snapshot else {
                return
            }
            completion(!snapshot.isEmpty)
        }
    }


    func downloadLikedUsers(completion: @escaping (_ likedUserIds:[String])-> Void){
        FirebaseReference(.Like).whereField(kLIKEDUSERID, isEqualTo: FUser.currentId()).getDocuments { (snapshot, error) in
            var allLikedIds:[String] = []
            guard let snapshot = snapshot else {
                completion(allLikedIds)
                return
            }
            if !snapshot.isEmpty{
                for likeDict in snapshot.documents{
                    allLikedIds.append(likeDict[kUSERID] as? String ?? "")

                }
                completion(allLikedIds)
            }else{
                completion(allLikedIds)
            }

        }
    }

    func downloadLikesObjectId(userId:String,completion: @escaping (_ likedObjectIds:[String])-> Void){
        FirebaseReference(.Like).whereField(kUSERID, isEqualTo: FUser.currentId()).whereField(kLIKEDUSERID, isEqualTo: userId).getDocuments { (snapshot, error) in
            var allLikedIds:[String] = []
            guard let snapshot = snapshot else {
                completion(allLikedIds)
                return
            }
            if !snapshot.isEmpty{
                for likeDict in snapshot.documents{
                    allLikedIds.append(likeDict[kOBJECTID] as? String ?? "")

                }
                completion(allLikedIds)
            }else{
                completion(allLikedIds)
            }

        }
    }
    func downloadLikesMessage(userId:String,completion:@escaping (_ messageArray:[String])->Void) {
        FirebaseReference(.Like).whereField(kUSERID, isEqualTo: userId).whereField(kLIKEDUSERID, isEqualTo: FUser.currentId()).getDocuments { (snapshot, error) in
 
            var messageArray:[String] = []
            guard let snapshot = snapshot else {
                completion(messageArray)
                return }
            if !snapshot.isEmpty{
                for likeDict in snapshot.documents{
                    messageArray.append(likeDict[kMESSAGE] as? String ?? "")
                    
                }
                completion(messageArray)
            }else{
                completion(messageArray)
            }
        }
    }
    //MARK:- Match
    func saveMatch(userId: String){
        let match = MatchObject(id: UUID().uuidString, memberIds: [FUser.currentId(),userId], date: Date())
        match.saveToFirestore()
    }

    func downloadUserMatches(competion: @escaping (_ matchesuserIds:[String])->Void){

        FirebaseReference(.Match).whereField(kMEMBERIDS, arrayContains: FUser.currentId()).getDocuments { (snapshot, error) in
            var allMatchIds :[String] = []
            guard let snapshot = snapshot else {return}
            if !snapshot.isEmpty{
                for matchDict in snapshot.documents{
                    allMatchIds += matchDict[kMEMBERIDS] as? [String] ?? [""]
                }
                competion(removeCurrentUserIdFrom(userIds: allMatchIds))
            }else{
                print("no matches found")
                competion(allMatchIds)
            }
        }
    }
    //MARK:-RecentChats
    func downloadRecentChatsFromFirestore(completion: @escaping (_ allRecentChats:[RecentChat])->Void){
        FirebaseReference(.Chats).whereField(kSENDERID, isEqualTo: FUser.currentId()).addSnapshotListener { (querySnapshot, error) in
            var recentChats :[RecentChat] = []
            guard let snapshot = querySnapshot else {return}
            if !snapshot.isEmpty{
                for recentDocument in snapshot.documents {
                    if recentDocument[kLASTMESSAGE] as! String != "" && recentDocument[kCHATROOMID] != nil && recentDocument[kOBJECTID] != nil {
                        recentChats.append(RecentChat(recentDocument.data()))
                    }
                }
                recentChats.sort(by: {$0.date > $1.date})
                completion(recentChats)
            }else{
                completion(recentChats)
            }
        }
    }

    func updateRecents(chatRoomId:String,lastMessage:String){
        FirebaseReference(.Chats).whereField(kCHATROOMID, isEqualTo: chatRoomId).getDocuments { (snapshot, error) in
            guard let snapshot = snapshot else{return}
            if !snapshot.isEmpty{
                for recent in snapshot.documents{
                    let recentChat = RecentChat(recent.data())
                    self.updateRecentItem(recent: recentChat, lastMessage: lastMessage)
                }
            }
        }
    }

    func updateRecentItem(recent:RecentChat,lastMessage:String){
        if recent.senderId != FUser.currentId(){
            recent.unreadCounter += 1
        }
        let values = [kLASTMESSAGE:lastMessage,kUNREADCOUNTER:recent.unreadCounter,kDATE:Date()] as [String : Any]
        FirebaseReference(.Chats).document(recent.objectId).updateData(values) { (error) in

        }
    }
    func resetRecentCounter(chatRoomId:String){
        FirebaseReference(.Chats).whereField(kCHATROOMID, isEqualTo: chatRoomId).whereField(kSENDERID, isEqualTo: FUser.currentId()).getDocuments { (snapshot, error) in
            guard let snapshot = snapshot else{return}
            if !snapshot.isEmpty{
                if let recentData = snapshot.documents.first?.data(){
                    let recent = RecentChat(recentData)
                    self.clearUnreadCounter(recent: recent)
                }
            }
        }
    }

    func clearUnreadCounter(recent: RecentChat){
        let values = [kUNREADCOUNTER : 0] as [String:Any]
        FirebaseReference(.Chats).document(recent.objectId).updateData(values) { (error) in

        }
    }
    
    //MARK:-ShareItems
    func downloadShareIdsFromFirebase(completion: @escaping (_ allShareItemIds:[String])->Void){
        var allShareItemIds:[String] = []
        var counter = 0
        downloadUserMatches { (allMatchIds) in
            for matchId in allMatchIds{
                
                self.downloadShareItemIds(with: matchId) { (ItemIds) in
                    counter += 1
                    allShareItemIds += ItemIds as? [String] ?? [""]
                    if counter == allMatchIds.count{
                        completion(allShareItemIds)

                    }
                }
            }

        }
    }
    func downloadShareItemIds(with userId:String,completion:@escaping (_ shareItemIds:[String])->Void){
        var shareItemIds :[String] = []
        
        FirebaseReference(.ShareItem).whereField(kUSERID, isEqualTo: userId).getDocuments { (snapshot, error) in
            guard let snapshot = snapshot else{return}
            if !snapshot.isEmpty{
                for shareItem in snapshot.documents{
                    shareItemIds.append(shareItem[kOBJECTID] as? String ?? "")
                }
                completion(shareItemIds)
            }else{
                completion(shareItemIds)
            }
        }
        
    }

    func downloadShareItemsFromFirebase(withIds:[String],completion:@escaping (_ ShareItem:[ShareItem])->Void){
        var allShareItems:[ShareItem] = []
        var counter = 0

        for userId in withIds{
            FirebaseReference(.ShareItem).document(userId).getDocument { (snapshot, error) in
                guard let snapshot = snapshot else {return}
                if snapshot.exists{
                    allShareItems.append(ShareItem(_dictionary: snapshot.data()! as NSDictionary))
                    counter += 1
                    if counter == withIds.count{
                        completion(allShareItems)
                    }
                }else{completion(allShareItems)}
            }
        }
    }
}


