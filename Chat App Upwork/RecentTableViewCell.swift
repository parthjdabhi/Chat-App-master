//
//  RecentTableViewCell.swift
//  PokeTrainerApp
//
//  Created by iParth on 7/31/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class RecentTableViewCell: UITableViewCell {
    
    @IBOutlet var lblName: UILabel?
    @IBOutlet var imgUser: UIImageView?
    @IBOutlet var lblLastMsg: UILabel?
    @IBOutlet var lblCount: UILabel?
    @IBOutlet var lblElapsed: UILabel?
    
    var FirRef:FIRDatabaseReference?
    var UserID:String?
    let MyUserID = FIRAuth.auth()?.currentUser?.uid
    var UserDetail:NSDictionary?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
