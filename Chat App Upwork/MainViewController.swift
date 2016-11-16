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
    
    var ref:FIRDatabaseReference!
    var user: FIRUser!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.tblGroupList.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cellIdentifier")
        
        ref = FIRDatabase.database().reference()
        let userID = FIRAuth.auth()?.currentUser?.uid
        
        ref.child("users").child(userID!).observeEventType(FIRDataEventType.Value, withBlock: { snapshot in
            if let user = snapshot.value!["username"] {
                self.username.text = "Hi \((user as! String))"
            }
        })
        
        getGroups()
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
        }))
        let next = self.storyboard?.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController!
        self.navigationController?.pushViewController(next, animated: true)
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
                
                myGroups.append(placeDict)
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
    
    // MARK: - Delegates & DataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myGroups.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("cellIdentifier", forIndexPath: indexPath)  as! UITableViewCell
        
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
        chatVc.city = myGroups[indexPath.row]["key"] as? String ?? ""
        chatVc.senderId = FIRAuth.auth()?.currentUser?.uid
        chatVc.senderDisplayName = "User"
        self.navigationController?.pushViewController(chatVc, animated: true)
    }
    
//    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
//        tableView.deselectRowAtIndexPath(indexPath, animated: true)
//        print("TableView view selected index path \(indexPath)")
//    }
}
