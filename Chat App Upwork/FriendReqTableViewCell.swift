//
//  FriendReqTableViewCell.swift
//  Chat App Upwork
//
//  Created by Dustin Allen on 11/10/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

@objc protocol FriendReqTableViewCellDelegate: class {
    optional func onAcceptOrRejectRequest(index:Int)
}

class FriendReqTableViewCell: UITableViewCell {

    @IBOutlet var lblName: UILabel!
    @IBOutlet var btnAccept: UIButton!
    @IBOutlet var btnReject: UIButton!
    @IBOutlet var imgUser: UIImageView!
    
    var FirRef:FIRDatabaseReference?
    var UserID:String?
    var UserSnapShot:FIRDataSnapshot?
    let MyUserID = FIRAuth.auth()?.currentUser?.uid
    var index:Int?
    
    weak var delegate: FriendReqTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func SetupData(FirRef:FIRDatabaseReference,UserID:String)
    {
        self.imgUser.layer.cornerRadius = 10
        self.imgUser.clipsToBounds = true
        
        self.FirRef = FirRef
        self.UserID = UserID
        
        //print("My Id : \(self.MyUserID) Firend use Id :\(self.UserID)")
        
        
        FirRef.child("users").child(UserID).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            
            self.UserSnapShot = snapshot
            let UserDetail = snapshot.valueInExportFormat() as? NSDictionary
            //print(UserDetail)
            
            if let userFirstName = (UserDetail?["userInfo"]?["userFirstName"]) , userLastName = (UserDetail?["userInfo"]?["userLastName"]) {
                self.lblName.text = "\(userFirstName!) \(userLastName!)"
            }
            
            if let base64String = UserDetail?["profileData"]?["userPhoto"] as? String {
                // decode image
                self.imgUser.image = CommonUtils.sharedUtils.decodeImage(base64String)
            }
            
        }) { (error) in
            //
        }
    }
    
    @IBAction func AcceptFriendRequest(sender: UIButton)
    {
        //print("My Id : \(self.MyUserID) Firend use Id :\(self.UserID)")
        
        //Remove My user Id to Friends's myfriend
        self.FirRef?.child("users").child(UserID!).child("userInfo").child("friendRequest").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if let FriendReqUserDetail = snapshot.valueInExportFormat() as? NSDictionary {
                let arrFriendReqs =  NSMutableArray(array: FriendReqUserDetail.allValues)
                //print("\(self.UserID) :: \(arrFriendReqs)")
                
                if arrFriendReqs.containsObject(self.MyUserID!) {
                    arrFriendReqs.removeObject(self.MyUserID!)
                    self.FirRef?.child("users").child(self.UserID!).child("userInfo").updateChildValues(["friendRequest":arrFriendReqs]) { (error, reference) in
                        
                        if error == nil {
                            print("successfully Removed MyUserID from their friends request")
                        }else  {
                            print("Faail to remove id From Request array")
                        }
                    }
                }
            }
        })
        
        //Remove Friends Id to my myfriend
        self.FirRef?.child("users").child(MyUserID!).child("userInfo").child("friendRequest").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if let FriendReqUserDetail = snapshot.valueInExportFormat() as? NSDictionary {
                let arrFriendReqs =  NSMutableArray(array: FriendReqUserDetail.allValues)
                //print("MyUserID >> \(self.MyUserID) :: \(arrFriendReqs)")
                
                if arrFriendReqs.containsObject(self.UserID!) {
                    arrFriendReqs.removeObject(self.UserID!)
                    self.FirRef?.child("users").child(self.MyUserID!).child("userInfo").updateChildValues(["friendRequest":arrFriendReqs]) { (error, reference) in
                        
                        if error == nil {
                            print("successfully Removed Friend id from my friends request")
                        }else  {
                            print("Faail to remove id From Request array")
                        }
                    }
                }
            }
        })
        
        //Add My ID to Friends - My Friends Array
        self.FirRef?.child("users").child(MyUserID!).child("myFriends").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            var arrFriendReqs:NSMutableArray?
            
            if let FriendReqUserDetail = snapshot.valueInExportFormat() as? NSDictionary {
                arrFriendReqs =  NSMutableArray(array: FriendReqUserDetail.allValues)
                //print("\(self.MyUserID) :: \(arrFriendReqs)")
                
            }
            if arrFriendReqs == nil {
                arrFriendReqs = NSMutableArray()
            }
            
            if (arrFriendReqs!.containsObject(self.UserID!) == false)
            {
                arrFriendReqs!.addObject(self.UserID!)
                self.FirRef?.child("users").child(self.MyUserID!).updateChildValues(["myFriends":arrFriendReqs!]) { (error, reference) in
                    
                    if error == nil {
                        print("successfully Removed MyUserID from their friends request")
                    }else  {
                        print("Faail to remove id From Request array")
                    }
                }
            }
        })
        
        //Add Friends ID to Mine - My Friends Array
        self.FirRef?.child("users").child(UserID!).child("myFriends").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            var arrFriendReqs:NSMutableArray?
            
            if let FriendReqUserDetail = snapshot.valueInExportFormat() as? NSDictionary {
                arrFriendReqs =  NSMutableArray(array: FriendReqUserDetail.allValues)
                //print("\(self.UserID) :: \(arrFriendReqs)")
            }
            if arrFriendReqs == nil {
                arrFriendReqs = NSMutableArray()
            }
            
            if (arrFriendReqs!.containsObject(self.MyUserID!) == false)
            {
                arrFriendReqs!.addObject(self.MyUserID!)
                self.FirRef?.child("users").child(self.UserID!).updateChildValues(["myFriends":arrFriendReqs!]) { (error, reference) in
                    
                    if error == nil {
                        print("successfully Removed MyUserID from their friends request")
                    }else  {
                        print("Faail to remove id From Request array")
                    }
                }
            }
        })
        
        self.delegate?.onAcceptOrRejectRequest?(self.index ?? 0)
    }
    
    
    @IBAction func RejectFriendRequest(sender: UIButton)
    {
        //print("My Id : \(self.MyUserID) Firend use Id :\(self.UserID)")
        //Remove My user Id to Friends's myfriend
        self.FirRef?.child("users").child(UserID!).child("userInfo").child("friendRequest").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if let FriendReqUserDetail = snapshot.valueInExportFormat() as? NSDictionary {
                let arrFriendReqs =  NSMutableArray(array: FriendReqUserDetail.allValues)
                //print("\(self.UserID) :: \(arrFriendReqs)")
                
                if arrFriendReqs.containsObject(self.MyUserID!) {
                    arrFriendReqs.removeObject(self.MyUserID!)
                    self.FirRef?.child("users").child(self.UserID!).child("userInfo").updateChildValues(["friendRequest":arrFriendReqs]) { (error, reference) in
                        
                        if error == nil {
                            print("successfully Removed MyUserID from their friends request")
                        }else  {
                            print("Faail to remove id From Request array")
                        }
                    }
                }
            }
            self.delegate?.onAcceptOrRejectRequest?(self.index ?? 0)
        })
        
        //Remove Friends Id to my myfriend
        self.FirRef?.child("users").child(MyUserID!).child("userInfo").child("friendRequest").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if let FriendReqUserDetail = snapshot.valueInExportFormat() as? NSDictionary {
                let arrFriendReqs =  NSMutableArray(array: FriendReqUserDetail.allValues)
                //print("MyUserID >> \(self.MyUserID) :: \(arrFriendReqs)")
                
                if arrFriendReqs.containsObject(self.UserID!) {
                    arrFriendReqs.removeObject(self.UserID!)
                    self.FirRef?.child("users").child(self.MyUserID!).child("userInfo").updateChildValues(["friendRequest":arrFriendReqs]) { (error, reference) in
                        
                        if error == nil {
                            print("successfully Removed Friend id from my friends request")
                        }else  {
                            print("Faail to remove id From Request array")
                        }
                    }
                }
            }
        })
    }
}
