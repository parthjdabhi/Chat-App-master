//
//  FriendListViewController.swift
//  Chat App Upwork
//
//  Created by Dustin Allen on 11/10/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import CryptoSwift

//-----------------------------------------------------------------------
let FMESSAGE_PATH = "Message"//	Path name
let FMESSAGE_GROUPID = "groupId"//	String
let FMESSAGE_USERID = "userId"//	String
let FMESSAGE_USER_NAME = "user_name"//	String
let FMESSAGE_STATUS = "status"//	String

//-----------------------------------------------------------------------
let FRECENT_PATH = "Recent"//	Path name
let FRECENT_USERID = "userId"//	String
let FRECENT_OPPUSERID = "oppUserId"
let FRECENT_GROUPID = "groupId"//	String
let FRECENT_PICTURE = "picture"//	String
let FRECENT_NAME = "name"
let FRECENT_MEMBERS = "members"//	Array
let FRECENT_DESCRIPTION = "description"//	String
let FRECENT_LASTMESSAGE = "lastMessage"//	String
let FRECENT_COUNTER = "counter"//	Number
let FRECENT_TYPE = "type"//	String
let FRECENT_PASSWORD = "password"//	String
let FRECENT_UPDATEDAT = "updatedAt"//	Interval
let FRECENT_CREATEDAT = "createdAt"//	Interval
let FMESSAGE_CREATEDAT = "createdAt"//	Interval

//-----------------------------------------------------------------------
let MESSAGE_TEXT = "text"

//-----------------------------------------------------------------------
let TEXT_DELIVERED = "Delivered"
let TEXT_READ = "Read"

//-----------------------------------------------------------------------
let FMESSAGE_TYPE = "type"//	String
let FMESSAGE_TEXT = "text"//	String

//-----------------------------------------------------------------------
let FTYPING_PATH = "Typing"//	Path name


class FriendListViewController: UIViewController {

    @IBOutlet var tblFriends: UITableView!
    
    
    // MARK: Properties
    
    var ref:FIRDatabaseReference!
    var FriendsReference:NSDictionary!
    var FriendSnapshot:FIRDataSnapshot!
    var arrFriends = NSMutableArray()
    var objects = NSMutableArray()
    var objectsID = NSMutableArray()
    
    var Usersname = ""
    let MyUserID = FIRAuth.auth()?.currentUser?.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.view.layoutIfNeeded()
        
        ref = FIRDatabase.database().reference()
        self.GetFriendList()
        
    }
    
    override func  preferredStatusBarStyle()-> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    //Go Back to Previous screen
    @IBAction func ActionGoBack(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func GetFriendList() {
        
        CommonUtils.sharedUtils.showProgress(self.view, label: "Fetching Friend List...")
        let userID = FIRAuth.auth()?.currentUser?.uid
        
        self.objects.removeAllObjects()
        self.objectsID.removeAllObjects()
        
        //Add My ID to Friends - My Friends Array
        ref.child("users").child(userID!).child("myFriends").observeEventType(.Value, withBlock: { (snapshot) in
            var arrFriendReqs:NSMutableArray?
            
            if let friendsReference = snapshot.valueInExportFormat() as? NSDictionary
            {
                self.FriendsReference = friendsReference
                arrFriendReqs =  NSMutableArray(array: friendsReference.allValues)
                
                print(" myFriends \(userID) :: \(arrFriendReqs)")
                
                let lastId:String? = arrFriendReqs?.lastObject as? String
                
                if arrFriendReqs != nil
                {
                    let group = dispatch_group_create()
                    for userObjectId in arrFriendReqs! {
                        dispatch_group_enter(group)
                        print("Hello, \(userObjectId)!")
                        self.ref.child("users").child(userObjectId as! String).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                            
                            if let UserDetail = snapshot.valueInExportFormat() as? NSDictionary {
                                self.objects.addObject(UserDetail)
                                self.objectsID.addObject(userObjectId)
                            }
                            dispatch_group_leave(group)
//                            if (userObjectId as? String == lastId)
                        });
                    }
                    dispatch_group_notify(group, dispatch_get_main_queue())
                    {
                        self.tblFriends.reloadData()
                        CommonUtils.sharedUtils.hideProgress()
                    }
                }
                else {
                    self.objects = [];
                    self.tblFriends.reloadData()
                    CommonUtils.sharedUtils.hideProgress()
                    print("No Friend found")
                }
            } else {
                self.objects = [];
                self.tblFriends.reloadData()
                CommonUtils.sharedUtils.hideProgress()
                print("No Friend found")
            }
        })
    }
    
    // MARK: - Delegates
    // MARK: -  UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let allFriendsCount = self.objects.count //?? 0
        if allFriendsCount == 0 {
            let emptyLabel = UILabel(frame: tableView.frame)
            emptyLabel.text = "You don't have any friends!"
            emptyLabel.textColor = UIColor.darkGrayColor();
            emptyLabel.textAlignment = .Center;
            emptyLabel.numberOfLines = 3
            
            tableView.backgroundView = emptyLabel
            tableView.separatorStyle = UITableViewCellSeparatorStyle.None
            return 0
        } else {
            tableView.backgroundView = nil
            return allFriendsCount
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:UserTableViewCell = tableView.dequeueReusableCellWithIdentifier("UserTableViewCell", forIndexPath: indexPath) as! UserTableViewCell
        
        let FriendUserID = self.objectsID.objectAtIndex(indexPath.row) as? String ?? ""
        cell.SetupData(self.objects.objectAtIndex(indexPath.row) as? NSDictionary, UserID: FriendUserID)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        
        if let UserDetail = self.objects.objectAtIndex(indexPath.row) as? NSDictionary {
            if let userFirstName = (UserDetail["userInfo"]?["userFirstName"]) , userLastName = (UserDetail["userInfo"]?["userLastName"]) {
                Usersname = "\(userFirstName!) \(userLastName!)"
            }
        }
        
        let groupId = self.StartPrivateChat(self.objectsID.objectAtIndex(indexPath.row) as? String ?? "", Usersname: Usersname)
        
        let chatVc = self.storyboard?.instantiateViewControllerWithIdentifier("PrivateChatViewController") as! PrivateChatViewController!
        chatVc.groupId = groupId
        chatVc.senderDisplayName = Usersname
        chatVc.senderId = FIRAuth.auth()?.currentUser?.uid
        chatVc.OppUserId = self.objectsID.objectAtIndex(0) as? String ?? ""
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
        
        recent[FRECENT_NAME] = (userId == MyUserID) ? "Me" : Usersname;
        
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


