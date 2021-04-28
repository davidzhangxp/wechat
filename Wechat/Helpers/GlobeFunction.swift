//
//  GlobeFunction.swift
//  Wechat
//
//  Created by Max Wen on 12/26/20.
//

import Foundation
import Firebase

public func saveLikeToUser(userId: String,message:String){

    if let currentUser = FUser.currentUser(){
        
        if !didLikeuserWith(userId: userId){
            let like = LikeObject(id: UUID().uuidString, userId: FUser.currentId(), likedUserId: userId, date: Date(),message: message)
            like.saveToFirestore()
            currentUser.likedIdArray!.append(userId)
//            currentUser.saveUserToFirestore()
                currentUser.updateCurrentUserInFirestore(withValues: [kLIKEDIDARRAY:currentUser.likedIdArray!]) { (error) in
                }
        }
    }
}


func didLikeuserWith(userId: String) -> Bool {
    return FUser.currentUser()?.likedIdArray?.contains(userId) ?? false
}

func removeCurrentUserIdFrom(userIds:[String])->[String]{
    var allIds = userIds
    for id in allIds{
        if id == FUser.currentId(){
            allIds.remove(at: allIds.firstIndex(of: id)!)
        }
        
    }
    
    return allIds
}

//MARK:-Starting chat
func startChat(user1:FUser,user2:FUser) -> String{
    let chatRoomId = chatRoomIdFrom(user1Id: user1.objectId, user2Id: user2.objectId)
    createRecentItems(chatRoomId: chatRoomId, users: [user1,user2])
    return chatRoomId
}

func chatRoomIdFrom(user1Id:String,user2Id:String) -> String{
    var chatRoomId = ""
    let value = user1Id.compare(user2Id).rawValue
    
    chatRoomId = value < 0 ? user1Id + user2Id : user2Id + user1Id
    return chatRoomId
}

func restartChat(chatRoomId:String,memerIds:[String]){
    FirebaseListener.shared.downloadUsersFromFirebase(withIds: memerIds) { (users) in
        if users.count > 0 {
            createRecentItems(chatRoomId: chatRoomId, users: users)
        }
    }
}
//MARK:-RecentChats
func createRecentItems(chatRoomId:String,users:[FUser]){
    var memberIdsToCreateRecent: [String] = []
    for user in users{
        memberIdsToCreateRecent.append(user.objectId)
    }
    FirebaseReference(.Chats).whereField(kCHATROOMID, isEqualTo: chatRoomId).getDocuments { (snapshot, error) in
        guard let snapshot = snapshot else{return}
        if !snapshot.isEmpty {
            memberIdsToCreateRecent = removeMemberWhoHasRecent(snapshot: snapshot, memberIds: memberIdsToCreateRecent)

        }
        for userId in memberIdsToCreateRecent{
            let senderUser = userId == FUser.currentId() ? FUser.currentUser()! : getReceiverFrom(users: users)
            let recieverUser = userId == FUser.currentId() ? getReceiverFrom(users: users) : FUser.currentUser()!
            let recentObject = RecentChat()

            recentObject.objectId = UUID().uuidString
            recentObject.chatRoomId = chatRoomId
            recentObject.senderId = senderUser.objectId
            recentObject.senderName = senderUser.userName
            recentObject.receiverId = recieverUser.objectId
            recentObject.receiverName = recieverUser.userName
            recentObject.date = Date()
            recentObject.memberIds = [senderUser.objectId,recieverUser.objectId]
            recentObject.lastMessage = ""
            recentObject.unreadCounter = 0
            recentObject.avatarLink = recieverUser.avatarLink

            recentObject.saveToFirestore()

        }
    }
}


func removeMemberWhoHasRecent(snapshot:QuerySnapshot,memberIds:[String])->[String]{
    var memberIdsToCreateRecent = memberIds
    for recentData in snapshot.documents {
        let currentRecent = recentData.data() as Dictionary
        if let currentUserId = currentRecent[kSENDERID]{
            if memberIdsToCreateRecent.contains(currentUserId as! String){
                let index = memberIdsToCreateRecent.firstIndex(of: currentUserId as! String)!
                memberIdsToCreateRecent.remove(at: index)
            }
        }
    }
    return memberIdsToCreateRecent
}

func getReceiverFrom(users:[FUser]) ->FUser {
    var allUsers = users
    allUsers.remove(at: allUsers.firstIndex(of: FUser.currentUser()!)!)

    return allUsers.first!
}

