//
//  GroupViewController.swift
//  Chat App Upwork
//
//  Created by Dustin Allen on 10/28/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit
import Firebase

class GroupViewController: UIViewController {
    
    @IBOutlet var groupField: UITextField!
    
    var ref:FIRDatabaseReference!
    var user: FIRUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func createGroup(sender: AnyObject) {
        
        ref = FIRDatabase.database().reference()
        let userID = FIRAuth.auth()?.currentUser?.uid
        
        let group = groupField.text! as String
        
        ref.child("groups").child(group).updateChildValues(["groupName": groupField.text! as String, "creator": userID!])
        
            let next = self.storyboard?.instantiateViewControllerWithIdentifier("MainViewController") as! MainViewController!
        self.navigationController?.pushViewController(next, animated: true)
    }
}
