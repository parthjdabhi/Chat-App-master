//
//  MainViewController.swift
//  Chat App Upwork
//
//  Created by Dustin Allen on 10/27/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var username: UILabel!
    @IBOutlet var tblGroupList: UITableView!
    
    @IBOutlet var lblFriendReqBadge: UILabel!
    @IBOutlet var lblUnreadConBadge: UILabel!
    
    var ref:FIRDatabaseReference!
    var user: FIRUser!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.tblGroupList.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cellIdentifier")
        
        ref = FIRDatabase.database().reference()
        user = FIRAuth.auth()?.currentUser
        let userID = FIRAuth.auth()?.currentUser?.uid
        
        ref.child("users").child(userID!).observeEventType(.Value, withBlock: { (snapshot) in
            AppState.sharedInstance.currentUser = snapshot
            
            let data = snapshot.value as? NSDictionary
            if let user = data?["username"] as? String {
                self.username.text = "Hi \(user)"
            } else {
                self.username.text = "Hi"
            }
            
            //let userInfo = snapshot.valueInExportFormat() as? NSMutableDictionary ?? NSMutableDictionary()
            let userInfo = NSMutableDictionary()
            userInfo["deviceToken"] = NSUserDefaults.standardUserDefaults().objectForKey("deviceToken") as? String ?? ""
            self.ref.child("users").child(userID!).updateChildValues(userInfo as [NSObject : AnyObject])
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        getGroups()
        observeNewlyAddedGroups()
        // inviteTapped()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func logoutButton(sender: AnyObject) {
        let actionSheetController = UIAlertController (title: "Message", message: "Are you sure want to logout?", preferredStyle: UIAlertControllerStyle.ActionSheet)
        actionSheetController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        actionSheetController.addAction(UIAlertAction(title: "Logout", style: UIAlertActionStyle.Destructive, handler: { (actionSheetController) -> Void in
            print("handle Logout action...")
            
            try! FIRAuth.auth()?.signOut()
            AppState.sharedInstance.signedIn = false
            
            let next = self.storyboard?.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController!
            self.navigationController?.pushViewController(next, animated: true)
        }))
        
        self.presentViewController(actionSheetController, animated: true, completion: nil)
        
    }
    
    @IBAction func actionAddFriends(sender: AnyObject) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("AddContactsViewController") as! AddContactsViewController!
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func actionMyFriendRequest(sender: AnyObject) {
        //InboxViewController
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("InboxViewController") as! InboxViewController!
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func actionRecentChat(sender: AnyObject) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("RecentChatViewController") as! RecentChatViewController!
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func networkButton(sender: AnyObject) {
        let next = self.storyboard?.instantiateViewControllerWithIdentifier("GroupViewController") as! GroupViewController!
        self.navigationController?.pushViewController(next, animated: true)
    }
    
    
    
    // Perform the search.
    private func getGroups(showLoader:Bool = true)
    {
        if showLoader == true {
            SVProgressHUD.showWithStatus("Loading..")
        }
        //        barSearchResults = bars.filter({ (bar) -> Bool in
        //            if let name = bar["venueName"] as? String {
        //                return (name.rangeOfString(searchString, options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil, locale: nil) != nil) ? true : false
        //            }
        //            return false
        //        })
        //        print(barSearchResults.count)
        //        searchResultController.reloadDataWithArray(barSearchResults)
        
        //        if isRefreshingData == true {
        //            return
        //        }
        
        //isRefreshingData = true
        let myGroup = dispatch_group_create()
        
        dispatch_group_enter(myGroup)
        
        //.queryOrderedByChild("name").queryEqualToValue("testios")
        SVProgressHUD.showWithStatus("Loading..")
        FIRDatabase.database().reference().child("groups").observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            myGroups.removeAll()
            
            print("\(NSDate().timeIntervalSince1970) -- \(snapshot.childrenCount)")
            //self.tblGroups.reloadData()
            for child in snapshot.children {
                
                var placeDict = Dictionary<String,AnyObject>()
                let childDict = child.valueInExportFormat() as! NSDictionary
                //print(childDict)
                
                let snap = child as! FIRDataSnapshot
                //let jsonDic = NSJSONSerialization.JSONObjectWithData(childDict, options: NSJSONReadingOptions.MutableContainers, error: &error) as Dictionary<String, AnyObject>;
                for key : AnyObject in childDict.allKeys {
                    let stringKey = key as! String
                    if let keyValue = childDict.valueForKey(stringKey) as? String {
                        placeDict[stringKey] = keyValue
                    } else if let keyValue = childDict.valueForKey(stringKey) as? Double {
                        placeDict[stringKey] = "\(keyValue)"
                    }
                    else if let keyValue = childDict.valueForKey(stringKey) as? Dictionary<String,AnyObject> {
                        placeDict[stringKey] = keyValue
                    }
                    else if let keyValue = childDict.valueForKey(stringKey) as? NSDictionary {
                        placeDict[stringKey] = keyValue
                    }
                    
                }
                placeDict["key"] = child.key
                
                if let members = placeDict["members"] as? Dictionary<String,AnyObject>
                    where members.indexForKey(myUserID ?? "") != nil {
                    myGroups.append(placeDict)
                } else {
                    print("it's Not My group - \(placeDict["key"])")
                }
                
                
                //print(placeDict)
            }
            dispatch_group_leave(myGroup)
        })
        dispatch_group_notify(myGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            dispatch_async(dispatch_get_main_queue()) {
                // update UI
                SVProgressHUD.dismiss()
                //self.isRefreshingData = false
                
                print(myGroups.count)
                self.tblGroupList.reloadData()
            }
        }
    }
    
    private func observeNewlyAddedGroups()
    {
        FIRDatabase.database().reference().child("groups").observeEventType(.ChildAdded, withBlock: {(snapshot: FIRDataSnapshot) -> Void in
            if snapshot.exists() {
                if var dic = snapshot.valueInExportFormat() as? [String:AnyObject] {
                    
                    if let members = dic["members"] as? Dictionary<String,AnyObject>
                        where members.indexForKey(myUserID ?? "") != nil
                    {
                        dic["key"] = snapshot.key
                        
                        myGroups.append(dic)
                        
                        self.tblGroupList.reloadData()
                        //self.tblGroupList.insertRowsAtIndexPaths([NSIndexPath(forRow: myGroups.count-1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Left)
                    } else {
                        print("it's Not My group - \(dic["key"])")
                    }
                }
            }
        })
    }
    
    func updateFriendRequestsCount() {
        
        if AppState.friendReqCount != 0 {
            self.lblFriendReqBadge.text = String(format: "%d",AppState.friendReqCount)
            self.lblFriendReqBadge.hidden = false
        } else {
            self.lblFriendReqBadge.hidden = true
        }
        
        let userId = FIRAuth.auth()?.currentUser?.uid
        let ref = self.ref.child("users").child(userId!).child("friendRequests")
        
        ref.observeEventType(.Value, withBlock: { snapshot in
            
            AppState.friendReqCount = snapshot.children.allObjects.count
            if AppState.friendReqCount != 0 {
                self.lblFriendReqBadge.text = String(format: "%d",AppState.friendReqCount)
                self.lblFriendReqBadge.hidden = false
            } else {
                self.lblFriendReqBadge.hidden = true
            }
            
            }, withCancelBlock: { error in
                print(error.description)
        })
    }
    
    
    func updateUnreadRecentChatsCount() {
        
        let firstGroup = dispatch_group_create()
        var recents: [AnyObject] = []
        var recentIds: [AnyObject] = []
        var unreadConversionCount = 0
        var unreadMsgCount = 0
        
        let userID = FIRAuth.auth()?.currentUser?.uid ?? ""
        let firebase: FIRDatabaseReference = FIRDatabase.database().referenceWithPath(FRECENT_PATH)
        dispatch_group_enter(firstGroup)
        firebase.queryOrderedByChild(FRECENT_USERID).queryEqualToValue(userID).observeSingleEventOfType(.Value, withBlock: {(snapshot: FIRDataSnapshot) -> Void in
            if snapshot.exists() {
                recents.removeAll()
                //Sort array by dict[FRECENT_UPDATEDAT]
                let enumerator = snapshot.children
                while let rest = enumerator.nextObject() as? FIRDataSnapshot {
                    print(rest.value)
                    if let dic = rest.value as? [String:AnyObject] {
                        print("Conversation : \(dic)")
                        recents.append(dic)
                        recentIds.append(dic[FRECENT_GROUPID] as? String ?? "")
                        
                        let GroupId = dic[FRECENT_GROUPID] as? String ?? ""
                        let firebase2: FIRDatabaseReference = FIRDatabase.database().referenceWithPath(FMESSAGE_PATH).child(GroupId)
                        
                        
                        let OppUserId = dic[FRECENT_OPPUSERID] as? String ?? ""
                        dispatch_group_enter(firstGroup)
                        
                        firebase2.queryOrderedByChild(FMESSAGE_STATUS).queryEqualToValue(TEXT_DELIVERED).observeSingleEventOfType(.Value, withBlock: {(snapshot: FIRDataSnapshot) -> Void in
                            if snapshot.exists() {
                                print(snapshot.childrenCount)
                                let enumerator = snapshot.children
                                var UnreadMsgCount = 0
                                while let rest = enumerator.nextObject() as? FIRDataSnapshot {
                                    print("rest.key =>>  \(rest.key) =>>   \(rest.value)")
                                    if var dic = rest.value as? [String:AnyObject] where (dic[FRECENT_USERID] as? String ?? "") ==  OppUserId {
                                        print(rest.key)
                                        print("Conversation : \(dic)")
                                        UnreadMsgCount += 1
                                    }
                                }
                                if UnreadMsgCount != 0 {
                                    unreadConversionCount += 1
                                    unreadMsgCount += UnreadMsgCount
                                }
                            }
                            dispatch_group_leave(firstGroup)
                        })
                    }
                }
            }
            dispatch_group_leave(firstGroup)
            //createRecentObservers
        })
        
        
        dispatch_group_notify(firstGroup, dispatch_get_main_queue()) {
            AppState.unreadConversionCount =  unreadConversionCount
            AppState.unreadConversionCount =  unreadConversionCount
            if AppState.unreadConversionCount != 0 {
                self.lblUnreadConBadge.text = String(format: "%d",AppState.unreadConversionCount)
                self.lblUnreadConBadge.hidden = false
            } else {
                self.lblUnreadConBadge.hidden = true
            }
        }
    }
    /*
    // Firebase invite
 
    func inviteTapped()
    {
        if let invite = FIRInvites.inviteDialog() {
            invite.setInviteDelegate(self)
            
            // NOTE: You must have the App Store ID set in your developer console project
            // in order for invitations to successfully be sent.
            
            // A message hint for the dialog. Note this manifests differently depending on the
            // received invation type. For example, in an email invite this appears as the subject.
            //invite.setMessage("Try this out!\n -\(GIDSignIn.sharedInstance().currentUser.profile.name)")
            invite.setMessage("Try this out!\n my group group1")
            // Title for the dialog, this is what the user sees before sending the invites.
            invite.setTitle("Invites Example")
            invite.setDeepLink("app_url")
            invite.setCallToActionText("Install!")
            invite.setCustomImage("https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png")
            invite.open()
        }
    }

    func inviteFinishedWithInvitations(invitationIds: [AnyObject], error: NSError?) {
        if let error = error {
            print("Failed: " + error.localizedDescription)
        } else {
            print("Invitations sent")
        }
    }
    */
    
    // MARK: - Delegates & DataSource
    
    // MARK: - Delegates
    // MARK: -  UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if myGroups.count == 0 {
            let emptyLabel = UILabel(frame: tableView.frame)
            emptyLabel.text = "You do not have any group!"
            emptyLabel.textColor = UIColor.darkGrayColor();
            emptyLabel.textAlignment = .Center;
            emptyLabel.numberOfLines = 3
            
            tableView.backgroundView = emptyLabel
            tableView.separatorStyle = UITableViewCellSeparatorStyle.None
            return 0
        } else {
            tableView.backgroundView = nil
            return myGroups.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("cellIdentifier", forIndexPath: indexPath) as! UITableViewCell
        
//        var cell:UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("cellIdentifier")
//        if cell == nil {
//            cell = UITableViewCell(style: UITableViewCellStyle.Value2, reuseIdentifier: "cellIdentifier")
//        }
        
        cell?.textLabel?.text = myGroups[indexPath.row]["groupName"] as? String ?? "-"
        cell?.detailTextLabel?.text = "\((myGroups[indexPath.row]["members"] as? NSDictionary)?.count ?? 0) Friends"
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        print("TableView view selected index path \(indexPath)")
        
        let chatVc = self.storyboard?.instantiateViewControllerWithIdentifier("ChatViewController") as! ChatViewController!
        chatVc.groupID = myGroups[indexPath.row]["key"] as? String ?? ""
        chatVc.senderId = FIRAuth.auth()?.currentUser?.uid
        chatVc.senderDisplayName = "User"
        self.navigationController?.pushViewController(chatVc, animated: true)
    }
    
//    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
//        tableView.deselectRowAtIndexPath(indexPath, animated: true)
//        print("TableView view selected index path \(indexPath)")
//    }
}
