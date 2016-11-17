//
//  FriendRequestTableViewCell.swift
//  Connect App
//
//  Created by devel on 7/6/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit

class FriendRequestTableViewCell: UITableViewCell {

    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    var onAcceptButtonTapped : (() -> Void)? = nil
    var onDeclineButtonTapped : (() -> Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func acceptBtnTapped(sender: UIButton) {
        if let onAcceptButtonTapped = self.onAcceptButtonTapped {
            onAcceptButtonTapped()
        }
    }
    
    @IBAction func declineBtnTapped(sender: UIButton) {
        if let onDeclineButtonTapped = self.onDeclineButtonTapped {
            onDeclineButtonTapped()
        }
    }

}
