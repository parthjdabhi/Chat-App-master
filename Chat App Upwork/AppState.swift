//
//  AppState.swift
//  Chat App Upwork
//
//  Created by Dustin Allen on 10/28/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import Foundation
import Firebase

class AppState: NSObject {
    
    static let sharedInstance = AppState()
    
    var signedIn = false
    var displayName: String?
    var photoUrl: NSURL?
    var currentUser: FIRDataSnapshot?
    var currentUserImage: UIImage?
    //var friendID: String?
    //var friend: UserData?
    
    let appBlueColor = UIColor.init(colorLiteralRed: (22.0/255.0), green: (104.0/255.0), blue: (143.0/255.0), alpha: 1)
    
    var friendReqCount = 0
    var unreadChatCount = 0
}