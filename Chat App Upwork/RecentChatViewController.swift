//
//  RecentChatViewController.swift
//  Chat App Upwork
//
//  Created by Dustin Allen on 11/10/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class RecentChatViewController: UIViewController {
    
    
    @IBOutlet var tblRecentChat: UITableView!
    
    // MARK: Properties
    
    var groupId:String? = ""
    var messages: [AnyObject] = []
    
    var recents: [AnyObject] = []
    var recentIds: [AnyObject] = []
    
    
    var ref:FIRDatabaseReference!
    let MyUserID = FIRAuth.auth()?.currentUser?.uid
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //self.loadRecentConversation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.loadRecentConversation()
    }
    
    override func  preferredStatusBarStyle()-> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */

    // Go Back to Previous screen
    @IBAction func ActionGoBack(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: - Delegates
    // MARK: -  UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if recents.count == 0 {
            let emptyLabel = UILabel(frame: tableView.frame)
            emptyLabel.text = "You don't have any conversations at this time."
            emptyLabel.textColor = UIColor.darkGrayColor();
            emptyLabel.textAlignment = .Center;
            emptyLabel.numberOfLines = 3
            
            tableView.backgroundView = emptyLabel
            tableView.separatorStyle = UITableViewCellSeparatorStyle.None
            return 0
        } else {
            tableView.backgroundView = nil
            return recents.count
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:RecentTableViewCell = tableView.dequeueReusableCellWithIdentifier("RecentTableViewCell", forIndexPath: indexPath) as! RecentTableViewCell
        
        if let recent = self.recents[indexPath.row] as? [String:AnyObject] {
            
            //cell.lblName?.text = recent[FRECENT_NAME] as? String ?? ""
            cell.lblLastMsg?.text = recent[FRECENT_LASTMESSAGE] as? String ?? ""
            
            let date = (recent[FRECENT_UPDATEDAT] as? String ?? "").asDate
            //let seconds = NSDate().timeIntervalSinceDate(date!)
            cell.lblElapsed?.text = date?.getElapsedInterval()
            
            let GroupId = recent[FRECENT_GROUPID] as? String ?? ""
            let firebase2: FIRDatabaseReference = FIRDatabase.database().referenceWithPath(FMESSAGE_PATH).child(GroupId)
            
            
            let OppUserId = recent[FRECENT_OPPUSERID] as? String ?? ""
            
            // status - Delivered
            //firebase2.queryOrderedByChild(FRECENT_USERID).queryEqualToValue(MyUserID)
            firebase2.queryOrderedByChild(FMESSAGE_STATUS).queryEqualToValue(TEXT_DELIVERED).observeSingleEventOfType(.Value, withBlock: {(snapshot: FIRDataSnapshot) -> Void in
                if snapshot.exists() {
                    //Sort array by dict[FRECENT_UPDATEDAT]
                    print(snapshot.childrenCount)
                    
                    //cell.lblCount?.text = (snapshot.childrenCount != 0) ? "\(snapshot.childrenCount) New" : nil
                    
                    let enumerator = snapshot.children
                    var UnreadMsgCount = 0
                    //var lastMsgText = ""
                    
                    while let rest = enumerator.nextObject() as? FIRDataSnapshot {
                        print("rest.key =>>  \(rest.key) =>>   \(rest.value)")
                        if var dic = rest.value as? [String:AnyObject] where (dic[FRECENT_USERID] as? String ?? "") ==  OppUserId {
                            print(rest.key)
                            print("Convesation : \(dic)")
                            UnreadMsgCount += 1
                            //lastMsgText = dic[MESSAGE_TEXT] as? String ?? ""
                            //self.recents.append(dic)
                            //self.recentIds.append(dic[FRECENT_GROUPID] as? String ?? "")
                            
                            // Test to set message record status to be read
                            //                            print(snapshot.key)
                            //                            dic[FMESSAGE_STATUS] = TEXT_READ
                            //                            let firebaseR: FIRDatabaseReference = FIRDatabase.database().referenceWithPath(FMESSAGE_PATH).child(GroupId).child(snapshot.key)
                            //                            firebaseR.updateChildValues(dic) { (error, FIRDBRef) in
                            //                                if error == nil {
                            //                                    print("Message marked as read")
                            //                                } else {
                            //                                    print("Failed to mark message as read")
                            //                                }
                            //                            }
                            
                        }
                        cell.lblCount?.text = (UnreadMsgCount != 0) ? "\(UnreadMsgCount) New" : nil
                        //cell.lblLastMsg?.text = lastMsgText
                    }
                }
                //createRecentObservers
            })
            
            //Fetch last message
            let firebase3: FIRDatabaseReference = FIRDatabase.database().referenceWithPath(FMESSAGE_PATH).child(GroupId)
            firebase3.queryLimitedToLast(1).observeSingleEventOfType(.Value, withBlock: {(snapshot: FIRDataSnapshot) -> Void in
                if snapshot.exists() {
                    print(snapshot.childrenCount)
                    let enumerator = snapshot.children
                    var lastMsgText = ""
                    
                    while let rest = enumerator.nextObject() as? FIRDataSnapshot {
                        if var dic = rest.value as? [String:AnyObject] {
                            print(rest.key)
                            print("Convesation : \(dic)")
                            lastMsgText = dic[MESSAGE_TEXT] as? String ?? ""
                            cell.lblElapsed?.text = (dic[FRECENT_CREATEDAT] as? String ?? "").asDate?.getElapsedInterval()
                        }
                    }
                    cell.lblLastMsg?.text = lastMsgText
                }
            })
            
            
            //let counter = recent[FRECENT_COUNTER] as? Int ?? 0
            //cell.lblCount?.text = (counter != 0) ? "\(counter)" : nil
            //cell.lblLastMsg?.text = recent[FRECENT_LASTMESSAGE] as? String ?? ""
            
            let firebase: FIRDatabaseReference = FIRDatabase.database().referenceWithPath("users")
            firebase.child((recent[FRECENT_OPPUSERID] as? String ?? "")).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                
                let UserDetail = snapshot.valueInExportFormat() as? NSDictionary
                //print(UserDetail)
                
                if let userFirstName = (UserDetail?["userInfo"]?["userFirstName"]) , userLastName = (UserDetail?["userInfo"]?["userLastName"]) {
                    cell.lblName?.text = "\(userFirstName!) \(userLastName!)"
                }
                
                if let base64String = UserDetail?["profileData"]?["userPhoto"] as? String {
                    // decode image
                    cell.imgUser?.image = CommonUtils.sharedUtils.decodeImage(base64String)
                }
            }) { (error) in
                //
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if let recent = self.recents[indexPath.row] as? [String:AnyObject] {
            let GroupId = recent[FRECENT_GROUPID] as? String ?? ""
            
            let chatVc = self.storyboard?.instantiateViewControllerWithIdentifier("PrivateChatViewController") as! PrivateChatViewController!
            chatVc.groupId = GroupId
            chatVc.senderDisplayName = ""
            chatVc.senderId = FIRAuth.auth()?.currentUser?.uid
            chatVc.OppUserId = recent[FRECENT_OPPUSERID] as? String ?? ""
            self.navigationController?.navigationBar.hidden = false
            self.navigationController?.pushViewController(chatVc, animated: true)
        }
    }
    
    // Fetching Convesation
    func loadRecentConversation()
    {
        let firebase: FIRDatabaseReference = FIRDatabase.database().referenceWithPath(FRECENT_PATH)
        firebase.queryOrderedByChild(FRECENT_USERID).queryEqualToValue(MyUserID).observeSingleEventOfType(.Value, withBlock: {(snapshot: FIRDataSnapshot) -> Void in
            if snapshot.exists() {
                self.recents.removeAll()
                //Sort array by dict[FRECENT_UPDATEDAT]
                let enumerator = snapshot.children
                while let rest = enumerator.nextObject() as? FIRDataSnapshot {
                    print(rest.value)
                    if let dic = rest.value as? [String:AnyObject] {
                        print("Convesation : \(dic)")
                        self.recents.append(dic)
                        self.recentIds.append(dic[FRECENT_GROUPID] as? String ?? "")
                    }
                }
                self.tblRecentChat.reloadData()
            }
            //createRecentObservers
        })
    }
}

/*
import UIKit
import Firebase
import FirebaseAuth

class RecentChatViewController: UIViewController {

    
    @IBOutlet var tblRecentChat: UITableView!
    
    // MARK: Properties

    var groupId:String? = ""
    var messages: [AnyObject] = []
    
    var recents: [AnyObject] = []
    var recentIds: [AnyObject] = []
    
    
    var ref:FIRDatabaseReference!
    let MyUserID = FIRAuth.auth()?.currentUser?.uid
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.loadRecentConversation()
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

    // Go Back to Previous screen
    @IBAction func ActionGoBack(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: - Delegates
    // MARK: -  UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if recents.count == 0 {
            let emptyLabel = UILabel(frame: tableView.frame)
            emptyLabel.text = "Its seem like you do not made any converion!"
            emptyLabel.textColor = UIColor.darkGrayColor();
            emptyLabel.textAlignment = .Center;
            
            tableView.backgroundView = emptyLabel
            tableView.separatorStyle = UITableViewCellSeparatorStyle.None
            return 0
        } else {
            tableView.backgroundView = nil
            return recents.count
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:RecentTableViewCell = tableView.dequeueReusableCellWithIdentifier("RecentTableViewCell", forIndexPath: indexPath) as! RecentTableViewCell
        
        if let recent = self.recents[indexPath.row] as? [String:AnyObject] {
            
            //cell.lblName?.text = recent[FRECENT_NAME] as? String ?? ""
            cell.lblLastMsg?.text = recent[FRECENT_LASTMESSAGE] as? String ?? ""
            
            let date = (recent[FRECENT_UPDATEDAT] as? String ?? "").asDate
            //let seconds = NSDate().timeIntervalSinceDate(date!)
            cell.lblElapsed?.text = date?.getElapsedInterval()
            
            let GroupId = recent[FRECENT_GROUPID] as? String ?? ""
            let firebase2: FIRDatabaseReference = FIRDatabase.database().referenceWithPath(FMESSAGE_PATH).child(GroupId)
            
            
            let OppUserId = recent[FRECENT_OPPUSERID] as? String ?? ""
            
            // status - Delivered
            //firebase2.queryOrderedByChild(FRECENT_USERID).queryEqualToValue(MyUserID)
            firebase2.queryOrderedByChild(FMESSAGE_STATUS).queryEqualToValue(TEXT_DELIVERED).observeSingleEventOfType(.Value, withBlock: {(snapshot: FIRDataSnapshot) -> Void in
                if snapshot.exists() {
                    //Sort array by dict[FRECENT_UPDATEDAT]
                    print(snapshot.childrenCount)
                    
                    //cell.lblCount?.text = (snapshot.childrenCount != 0) ? "\(snapshot.childrenCount) New" : nil
                    
                    let enumerator = snapshot.children
                    var UnreadMsgCount = 0
                    //var lastMsgText = ""
                    
                    while let rest = enumerator.nextObject() as? FIRDataSnapshot {
                        print("rest.key =>>  \(rest.key) =>>   \(rest.value)")
                        if var dic = rest.value as? [String:AnyObject] where (dic[FRECENT_USERID] as? String ?? "") ==  OppUserId {
                            print(rest.key)
                            print("Convesation : \(dic)")
                            UnreadMsgCount += 1
                            //lastMsgText = dic[MESSAGE_TEXT] as? String ?? ""
                            //self.recents.append(dic)
                            //self.recentIds.append(dic[FRECENT_GROUPID] as? String ?? "")
                           
                            // Test to set message record status to be read
//                            print(snapshot.key)
//                            dic[FMESSAGE_STATUS] = TEXT_READ
//                            let firebaseR: FIRDatabaseReference = FIRDatabase.database().referenceWithPath(FMESSAGE_PATH).child(GroupId).child(snapshot.key)
//                            firebaseR.updateChildValues(dic) { (error, FIRDBRef) in
//                                if error == nil {
//                                    print("Message marked as read")
//                                } else {
//                                    print("Failed to mark message as read")
//                                }
//                            }
                            
                        }
                        cell.lblCount?.text = (UnreadMsgCount != 0) ? "\(UnreadMsgCount) New" : nil
                        //cell.lblLastMsg?.text = lastMsgText
                    }
            }
                //createRecentObservers
            })
            
            //Fetch last message
            let firebase3: FIRDatabaseReference = FIRDatabase.database().referenceWithPath(FMESSAGE_PATH).child(GroupId)
            firebase3.queryLimitedToLast(1).observeSingleEventOfType(.Value, withBlock: {(snapshot: FIRDataSnapshot) -> Void in
                if snapshot.exists() {
                    print(snapshot.childrenCount)
                    let enumerator = snapshot.children
                    var lastMsgText = ""
                    
                    while let rest = enumerator.nextObject() as? FIRDataSnapshot {
                        if var dic = rest.value as? [String:AnyObject] {
                            print(rest.key)
                            print("Convesation : \(dic)")
                            lastMsgText = dic[MESSAGE_TEXT] as? String ?? ""
                             cell.lblElapsed?.text = (dic[FRECENT_CREATEDAT] as? String ?? "").asDate?.getElapsedInterval()
                        }
                    }
                    cell.lblLastMsg?.text = lastMsgText
                }
            })
            
            
            //let counter = recent[FRECENT_COUNTER] as? Int ?? 0
            //cell.lblCount?.text = (counter != 0) ? "\(counter)" : nil
            //cell.lblLastMsg?.text = recent[FRECENT_LASTMESSAGE] as? String ?? ""
            
            let firebase: FIRDatabaseReference = FIRDatabase.database().referenceWithPath("users")
            firebase.child((recent[FRECENT_OPPUSERID] as? String ?? "")).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                
                let UserDetail = snapshot.valueInExportFormat() as? NSDictionary
                //print(UserDetail)
                
                if let userFirstName = (UserDetail?["userInfo"]?["userFirstName"]) , userLastName = (UserDetail?["userInfo"]?["userLastName"]) {
                    cell.lblName?.text = "\(userFirstName!) \(userLastName!)"
                }
                
                if let base64String = UserDetail?["profileData"]?["userPhoto"] as? String {
                    // decode image
                    cell.imgUser?.image = CommonUtils.sharedUtils.decodeImage(base64String)
                }
                
            }) { (error) in
                //
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if let recent = self.recents[indexPath.row] as? [String:AnyObject] {
            let GroupId = recent[FRECENT_GROUPID] as? String ?? ""
            
            let chatVc = self.storyboard?.instantiateViewControllerWithIdentifier("PrivateChatViewController") as! PrivateChatViewController!
            chatVc.groupId = GroupId
            chatVc.senderDisplayName = ""
            chatVc.senderId = FIRAuth.auth()?.currentUser?.uid
            chatVc.OppUserId = recent[FRECENT_OPPUSERID] as? String ?? ""
            self.navigationController?.navigationBar.hidden = false
            self.navigationController?.pushViewController(chatVc, animated: true)
        }
    }
    
    // Fetching Convesation
    func loadRecentConversation()
    {
        let firebase: FIRDatabaseReference = FIRDatabase.database().referenceWithPath(FRECENT_PATH)
        firebase.queryOrderedByChild(FRECENT_USERID).queryEqualToValue(MyUserID).observeSingleEventOfType(.Value, withBlock: {(snapshot: FIRDataSnapshot) -> Void in
           if snapshot.exists() {
                //Sort array by dict[FRECENT_UPDATEDAT]
                let enumerator = snapshot.children
                while let rest = enumerator.nextObject() as? FIRDataSnapshot {
                    print(rest.value)
                    if let dic = rest.value as? [String:AnyObject] {
                        print("Convesation : \(dic)")
                        self.recents.append(dic)
                        self.recentIds.append(dic[FRECENT_GROUPID] as? String ?? "")
                    }
                }
                self.tblRecentChat.reloadData()
            }
            //createRecentObservers
        })
    }
}*/
