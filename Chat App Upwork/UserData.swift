//
//  UserData.swift
//  Connect App
//
//  Created by super on 7/4/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import Foundation
struct UserData
{
    var userName: String?
    var photoURL: String?
    var uid: String?
    var image: UIImage?
    var email: String?
    var noImage: Bool?
    
    // Mark: Init
    init(let userName: String?, let photoURL: String?, let uid: String?, let image: UIImage?, let email: String?, let noImage: Bool?) {
        self.userName = userName
        self.photoURL = photoURL
        self.uid = uid
        self.image = image
        self.email = email
        self.noImage = noImage
    }
    
    // Mark: Get User Name
    func getUserName() -> String {
        return self.userName!
    }
    
    // Mark: Get User Profile Photo URL
    func getUserPhotoURL() -> String {
        return self.photoURL!
    }
    
    // Mark: Get User uid
    func getUid() -> String {
        return self.uid!
    }
    
    // Mark: Get User image
    func getImage() -> UIImage {
        return self.image!
    }
    
    // Mark: Get User email
    func getEmail() -> String {
        return self.email!
    }
    
    // Mark: check whether profile image exist
    func imageExist() -> Bool {
        return !self.noImage!
    }
}