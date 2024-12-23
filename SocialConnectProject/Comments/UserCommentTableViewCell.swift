//
//  UserCommentTableViewCell.swift
//  SocialConnectProject
//
//  Created by user259543 on 12/12/24.
//

import UIKit

class UserCommentTableViewCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var userFullnameButton: UIButton!
    
    
    
    @IBOutlet weak var userComment: UILabel!
    
    weak var delegate: UserCommentCellDelegate?
    //UserCommentTableViewCell.UserCommentCellDelegate
    protocol UserCommentCellDelegate: AnyObject {
        func didTapFullNameButton(in cell: UserCommentTableViewCell)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Ensure wrapping happens
        
        // Allow the button's width to adjust based on content
            userFullnameButton.titleLabel?.numberOfLines = 0  // Allow multiple lines if necessary
            userFullnameButton.titleLabel?.lineBreakMode = .byWordWrapping  // Wrap text when needed

            // Adjust content hugging and compression resistance priorities
            userFullnameButton.setContentHuggingPriority(.required, for: .horizontal)  // Make sure the button prefers to expand
            userFullnameButton.setContentCompressionResistancePriority(.required, for: .horizontal)  // Prevent button from shrinking
            
        // Add a target action for the button tap
        userFullnameButton.addTarget(self, action: #selector(fullNameButtonTapped), for: .touchUpInside)
    }
    
    @objc private func fullNameButtonTapped() {
           
        delegate?.didTapFullNameButton(in: self)
        
        }
    
}
