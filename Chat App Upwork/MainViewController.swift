//
//  MainViewController.swift
//  Chat App Upwork
//
//  Created by Dustin Allen on 10/27/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit
import Firebase

class MainViewController: UIViewController {
    
    @IBOutlet var username: UILabel!
    
    var ref:FIRDatabaseReference!
    var user: FIRUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        let userID = FIRAuth.auth()?.currentUser?.uid
        
        ref.child("users").child(userID!).observeEventType(FIRDataEventType.Value, withBlock: { snapshot in
            if let user = snapshot.value!["username"] {
                self.username.text = "Hi \((user as! String))"
            }
        })
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
    
}
