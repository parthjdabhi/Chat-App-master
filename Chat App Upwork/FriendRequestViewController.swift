//
//  FriendRequestViewController.swift
//  Chat App Upwork
//
//  Created by Dustin Allen on 11/10/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class FriendReqViewController: UIViewController,FriendReqTableViewCellDelegate {

    @IBOutlet var tblFriendReq: UITableView!
    
    // MARK: Properties
    
    var ref:FIRDatabaseReference!
    var FriendReqReference:NSDictionary!
    var FriendReqSnapshot:FIRDataSnapshot!
    var arrFriendReq = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        ref = FIRDatabase.database().reference()
        self.getFriendRequests()
        
    }
    
    override func  preferredStatusBarStyle()-> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getFriendRequests() {
        
        CommonUtils.sharedUtils.showProgress(self.view, label: "Fetching Friend Request...")
        let userID = FIRAuth.auth()?.currentUser?.uid
        
        //observeSingleEventOfType
        ref.child("users").child(userID!).child("userInfo").child("friendRequest").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            
            if let FriendReqRef = snapshot.valueInExportFormat() as? NSDictionary {
                self.FriendReqReference = FriendReqRef
                self.arrFriendReq =   NSMutableArray(array: self.FriendReqReference.allValues)
            } else {
                self.FriendReqReference = nil
                self.arrFriendReq = []
            }

            self.tblFriendReq.reloadData()
            CommonUtils.sharedUtils.hideProgress()
            
        }) { (error) in
            
            CommonUtils.sharedUtils.hideProgress()
            CommonUtils.sharedUtils.showAlert(self, title: "Oops!", message: error.localizedDescription)
        }

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
    
    
    // MARK: - Delegates
    // MARK: -  UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let allFriendReqReference = self.FriendReqReference?.allKeys.count ?? 0
        if arrFriendReq.count == 0 {
            let emptyLabel = UILabel(frame: tableView.frame)
            emptyLabel.text = "Currently you not have any pending requests!"
            emptyLabel.textColor = UIColor.darkGrayColor();
            emptyLabel.textAlignment = .Center;
            emptyLabel.numberOfLines = 3
            
            tableView.backgroundView = emptyLabel
            tableView.separatorStyle = UITableViewCellSeparatorStyle.None
            return 0
        } else {
            tableView.backgroundView = nil
            return arrFriendReq.count
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:FriendReqTableViewCell = tableView.dequeueReusableCellWithIdentifier("FriendReqTableViewCell", forIndexPath: indexPath) as! FriendReqTableViewCell
        
        //let userID = self.FriendReqReference["\(indexPath.row)"] as? String ?? ""
        let userID = arrFriendReq[indexPath.row] as! String

        cell.delegate = self
        cell.index = indexPath.row
        
        cell.SetupData(ref, UserID: userID)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func onAcceptOrRejectRequest(index: Int) {
        self.arrFriendReq.removeObjectAtIndex(index)
        self.tblFriendReq.reloadData()
    }
    
    
}
