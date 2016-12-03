//
//  AddressBookViewController.swift
//  Connect App
//
//  Created by Dustin Allen on 7/6/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import SDWebImage
import CryptoSwift

class AddressBookViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    var ref:FIRDatabaseReference!
    var userArry: [UserData] = []
    var userName: String?
    var photoURL: String?
    
    var selectedUserId: String?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        ref = FIRDatabase.database().reference()
        let userID = FIRAuth.auth()?.currentUser?.uid
        
        let frRef = ref.child("users").child(userID!).child("friends")
        CommonUtils.sharedUtils.showProgress(self.view, label: "Loading..")
        print("Started")
        
        frRef.observeEventType(.Value, withBlock: { snapshot in
            self.userArry.removeAll()
            print(snapshot.value)
            if let friends = snapshot.value as?[String: String] {
                print("if pritned")
                for(_, value) in friends {
                    
                    let uRef = self.ref.child("users").child(value)
                    uRef.observeSingleEventOfType(FIRDataEventType.Value, withBlock: { snapshot in
                        if snapshot.exists()
                        {
                            
                            let userFirstName:String = snapshot.value!["username"] as? String ?? ""
                            //let userLastName:String = snap.value!["userLastName"] as? String ?? ""
                            var noImage = false
                            var image = UIImage(named: "no-pic.png")
                            if let base64String = snapshot.value!["image"] as! String! {
                                image = CommonUtils.sharedUtils.decodeImage(base64String)
                            } else {
                                noImage = true
                            }
                            
                            self.photoURL = ""
                            self.userName = userFirstName //+ " " + userLastName
                            
                            
                            if let email = snapshot.value!["email"] as? String {
                                self.userArry.append(UserData(userName: self.userName, photoURL: self.photoURL, uid: snapshot.key, image: image, email: email, noImage: noImage))
                            } else {
                                self.userArry.append(UserData(userName: self.userName, photoURL: self.photoURL, uid: snapshot.key, image: image, email: "test@test.com", noImage: noImage))
                            }
                            
                            self.tableView.reloadData()
                        }
                        
                    })
                }
            }
            else {
                CommonUtils.sharedUtils.hideProgress()
            }
        })
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    override func  preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        //self.dismissViewControllerAnimated(true, completion: nil)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //Mark :- UITableView DataSource and Delegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userArry.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell2") as! FriendTableViewCell
        
        cell.lblTitle.text = userArry[indexPath.row].getUserName()
        
        cell.onDeleteButtonTapped = {

            let alert = UIAlertController(title: "Confirm", message: "Do you want to really delete friend?", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.Default, handler: { action in
                
                /*
                if let oldfriends = AppState.sharedInstance.currentUser.value!["friends"] {
                    let fid = self.userArry[indexPath.row].getUid()
                    var friends = oldfriends as! [String:String]
                    
                    for (key, value) in friends {
                        if value == fid {
                            friends.removeValueForKey(key)
                        }
                    }
                    
                    let userID = FIRAuth.auth()?.currentUser?.uid
                    let userRef = self.ref.child("users").child(userID!)
                    
                    let dic = ["friends" : friends]
                    
                    userRef.updateChildValues(dic)
                    
                    // Delete friends of Friend
                    let fRef = self.ref.child("users").child(fid)
                    fRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                        print(snapshot.value)
                        var friends = snapshot.value!["friends"] as! [String:String]
                        
                        for (key, value) in friends {
                            if value == userID {
                                friends.removeValueForKey(key)
                            }
                        }
                        
                        let dic = ["friends" : friends]
                        
                        fRef.updateChildValues(dic)
                    })
                    
                    self.userArry.removeAtIndex(indexPath.row)
                    self.tableView.reloadData()
                }*/
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        print("\(indexPath.row)" + "\n")
        CommonUtils.sharedUtils.hideProgress()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        print("Index Path: ", indexPath.row)
        print("User Array: ", self.userArry)
        let friend = self.userArry[indexPath.row]
        selectedUserId = friend.getUid()
        AppState.sharedInstance.friend = friend
        
        //let vc = self.storyboard?.instantiateViewControllerWithIdentifier("FriendPortalViewController") as! FriendPortalViewController
        //self.navigationController?.pushViewController(vc, animated: true)
        actionStartChat()
    }
    
    @IBAction func selectAddContacts(sender: AnyObject) {        
        
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("AddContactsViewController") as! AddContactsViewController!
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func actionStartChat() {
        
        let groupId = self.StartPrivateChat(AppState.sharedInstance.friend?.getUid() ?? "", Usersname: AppState.sharedInstance.friend?.userName ?? "")
        
        let chatVc = self.storyboard?.instantiateViewControllerWithIdentifier("MyChatViewController") as! MyChatViewController!
        chatVc.groupId = groupId
        chatVc.senderDisplayName = AppState.sharedInstance.friend?.userName ?? ""
        chatVc.senderId = FIRAuth.auth()?.currentUser?.uid
        chatVc.OppUserId = AppState.sharedInstance.friend?.getUid() ?? ""
        self.navigationController?.navigationBar.hidden = false
        self.navigationController?.pushViewController(chatVc, animated: true)
    }
    
    //StartPrivateChat
    func StartPrivateChat(userID:String,Usersname:String) -> String
    {
        let userId1 = (FIRAuth.auth()?.currentUser?.uid)! as String
        let userId2 = userID //self.objectsID.objectAtIndex(0) as? String ?? ""      //Later Change it to dynamic
        let user1Name = "user1"
        let user2Name = "user2"//user2[FUSER_NAME]
        
        let members:[String] = NSArray.init(array:[userId1,userId2]) as! [String]
        let sortedMembers = members.sort({ $0 < $1 })
        
        let groupId =  (sortedMembers.joinWithSeparator("")).md5()
        
        print("Group ID : \(groupId)")
        
        CreateRecent(userId1, oppUserId:userId2, groupId: groupId, members: members, description: user2Name);
        CreateRecent(userId2, oppUserId:userId1, groupId: groupId, members: members, description: user1Name);
        
        return groupId;
    }
    
    func CreateRecent(userId:String,oppUserId:String,groupId:String ,members:[String] ,description:String)
    {
        let firebase: FIRDatabaseReference = FIRDatabase.database().referenceWithPath(FRECENT_PATH)
        let query: FIRDatabaseQuery = firebase.queryOrderedByChild(FRECENT_GROUPID).queryEqualToValue(groupId)
        query.observeSingleEventOfType(.Value, withBlock: {(snapshot: FIRDataSnapshot) -> Void in
            var create: Bool = true
            if snapshot.exists() {
                print(snapshot.childrenCount) // I got the expected number of items
                let enumerator = snapshot.children
                while let rest = enumerator.nextObject() as? FIRDataSnapshot {
                    print(rest.value)
                    if let dictionary = rest.value as? [NSString : AnyObject]
                        where (dictionary[FRECENT_USERID] as! String) == userId
                    {
                        create = false
                    }
                }
            }
            if create == true {
                self.CreateRecentItem(userId, oppUserId:oppUserId, groupId: groupId, members: members, description: description)
            }
        })
    }
    
    func CreateRecentItem(userId:String ,oppUserId:String ,groupId:String ,members:[String] ,description:String)
    {
        var recent: [String:AnyObject] =  Dictionary()
        recent[FRECENT_USERID] = userId
        recent[FRECENT_OPPUSERID] = oppUserId
        recent[FRECENT_GROUPID] = groupId
        recent[FRECENT_MEMBERS] = members
        recent[FRECENT_DESCRIPTION] = ""
        recent[FRECENT_LASTMESSAGE] = ""
        recent[FRECENT_COUNTER] = 0
        recent[FRECENT_TYPE] = "Private"
        
        recent[FRECENT_NAME] = (userId == FIRAuth.auth()?.currentUser?.uid ?? "") ? "Me" : AppState.sharedInstance.friend?.userName ?? "";
        
        recent[FRECENT_UPDATEDAT] = NSDate().customFormatted
        recent[FRECENT_CREATEDAT] = NSDate().customFormatted
        
        ref.child(FRECENT_PATH).childByAutoId().updateChildValues(recent) { (error, FIRDBRef) in
            if error == nil {
                print("saved recent object")
            } else {
                print("Failed to save recent object : \(recent)")
            }
        }
        
    }
}
