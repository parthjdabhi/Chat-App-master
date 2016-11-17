//
//  ContactsTableViewCell.swift
//  Connect App
//
//  Created by super on 7/2/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit

class ContactsTableViewCell: UITableViewCell {

    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    
    var onAddButtonTapped : (() -> Void)? = nil
    
    
    @IBAction func addBtnTapped(sender: UIButton) {
        if let onAddButtonTapped = self.onAddButtonTapped {
            onAddButtonTapped()
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
