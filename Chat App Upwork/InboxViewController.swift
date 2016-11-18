//
//  InboxViewController.swift
//  Connect App
//
//  Created by devel on 7/6/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
import SVProgressHUD

//View Friend Request
class InboxViewController: UIViewController ,UITableViewDataSource, UITableViewDelegate {
    
    var ref:FIRDatabaseReference!
    var userArry: [UserData] = []
    var userName: String?
    var photoURL: String?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.tableView.allowsSelection = false
        
        
        ref = FIRDatabase.database().reference()
        let userID = FIRAuth.auth()?.currentUser?.uid
        let frRef = ref.child("users").child(userID!).child("friendRequests")
        
        frRef.observeEventType(.Value, withBlock: { snapshot in
            
            self.userArry.removeAll()
            print(snapshot.value)
            if let friendRequests = snapshot.value as?[String: String] {
                for(_, value) in friendRequests{
                    
                    let uRef = self.ref.child("users").child(value)
                    uRef.observeSingleEventOfType(FIRDataEventType.Value, withBlock: { snapshot in
                        
                        print(snapshot.value)
                        
                        if !(snapshot.value is NSNull)
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
                                self.userArry.append(UserData(userName: self.userName!, photoURL: self.photoURL, uid: snapshot.key, image: image, email: email, noImage: noImage))
                            } else {
                                self.userArry.append(UserData(userName: self.userName!, photoURL: self.photoURL, uid: snapshot.key, image: image, email: "test@test.com", noImage: noImage))
                            }
                            
                            self.tableView.reloadData()
                        }
                        
                    })
                }
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func  preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    @IBAction func backButton(sender: AnyObject) {
        //self.dismissViewControllerAnimated(true, completion: nil)
        self.navigationController?.popViewControllerAnimated(true)  //Changed to Push
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if userArry.count == 0 {
            let emptyLabel = UILabel(frame: tableView.frame)
            emptyLabel.text = "No pending friend request"
            emptyLabel.textColor = UIColor.darkGrayColor();
            emptyLabel.textAlignment = .Center;
            emptyLabel.numberOfLines = 3
            
            tableView.backgroundView = emptyLabel
            tableView.separatorStyle = UITableViewCellSeparatorStyle.None
            return 0
        } else {
            tableView.backgroundView = nil
            return userArry.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell1") as! FriendRequestTableViewCell
        
        cell.profilePic.layer.masksToBounds = true
        cell.profilePic.layer.cornerRadius = cell.profilePic.frame.width/2
        
        cell.userNameLabel.text = userArry[indexPath.row].getUserName()
        let imageExist = userArry[indexPath.row].imageExist()
        if imageExist {
            let image = userArry[indexPath.row].getImage()
            cell.profilePic.image = image
        } else {
            if !userArry[indexPath.row].getUserPhotoURL().isEmpty {
                cell.profilePic.sd_setImageWithURL(NSURL(string: userArry[indexPath.row].getUserPhotoURL()), placeholderImage: UIImage(named: "no-pic.png"))
            }
        }
        
        cell.onAcceptButtonTapped = {
            
            FIRDatabase.database().reference().child("users").child(myUserID!).observeSingleEventOfType(.Value, withBlock: { (snapshot: FIRDataSnapshot) in
                //
                
                AppState.sharedInstance.currentUser = snapshot
                
                let friendRequests = AppState.sharedInstance.currentUser.value!["friendRequests"]
                let fid = self.userArry[indexPath.row].getUid()
                var requests = friendRequests as! [String:String]
                
                for (key, value) in requests {
                    if value == fid {
                        requests.removeValueForKey(key)
                    }
                }
                
                //let userID = FIRAuth.auth()?.currentUser?.uid
                let userRef = self.ref.child("users").child(myUserID!)
                
                let dic = ["friendRequests" : requests]
                
                userRef.updateChildValues(dic)
                userRef.child("friends").childByAutoId().setValue(fid)
                
                let friendRef = self.ref.child("users").child(fid)
                friendRef.child("friends").childByAutoId().setValue(myUserID!)
                
                self.userArry.removeAtIndex(indexPath.row)
                self.tableView.reloadData()
                
            }, withCancelBlock: { (error: NSError) in
                //
                SVProgressHUD.showErrorWithStatus("Action failed!")
            })
            
            
//            FIRDatabase.database().reference().child("users").child(fid).child("userInfo").observeSingleEventOfType(.Value, withBlock: {(snapshot: FIRDataSnapshot) -> Void in
//                
//                let userInfo = snapshot.valueInExportFormat() as? NSMutableDictionary ?? NSMutableDictionary()
//                let token = userInfo["deviceToken"] as? String ?? ""
//                
//                if token.characters.count > 1 {
//                    
//                    Alamofire.request(.GET, "http://www.unitedpeoplespower.com/api/notifications.php", parameters: ["token": token,"message":"Your friend is accepted!","type":"friendRequest","data":"friendRequest"])
//                        .responseJSON { response in
//                            switch response.result {
//                            case .Success:
//                                print("Notification sent successfully")
//                            case .Failure(let error):
//                                print(error)
//                            }
//                    }
//                    
//                }
//            })
            
        }
        
        cell.onDeclineButtonTapped = {
            
            FIRDatabase.database().reference().child("users").child(myUserID!).observeSingleEventOfType(.Value, withBlock: { (snapshot: FIRDataSnapshot) in
                //
                
                AppState.sharedInstance.currentUser = snapshot
                
                let friendRequests = AppState.sharedInstance.currentUser.value!["friendRequests"]
                let fid = self.userArry[indexPath.row].getUid()
                var requests = friendRequests as! [String:String]
                
                for (key, value) in requests {
                    if value == fid {
                        requests.removeValueForKey(key)
                    }
                }
                
                let userID = FIRAuth.auth()?.currentUser?.uid
                let userRef = self.ref.child("users").child(userID!)
                let dic = ["friendRequests" : requests]
                
                userRef.updateChildValues(dic) { (error, firebase) in
                    if error == nil {
                        userRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                            // Get user value
                            AppState.sharedInstance.currentUser = snapshot
                        }) { (error) in
                            print(error.localizedDescription)
                        }
                    } else {
                        print(error?.description)
                    }
                }
                self.userArry.removeAtIndex(indexPath.row)
                self.tableView.reloadData()
                
            }, withCancelBlock: { (error: NSError) in
                    //
                    SVProgressHUD.showErrorWithStatus("Action failed!")
            })
            
        }
        
        return cell
    }
    
    
}