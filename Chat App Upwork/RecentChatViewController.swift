//
//  RecentChatViewController.swift
//  PokeTrainerApp
//
//  Created by iParth on 7/31/16.
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
    
    @IBAction func ActionStartChat(sender: AnyObject) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("AddressBookViewController") as! AddressBookViewController
        self.navigationController?.pushViewController(vc, animated: true)
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
        
        cell.imgUser?.layer.masksToBounds = true
        cell.imgUser?.layer.cornerRadius = (cell.imgUser?.frame.size.width ?? 1)/2
        
        if let recent = self.recents[indexPath.row] as? [String:AnyObject] {
            
            cell.lblLastMsg?.text = recent[FRECENT_LASTMESSAGE] as? String ?? ""
            
            let date = (recent[FRECENT_UPDATEDAT] as? String ?? "").asDate
            cell.lblElapsed?.text = date?.getElapsedInterval()
            
            let GroupId = recent[FRECENT_GROUPID] as? String ?? ""
            let firebase2: FIRDatabaseReference = FIRDatabase.database().referenceWithPath(FMESSAGE_PATH).child(GroupId)
            
            
            let OppUserId = recent[FRECENT_OPPUSERID] as? String ?? ""
            
            // status - Delivered
            firebase2.queryOrderedByChild(FMESSAGE_STATUS).queryEqualToValue(TEXT_DELIVERED).observeSingleEventOfType(.Value, withBlock: {(snapshot: FIRDataSnapshot) -> Void in
                if snapshot.exists() {
                    //Sort array by dict[FRECENT_UPDATEDAT]
                    print(snapshot.childrenCount)
                    
                    let enumerator = snapshot.children
                    var UnreadMsgCount = 0
                    //var lastMsgText = ""
                    
                    while let rest = enumerator.nextObject() as? FIRDataSnapshot {
                        print("rest.key =>>  \(rest.key) =>>   \(rest.value)")
                        if var dic = rest.value as? [String:AnyObject] where (dic[FRECENT_USERID] as? String ?? "") ==  OppUserId {
                            print(rest.key)
                            print("Convesation : \(dic)")
                            UnreadMsgCount += 1
                        }
                        cell.lblCount?.text = (UnreadMsgCount != 0) ? "\(UnreadMsgCount) New" : nil
                    }
                }
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
            
            
            let firebase: FIRDatabaseReference = FIRDatabase.database().referenceWithPath("users")
            firebase.child((recent[FRECENT_OPPUSERID] as? String ?? "")).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                
                let UserDetail = snapshot.valueInExportFormat() as? NSDictionary
                //print(UserDetail)
                
                cell.lblName?.text = UserDetail?["username"] as? String ?? "-"
                
//                if let base64String = UserDetail?["image"] as? String {
//                    // decode image
//                    cell.imgUser?.image = CommonUtils.sharedUtils.decodeImage(base64String)
//                }
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
            
            let chatVc = self.storyboard?.instantiateViewControllerWithIdentifier("MyChatViewController") as! MyChatViewController!
            chatVc.groupId = GroupId
            chatVc.senderDisplayName = AppState.sharedInstance.friend?.userName ?? ""
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