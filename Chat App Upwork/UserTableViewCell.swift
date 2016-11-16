//
//  UserListTableViewCell.swift
//  Chat App Upwork
//
//  Created by Dustin Allen on 11/10/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class UserTableViewCell: UITableViewCell {

    @IBOutlet var lblName: UILabel!
    @IBOutlet var imgUser: UIImageView!
    
    var FirRef:FIRDatabaseReference?
    var UserID:String?
    //var UserSnapShot:FIRDataSnapshot?
    let MyUserID = FIRAuth.auth()?.currentUser?.uid
    var UserDetail:NSDictionary?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func SetupData(userDetail:NSDictionary?,UserID:String)
    {
        self.imgUser.layer.cornerRadius = self.imgUser.frame.size.width/2;
        self.imgUser.clipsToBounds = true
        
        self.UserDetail = userDetail
        self.UserID = UserID
        
        print("My Id : \(self.MyUserID) Firend use Id :\(self.UserID)")
        
        if let userFirstName = (UserDetail?["userInfo"]?["userFirstName"]) , userLastName = (UserDetail?["userInfo"]?["userLastName"]) {
            self.lblName.text = "\(userFirstName!) \(userLastName!)"
        }
        
        if let base64String = UserDetail?["profileData"]?["userPhoto"] as? String {
            // decode image
            self.imgUser.image = CommonUtils.sharedUtils.decodeImage(base64String)
        }
    }

}
