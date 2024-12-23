//
//  MessangerTableViewCell.swift
//  SocialConnectProject
//
//  Created by user259543 on 12/17/24.
//

import UIKit

class MessangerTableViewCell: UITableViewCell {

    
    @IBOutlet weak var userSenderImage: UIImageView!
    
    @IBOutlet weak var messageContent: UILabel!
    
    @IBOutlet weak var statusAndtime: UILabel!
    
    override func awakeFromNib() {
            super.awakeFromNib()
            // Hide status and time by default
            statusAndtime.isHidden = true
        }

    func toggleStatusAndTimeVisibility() {
        UIView.animate(withDuration: 0.3) {
            self.statusAndtime.isHidden.toggle()
        }
    }

    

}
