//
//  GroupViewController.swift
//  Chat App Upwork
//
//  Created by Dustin Allen on 10/28/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit
import Firebase

class GroupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, SearchVCDelegates {
    
    @IBOutlet var groupField: UITextField!
    @IBOutlet var tblParticipants: UITableView!
    
    // MARK: Properties
    var ref:FIRDatabaseReference! = FIRDatabase.database().reference()
    var user: FIRUser!
    
    var searchResultController:SearchResultsController!
    
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        searchResultController = SearchResultsController()
        searchResultController.delegate = self
        
        //Users = Array()
        selectedUser = Array()
        loadUsers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func createGroup(sender: AnyObject) {
        
        if groupField.text?.characters.count == 0 {
            // Need group name
        } else if selectedUser.count == 0 {
            // No Participants
        }
        
        ref = FIRDatabase.database().reference()
        let userID = FIRAuth.auth()?.currentUser?.uid
        
        var members:[String:String] = [userID ?? "": ""]
        
        for usr in selectedUser {
            members[(usr["key"] as? String ?? "")] = (usr["username"] as? String ?? "")
        }
        
        var groupData:[String:AnyObject] = ["groupName": groupField.text! as String, "creator": userID!, "createdAt": NSDate().timeIntervalSince1970]
        groupData["members"] = members
        
        print("groupData ",groupData)
        ref.child("groups").childByAutoId().updateChildValues(groupData)
        //ref.child("groups").child(group).updateChildValues(groupData)
        
        let next = self.storyboard?.instantiateViewControllerWithIdentifier("MainViewController") as! MainViewController!
        self.navigationController?.pushViewController(next, animated: true)
    }
    
    // MARK: Other
    
    func loadUsers()
    {
        //Load  Data first time from firebase
        CommonUtils.sharedUtils.showProgress(self.view, label: "We are loading list of users!")
        dispatch_group_enter(globalGroup)
        ref.child("users").queryOrderedByKey().observeSingleEventOfType(.Value, withBlock: { snapshot in
            CommonUtils.sharedUtils.hideProgress()
            dispatch_group_leave(globalGroup)
            
            if snapshot.exists()
            {
                print(snapshot.childrenCount)
                let allUsers = snapshot.valueInExportFormat() as? NSDictionary
                
                let enumerator = snapshot.children
                while let rest = enumerator.nextObject() as? FIRDataSnapshot {
                    //print("rest.key =>>  \(rest.key) =>>   \(rest.value)")
                    if var dic = rest.value as? [String:AnyObject] {
                        dic["key"] = rest.key
                        Users.append(dic)
                    }
                }
                
//                if Users.count > 0 {
//                    NSUserDefaults.standardUserDefaults().setObject(Users, forKey: "Users")
//                    NSUserDefaults.standardUserDefaults().synchronize()
//                }
                
            } else {
                // Not found any user
            }
            
        }, withCancelBlock: { error in
            print(error.description)
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            dispatch_group_leave(globalGroup)
        })
        
        dispatch_group_notify(globalGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            
            dispatch_async(dispatch_get_main_queue(),{
                
                print(" 0 - - - - - - - - - - -  - - - - - - - - - --  - - - - - -- - - - -  - - -- - - - - - - - - - - - - - -")
                
            })
        })
    }
    
    // MARK: UISearchBar
    
    func searchBar(searchBar: UISearchBar,
                   textDidChange searchText: String) {
//        let placesClient = GMSPlacesClient()
//        placesClient.autocompleteQuery(searchText, bounds: nil, filter: nil) { (results, error:NSError?) -> Void in
//            self.resultsArray.removeAll()
//            if results == nil {
//                return
//            }
//            for result in results!{
//                if let result = result as? GMSAutocompletePrediction {
//                    self.resultsArray.append(result.attributedFullText.string)
//                }
//            }
//            self.searchResultController.reloadDataWithArray(self.resultsArray)
//        }
    }
    
    func selectedUserFromSearchResult(user: Dictionary<String, AnyObject>) {
        selectedUser.append(user)
        self.tblParticipants.reloadData()
    }
    
    // MARK: UITableview
    func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 1 + selectedUser.count
        //return self.directionDetail.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("FriendTableViewCell", forIndexPath: indexPath) as! FriendTableViewCell
        if indexPath.row == 0 {
            cell.lblTitle.text = " + Add Participants"
        } else {
            cell.lblTitle.text = selectedUser[indexPath.row-1]["username"] as? String ?? ""
//            let idx:Int = indexPath.row
//            let dictTable:NSDictionary = self.directionDetail[idx] as! NSDictionary
//            cell.directionDetail.text =  dictTable["instructions"] as? String
//            let distance = dictTable["distance"] as! NSString
//            let duration = dictTable["duration"] as! NSString
//            let detail = "Distance : \(distance) Duration : \(duration)"
//            cell.directionDescription.text = detail
//            cell.selectionStyle = UITableViewCellSelectionStyle.None
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        print(" indexpath - ",indexPath)
        if indexPath.row == 0 {
            print("Add new participants")
            
            filteredUser = Users
            //Remove already added user
            
            let searchController = UISearchController(searchResultsController: searchResultController)
            searchController.searchBar.delegate = self
            searchController.delegate = searchResultController
            searchResultController.searchResults = filteredUser
            self.presentViewController(searchController, animated: true, completion: nil)
            
        } else {
            
        }
    }
    
}
