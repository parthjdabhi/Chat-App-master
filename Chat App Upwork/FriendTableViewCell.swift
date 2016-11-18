//
//  FriendTableViewCell.swift
//  Chat App Upwork
//
//  Created by iParth on 11/16/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit

class FriendTableViewCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    
    var onDeleteButtonTapped : (() -> Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func deleteBtnTapped(sender: UIButton) {
        if let onDeleteButtonTapped = self.onDeleteButtonTapped {
            onDeleteButtonTapped()
        }
    }

}
