//
//  AddContactsViewController.swift
//  Connect App
//
//  Created by super on 7/2/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
import Alamofire

class AddContactsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    var ref:FIRDatabaseReference!
    var userArry: [UserData] = []
    var filtered:[UserData] = []
    var userName: String?
    var photoURL: String?
    var searchActive : Bool = false
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchBar.delegate = self
        self.tableView.allowsSelection = false
        
        // Load Data from Firebase
        CommonUtils.sharedUtils.showProgress(self.view, label: "Loading...")
        ref = FIRDatabase.database().reference()
        let userID = FIRAuth.auth()?.currentUser?.uid
        ref.child("users").observeEventType(FIRDataEventType.Value, withBlock: { snapshot in
            self.userArry.removeAll()
            self.filtered.removeAll()
            for childSnap in  snapshot.children.allObjects {
                let snap = childSnap as! FIRDataSnapshot
                
                var contained = false
                
                if let friendRequests = snap.value!["friendRequests"] as? [String: String]
                {
                    for (_,value) in friendRequests {
                        if value == userID {
                            contained = true
                            print("friend requested")
                        }
                    }
                }
                
                if let friends = snap.value!["friends"] as? [String: String]
                {
                    for (_,value) in friends {
                        if value == userID {
                            contained = true
                            print("already friends")
                        }
                    }
                }
                
                
                if userID != snap.key
                    && contained == false
                {
                    let userFirstName:String = snap.value!["username"] as? String ?? ""
                    //let userLastName:String = snap.value!["userLastName"] as? String ?? ""
                    var noImage = false
                    var image = UIImage(named: "no-pic.png")
                    if let base64String = snap.value!["image"] as! String! {
                        image = CommonUtils.sharedUtils.decodeImage(base64String)
                    } else {
                        noImage = true
                    }
                    
                    self.photoURL = ""
                    self.userName = userFirstName //+ " " + userLastName
                    
                    if let email = snap.value!["email"] as? String {
                        self.userArry.append(UserData(userName: self.userName!, photoURL: self.photoURL, uid: snap.key, image: image, email: email, noImage: noImage))
                    } else {
                        self.userArry.append(UserData(userName: self.userName!, photoURL: self.photoURL, uid: snap.key, image: image, email: "test@test.com", noImage: noImage))
                    }
                }
            }
            self.tableView.reloadData()
            CommonUtils.sharedUtils.hideProgress()
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func  preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    @IBAction func backBtnTapped(sender: UIButton) {
        //self.dismissViewControllerAnimated(true, completion: nil)
        self.navigationController?.popViewControllerAnimated(true)  //Changed to Push
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.endEditing(true)
        searchActive = false;
        self.searchBar.showsCancelButton = false
        self.tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        filtered = userArry.filter { user in
            return user.getUserName().lowercaseString.containsString(searchText.lowercaseString)
        }
        if searchText  == ""{
            self.searchActive = false
        }
        else {
            self.searchActive = true
        }
        self.tableView.reloadData()
    }
    
    // MARK: - Delegates
    // MARK: -  UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        var records = 0
        if self.searchActive {
            records = filtered.count
        }
        records = userArry.count
        
        if records == 0 {
            let emptyLabel = UILabel(frame: tableView.frame)
            emptyLabel.text = "No new friend founds"
            emptyLabel.textColor = UIColor.darkGrayColor();
            emptyLabel.textAlignment = .Center;
            emptyLabel.numberOfLines = 3
            
            tableView.backgroundView = emptyLabel
            tableView.separatorStyle = UITableViewCellSeparatorStyle.None
            return 0
        } else {
            tableView.backgroundView = nil
            return records
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! ContactsTableViewCell
        if self.searchActive {
            cell.userNameLabel.text = self.filtered[indexPath.row].getUserName()
            
            let imageExist = filtered[indexPath.row].imageExist()
            if imageExist {
                let image = filtered[indexPath.row].getImage()
                cell.profilePic.image = image
            } else {
                if !self.filtered[indexPath.row].getUserPhotoURL().isEmpty {
                    cell.profilePic.sd_setImageWithURL(NSURL(string: self.filtered[indexPath.row].getUserPhotoURL()), placeholderImage: UIImage(named: "no-pic.png"))
                }
            }
        }else {
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
        }
        
        // Mark send friend request to user
        cell.onAddButtonTapped = {
            print("add button tapped");
            var user: UserData
            if self.searchActive {
                user = self.filtered[indexPath.row];
            } else {
                user = self.userArry[indexPath.row];
            }
            
            let uid = user.getUid();
            let ref: FIRDatabaseReference = self.ref.child("users").child(uid).child("friendRequests");
            let friendRequestRef = ref.childByAutoId()
            let userID = FIRAuth.auth()?.currentUser?.uid
            friendRequestRef.setValue(userID)
            

            
            ref.child("users").child(uid).child("userInfo").observeSingleEventOfType(.Value, withBlock: {(snapshot: FIRDataSnapshot) -> Void in
                
                let userInfo = snapshot.valueInExportFormat() as? NSMutableDictionary ?? NSMutableDictionary()
                let token = userInfo["deviceToken"] as? String ?? ""
                
                if token.characters.count > 1 {
                    
                    Alamofire.request(.GET, "http://www.unitedpeoplespower.com/api/notifications.php", parameters: ["token": token,"message":"You have a friend request!","type":"friendRequest","data":"friendRequest"])
                        .responseJSON { response in
                            switch response.result {
                            case .Success:
                                print("Notification sent successfully")
                            case .Failure(let error):
                                print(error)
                            }
                    }
                    
                }
            })
        }
 
        return cell
    }
 
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        CommonUtils.sharedUtils.hideProgress()
    }    
}
