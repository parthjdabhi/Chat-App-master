//
//  ChatViewController.swift
//  Chat App Upwork
//
//  Created by Dustin Allen on 11/10/16.
//  Copyright © 2016 Harloch. All rights reserved.
//


import UIKit
import Firebase
import JSQMessagesViewController
import SDWebImage
import Alamofire

class ChatViewController: JSQMessagesViewController {
    
    // MARK: Properties
    var groupID: String!
    let myUserID = FIRAuth.auth()?.currentUser?.uid
    
    let rootRef = FIRDatabase.database().reference()
    var messageRef: FIRDatabaseReference!
    var messages = [JSQMessage]()
    
    var userIsTypingRef: FIRDatabaseReference!
    var usersTypingQuery: FIRDatabaseQuery!
    
    private var localTyping = false
    var isTyping: Bool {
        get {
            return localTyping
        }
        set {
            localTyping = newValue
            userIsTypingRef.setValue(newValue)
        }
    }
    
    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var incomingBubbleImageView: JSQMessagesBubbleImage!
    
    var navigationBar = UINavigationBar()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageRef = rootRef.child("groupchat").child(groupID)
        
        self.inputToolbar.contentView.leftBarButtonItem = nil
        self.topContentAdditionalInset = 44
        
        setupBubbles()
        // No avatars
        //collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
        
        // Create the navigation bar
        navigationBar = UINavigationBar(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 64))
        // Offset by 20 pixels vertically to take the status bar into account
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        navigationBar.tintColor = UIColor.whiteColor()
        navigationBar.barTintColor = AppState.sharedInstance.appBlueColor
        navigationBar.translucent = false
        
        // Create a navigation item with a title
        let navigationItem = UINavigationItem()
        navigationItem.title = "Chat"
        let leftButton =  UIBarButtonItem(title: "Back", style:   UIBarButtonItemStyle.Plain, target: self, action: #selector(self.ActionGoBack(_:)))
        leftButton.tintColor = UIColor.whiteColor()
        navigationItem.leftBarButtonItem = leftButton
        navigationBar.items = [navigationItem]
        
        self.view.addSubview(navigationBar)
        
        JSQMessagesCollectionViewCell.registerMenuAction(#selector(ChatViewController.spam(_:)))
        JSQMessagesCollectionViewCell.registerMenuAction(#selector(ChatViewController.reportUser(_:)))
        UIMenuController.sharedMenuController().menuItems = [UIMenuItem.init(title: "Block", action: #selector(ChatViewController.spam(_:))),UIMenuItem.init(title: "Report user", action: #selector(ChatViewController.reportUser(_:)))]
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        observeMessages()
        observeTyping()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func  preferredStatusBarStyle()-> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    
    
    //Start Blocking functions
    func didReviceMenuAction() {
        print("didReviceMenuAction")
    }
    
    func spam(sender: AnyObject?) {
        print("Block user")
    }
    
    func reportUser(sender: AnyObject?) {
        print("Report user")
    }
    
    override func didReceiveMenuWillShowNotification(notification: NSNotification!) {
        UIMenuController.sharedMenuController().menuItems = nil
        UIMenuController.sharedMenuController().menuItems = [UIMenuItem.init(title: "Block", action: #selector(ChatViewController.spam(_:))),UIMenuItem.init(title: "Report user", action: #selector(ChatViewController.reportUser(_:)))]
    }
    
    
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            //CANNOT BLOCK MY SELF
            return false
        } else {
            return true
        }
        //return true
    }
    
    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            //CANNOT BLOCK MY SELF
            return false
        } else {
            return (action == #selector(ChatViewController.spam(_:))) || (action == #selector(ChatViewController.reportUser(_:)))
        }
        //return action == #selector(PrivateChatViewController.spam(_:))
    }
    
    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
        if  action == #selector(ChatViewController.spam(_:)){
            print("Block user")
            //Remove recent chat
            //Set Friend status to Zero
            //Remove from friend list
            
            
            let message = messages[indexPath.item]
            
            if message.senderId == senderId {
                //CANNOT BLOCK MY SELF
            }
            else
            {
                CommonUtils.sharedUtils.showProgress(self.view, label: "Blocking User..")
                /// Add Block users entry
                //let ref: FIRDatabaseReference = FIRDatabase.database().reference().child(cityNodeName).child("\(cityNodeName)_blockedUser")
                let ref: FIRDatabaseReference = FIRDatabase.database().reference().child("blocked").child("\(groupID)_blockedUser")
                //let friendRequestRef = ref.childByAutoId()
                //friendRequestRef.setValue(myUserID)
                ref.child(message.senderId!).setValue("1")
                
                //Remove That message
                //FIRDatabase.database().reference().child(cityNodeName).child(message.key).removeValue()
                
                self.messages.removeObject(message)
                
                self.collectionView.deleteItemsAtIndexPaths([indexPath])
                
                CommonUtils.sharedUtils.hideProgress()
            }
            
            
            
            //            CommonUtils.sharedUtils.showProgress(self.view, label: "Blocking User..")
            //
            //            let MyGroup = dispatch_group_create()
            //
            //            //Remove Friends Id to my myfriend
            //            dispatch_group_enter(MyGroup)
            //            ref.child("users").child(senderId).child("myFriends").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            //                if let FriendReqUserDetail = snapshot.valueInExportFormat() as? NSDictionary {
            //                    let arrFriends =  NSMutableArray(array: FriendReqUserDetail.allValues)
            //                    //print("\(self.UserID) :: \(arrFriendReqs)")
            //
            //                    if arrFriends.containsObject(self.OppUserId!) {
            //                        arrFriends.removeObject(self.OppUserId!)
            //                        dispatch_group_enter(MyGroup)
            //                        self.ref.child("users").child(self.senderId).updateChildValues(["myFriends":arrFriends]) { (error, reference) in
            //
            //                            if error == nil {
            //                                print("successfully Removed MyUserID from their myFriends ")
            //                            }else  {
            //                                print("Faail to remove id From myFriends array")
            //                            }
            //                            dispatch_group_leave(MyGroup)
            //                        }
            //                    }
            //                }
            //                dispatch_group_leave(MyGroup)
            //            })
            //
            //            //Remove My user Id to Friends's myfriend
            //            dispatch_group_enter(MyGroup)
            //            ref.child("users").child(self.OppUserId!).child("myFriends").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            //                if let FriendReqUserDetail = snapshot.valueInExportFormat() as? NSDictionary {
            //                    let arrFriends =  NSMutableArray(array: FriendReqUserDetail.allValues)
            //                    //print("MyUserID >> \(self.MyUserID) :: \(arrFriendReqs)")
            //
            //                    if arrFriends.containsObject(self.senderId!) {
            //                        arrFriends.removeObject(self.senderId!)
            //                        dispatch_group_enter(MyGroup)
            //                        self.ref.child("users").child(self.OppUserId!).updateChildValues(["myFriends":arrFriends]) { (error, reference) in
            //
            //                            if error == nil {
            //                                print("successfully Removed Friend id from my myFriends ")
            //                            }else  {
            //                                print("Faail to remove id From myFriends array")
            //                            }
            //                            dispatch_group_leave(MyGroup)
            //                        }
            //                    }
            //                }
            //                dispatch_group_leave(MyGroup)
            //            })
            //
            //            //groupId
            //            //Remove conversation messages
            //            print("Removing groupId : \(groupId)")
            //            self.ref.child(FMESSAGE_PATH).child(groupId!).removeValue()
            //
            //            //Remove Recent Entries
            //            let firebase: FIRDatabaseReference = FIRDatabase.database().referenceWithPath(cityNodeName)
            //            let query: FIRDatabaseQuery = firebase.queryOrderedByChild(FRECENT_GROUPID).queryEqualToValue(groupId)
            //            dispatch_group_enter(MyGroup)
            //            query.observeSingleEventOfType(.Value, withBlock: {(snapshot: FIRDataSnapshot) -> Void in
            //                if snapshot.exists() {
            //                    print(snapshot.childrenCount) // I got the expected number of items
            //                    let enumerator = snapshot.children
            //                    while let rest = enumerator.nextObject() as? FIRDataSnapshot {
            //                        print(rest.key)
            //                        print("Removing : \(rest.key)")
            //                        self.ref.child(FRECENT_PATH).child(rest.key).removeValue()
            //                        //                        if let dictionary = rest.value as? [NSString : AnyObject]
            //                        //                            where ((dictionary[FRECENT_USERID] as! String) == self.MyUserID! || (dictionary[FRECENT_USERID] as! String) == self.senderId!)
            //                        //                        {
            //                        //                            print("Removing : \(rest.key)")
            //                        //                            //self.ref.child(FRECENT_PATH).child(rest.key).removeValue()
            //                        //                        }
            //                    }
            //                }
            //                dispatch_group_leave(MyGroup)
            //            })
            //
            //            //self.FirRef?.child("users").child(self.MyUserID!).child("myFriends").child(self.MyUserID!).removeValue()
            //
            //            dispatch_group_notify(MyGroup, dispatch_get_main_queue()) {
            //                CommonUtils.sharedUtils.hideProgress()
            //
            //                let MainScreenVC: MainScreenViewController = self.storyboard!.instantiateViewControllerWithIdentifier("MainScreenViewController") as! MainScreenViewController
            //                self.navigationController?.pushViewController(MainScreenVC, animated: true)
            //            }
        }
        else if  action == #selector(ChatViewController.reportUser(_:))
        {
            let message = messages[indexPath.item]
            
            if message.senderId == senderId {
                //CANNOT BLOCK MY SELF
                return
            }
            
            //Messageid,userid,email and message text
            
            CommonUtils.sharedUtils.showProgress(self.view, label: "Submitting report..")
            FIRDatabase.database().reference().child("users").child(message.senderId).child("userInfo").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                
                var email = ""
                CommonUtils.sharedUtils.hideProgress()
                
                if let userInfo = snapshot.valueInExportFormat() as? NSDictionary {
                    email = userInfo["email"] as? String ?? ""
                }
                
                let message = "Message Id : \(message.key) \n Message Text: \(message.text) Email  : \(email) \nSent By : \(message.senderId) \nBlock Requset Sent by : \(self.myUserID ?? "") \n Reported on \(NSDate.init()) for group chat"
                //let message = "message Id : \(self.groupId ?? "") \n Message Text: \(text) Email  : \(email) (\(name)) \nSent By : \(self.senderId) on \(date) \nBlock Requset Sent by : \(FIRAuth.auth()?.currentUser?.uid ?? "") \n Reported on \(NSDate.init()) for personal chat"
                
                Alamofire.request(.GET, "http://trainersmatchapp.com/poketrainerapp/api/reportUser.php", parameters: ["from": email ,"subject":"Request to block user in group chat","message":message])
                    .responseJSON { response in
                        debugPrint(response.result.value)
                        var msg = ""
                        if let result = response.result.value as? NSDictionary
                            where (result["result"] as? String ?? "") == "true"
                        {
                            msg = "Thank you, Your report submitted successfully. Our team will soon takes appropriate action."
                        } else {
                            msg = "Failed to submit report."
                        }
                        let sendMailErrorAlert = UIAlertView(title: "Message", message: msg , delegate: nil, cancelButtonTitle: "OK")
                        sendMailErrorAlert.show()
                }
            })
            
        }
    }
    
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        if action == #selector(ChatViewController.spam(_:)) {
            return true
        }
        else if action == #selector(ChatViewController.reportUser(_:)) {
            return true
        }
        return super.canPerformAction(action, withSender:sender)
    }
    //End  Blocking Functions
    
    
    //Go Back to Previous screen
    @IBAction func ActionGoBack(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("sdfasdfdfasdfasdf")
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            return outgoingBubbleImageView
        } else { // 3
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            cell.textView!.textColor = UIColor.whiteColor()
        } else {
            cell.textView!.textColor = UIColor.blackColor()
            
            //let cell:JSQMessagesCollectionViewCell = super.collectionView(collectionView, avatarImageDataForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
            //return JSQMessagesAvatarImageFactory.circularAvatarHighlightedImage(UIImage(named: "POKE-TRAINER-LOGO.png"), withDiameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
            FIRDatabase.database().reference().child("users").child(message.senderId).child("profileData").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                AppState.sharedInstance.currentUser = snapshot
                if let base64String = snapshot.value!["userPhoto"] as? String {
                    cell.avatarImageView.image = JSQMessagesAvatarImageFactory.circularAvatarImage(CommonUtils.sharedUtils.decodeImage(base64String), withDiameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
                } else {
                    if let facebookData = snapshot.value!["facebookData"] as? [String : String] {
                        if let image_url = facebookData["profilePhotoURL"]  {
                            print(image_url)
                            let image_url_string = image_url
                            let url = NSURL(string: "\(image_url_string)")
                            cell.avatarImageView.sd_setImageWithURL(url)
                        }
                    }
                }})
            //cell.avatarImageView.sd_setImageWithURL(NSURL.init(string:self.userSession.profilePictureUrl), placeholderImage: UIImage(named: "POKE-TRAINER-LOGO.png"))
        }
        
        cell.textView.selectable = false
        
        return cell
    }
    
    
    override func collectionView(collectionView: JSQMessagesCollectionView, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath) -> NSAttributedString?
    {
        if (indexPath.item % 3 == 0) {
            //let message = self.messages[indexPath.item]
            //return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(message.date)
        }
        
        return nil
        
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.item % 3 == 0 {
            //return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        
        return 0.0
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let currentMessage = self.messages[indexPath.item]
        
        if currentMessage.senderId == self.senderId {
            return 0.0
        }
        
        if indexPath.item - 1 > 0 {
            let previousMessage = self.messages[indexPath.item - 1]
            if previousMessage.senderId == currentMessage.senderId {
                return 0.0
            }
        }
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath) -> NSAttributedString? {
        let message = messages[indexPath.item]
        
        if message.senderId == self.senderId {
            //return nil
        }
        
        //let range = message.senderDisplayName.rangeOfString(message.senderDisplayName)
        let attributedString = NSMutableAttributedString(string:message.senderDisplayName)
        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.lightGrayColor() , range: NSRangeFromString(message.senderDisplayName))
        return attributedString
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        return nil
        /*
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            return nil
        }
        else
        {
            var jsqAvtarImg = JSQMessagesAvatarImage.avatarWithImage(UIImage(named: "POKE-TRAINER-LOGO.png"))
            return jsqAvtarImg
        }
        */
    }
    
    
    private func observeMessages() {
        let messagesQuery = messageRef.queryLimitedToLast(25)
        messagesQuery.observeEventType(.ChildAdded, withBlock: { (snapshot) in
            if let id = snapshot.value!["senderId"] as? String {
                //let id = snapshot.value!["senderId"] as! String
                let text = snapshot.value!["text"] as! String
                let senderName = snapshot.value!["senderName"] as? String ?? id
                let createdAt = snapshot.value!["createdAt"] as? String ?? ""
                
                self.addMessage(id, text: text,displayName: senderName,createdAt: createdAt,key: snapshot.key)
                self.finishReceivingMessage()
            }
        })
    }
    
    private func observeTyping()
    {
        let typingIndicatorRef = rootRef.child("typingIndicator")
        userIsTypingRef = typingIndicatorRef.child(senderId)
        userIsTypingRef.onDisconnectRemoveValue()
        usersTypingQuery = typingIndicatorRef.queryOrderedByValue().queryEqualToValue(true)
        
        usersTypingQuery.observeEventType(.ChildAdded, withBlock: { (data) in
            
            if data.childrenCount == 1 && self.isTyping {
                return
            }
            
            self.showTypingIndicator = data.childrenCount > 0
            self.scrollToBottomAnimated(true)
        })
        
    }
    
    func addMessage(id: String, text: String,displayName: String,createdAt: String,key: String) {
        
        let message = JSQMessage(senderId: id, senderDisplayName: displayName, date: createdAt.asDate, text: text)
        //JSQMessage(senderId: id, displayName: id, text: text)
        message.key = key
        messages.append(message)
    }
    
    override func textViewDidChange(textView: UITextView) {
        super.textViewDidChange(textView)
        isTyping = textView.text != ""
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        
        let itemRef = messageRef.childByAutoId()
        let messageItem = [
            "text": text,
            "senderId": senderId,
            "senderName": AppState.sharedInstance.displayName ?? "",
            "createdAt": NSDate().customFormatted
        ]
        itemRef.setValue(messageItem)
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        finishSendingMessage()
        isTyping = false
    }
    
    private func setupBubbles() {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageView = bubbleImageFactory.outgoingMessagesBubbleImageWithColor(AppState.sharedInstance.appBlueColor)
        incomingBubbleImageView = bubbleImageFactory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    }
    
}

extension RangeReplaceableCollectionType where Generator.Element : Equatable {
    
    // Remove first collection element that is equal to the given `object`:
    mutating func removeObject(object : Generator.Element) {
        if let index = self.indexOf(object) {
            self.removeAtIndex(index)
        }
    }
}