//
//  FUser.swift
//  Wechat
//
//  Created by Max Wen on 12/25/20.
//

import Foundation
import Firebase
import FirebaseAuth
import UIKit

class FUser: Equatable{
    static func == (lhs: FUser, rhs: FUser) -> Bool {
        lhs.objectId == rhs.objectId
    }

    var objectId: String
    var email: String
    var userName: String
    var dateOfBirth: Date
    var jobTitle:String
    var isMale: Bool
    var about:String
    var city: String
    var country: String
    var avatarLink: String

    var likedIdArray: [String]?
    var imageLinks: [String]?
    var registerDate =  Date()
    var pushId: String?
    
    var userDictionary: NSDictionary{
        return NSDictionary(objects: [
            self.objectId,self.email,self.userName,self.dateOfBirth,self.isMale,self.jobTitle,self.about,self.city,self.country,self.avatarLink,self.likedIdArray ?? [],self.imageLinks ?? [],self.registerDate,self.pushId ?? ""
        ],
                            forKeys: [kOBJECTID as NSCopying,kEMAIL as NSCopying,kUSERNAME as NSCopying,kDATEOFBIRTH as NSCopying,kISMALE as NSCopying,kJOBTITLE as NSCopying,kABOUT as NSCopying,kCITY as NSCopying,kCOUNTRY as NSCopying,kAVATARLINK as NSCopying,kLIKEDIDARRAY as NSCopying,kIMAGELINKS as NSCopying,kREGISTERDATE as NSCopying,kPUSHID as NSCopying
                            ])
    }
    
    init(_objectId:String,_emal:String,_username:String){
        objectId = _objectId
        email = _emal
        userName = _username
        city = ""
        dateOfBirth = Date()
        isMale = true
        jobTitle = ""
        about = ""
        country = ""
        avatarLink = ""
        likedIdArray = []
        imageLinks = []

    }
    init(_dictionary: NSDictionary){
        objectId = _dictionary[kOBJECTID] as? String ?? ""
        email = _dictionary[kEMAIL] as? String ?? ""
        userName = _dictionary[kUSERNAME] as? String ?? ""
        city = _dictionary[kCITY] as? String ?? ""
        
        isMale = _dictionary[kISMALE] as? Bool ?? true
        jobTitle = _dictionary[kJOBTITLE] as? String ?? ""
        about = _dictionary[kABOUT] as? String ?? ""
        country = _dictionary[kCOUNTRY] as? String ?? ""

        avatarLink = _dictionary[kAVATARLINK] as? String ?? ""
        likedIdArray = _dictionary[kLIKEDIDARRAY] as? [String]
        imageLinks = _dictionary[kIMAGELINKS] as? [String]

        pushId = _dictionary[kPUSHID] as? String ?? ""
        
        if let date = _dictionary[kDATEOFBIRTH] as? Timestamp {
            dateOfBirth = date.dateValue()
        }else{
            dateOfBirth = _dictionary[kDATEOFBIRTH] as? Date ?? Date()
        }
    }
    //current info
    class func currentId() -> String {
        if Auth.auth().currentUser != nil {
        return Auth.auth().currentUser!.uid
        }
        return ""
    }
    class func currentUser() -> FUser? {
        if Auth.auth().currentUser != nil {
            if let dictionary = UserDefaults.standard.object(forKey: kCURRENTUSER) {
                return FUser.init(_dictionary: dictionary as! NSDictionary)
            }
        }
        return nil
    }
    
    
    //login
    class func loginUserWith(email: String, password: String, completion: @escaping (_ error: Error?, _ isEmailVerified: Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (authDataResult, error) in
            
            if error == nil {
//                if authDataResult!.user.isEmailVerified {
                    
                    FirebaseListener.shared.downloadCurrentUserFromFirebase(userId:authDataResult!.user.uid,email:email)
                    
                    completion(error,true)
//                }else{
//                    print("Email is not verified")
//                    completion(error,false)
//                }
            }else{
                completion(error,false)
            }
        }
    }
    
    class func registerUserWith(email:String,password:String,userName:String,completion:@escaping(_ error:Error?) ->Void) {
        Auth.auth().createUser(withEmail: email, password: password) { (authDataResult, error) in
            completion(error)
            if error == nil{
//                authDataResult!.user.sendEmailVerification { (error) in
//                    print("verification email")
//                }
                if authDataResult?.user != nil{
                    let user = FUser(_objectId: authDataResult!.user.uid, _emal: email, _username: userName)
                    user.saveUserLocally()
                }
            }
        }
    }
    
    class func logoutCurrentUser(completion:@escaping (_ error:Error?) ->Void) {
        do {
            try Auth.auth().signOut()
            UserDefaults.standard.removeObject(forKey: kCURRENTUSER)
            
            UserDefaults.standard.synchronize()
            completion(nil)
        } catch let error as NSError {
            completion(error)
        }
    }
    
    class func resetPasswordFor(email: String,completion: @escaping (_ error: Error?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            completion(error)
        }
    }
    
    func saveUserToFirestore(){
        FirebaseReference(.User).document(self.objectId).setData(self.userDictionary as! [String : Any]) { (error) in
            if error != nil {
                print("error saving user",error!.localizedDescription)
            }
        }
    }

    func saveUserLocally(){
        UserDefaults.standard.setValue(self.userDictionary as! [String:Any], forKey: kCURRENTUSER)
        UserDefaults.standard.synchronize()
    }
    //Update user
    func updateCurrentUserInFirestore(withValues:[String:Any], completion: @escaping (_ error: Error?) -> Void) {

        if let dictionary = UserDefaults.standard.object(forKey: kCURRENTUSER) {
            let userObject = (dictionary as! NSDictionary).mutableCopy() as! NSMutableDictionary
            userObject.setValuesForKeys(withValues)
            
            FirebaseReference(.User).document(FUser.currentId()).updateData(withValues) { error in
                
                completion(error)
                if error == nil {
                    FUser(_dictionary: userObject).saveUserLocally()
                }
            }
        }
    }
    
    
}

func downloadUsersFromFirebase(completion: @escaping(_ userArray: [FUser]) -> Void){
    var userArray:[FUser] = []
    
    FirebaseReference(.User).getDocuments { (snapshot, error) in
       
        guard let snapshot = snapshot else {
            completion(userArray)
            return
        }
        if !snapshot.isEmpty{
            for userDict in snapshot.documents {
                userArray.append(FUser(_dictionary: userDict.data() as NSDictionary))
            }
        }
        completion(userArray)
    }
    
}
