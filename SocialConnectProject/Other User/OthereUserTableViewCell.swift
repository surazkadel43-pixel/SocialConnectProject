//
//  OthereUserTableViewCell.swift
//  SocialConnectProject
//
//  Created by user259543 on 12/4/24.
//

import UIKit

class OthereUserTableViewCell: UITableViewCell {

    @IBOutlet weak var userProfileImage: UIImageView!
    
    @IBOutlet weak var userFullName: UILabel!
    
    @IBOutlet weak var userUsername: UILabel!
    
    @IBOutlet weak var userPostImage: UIImageView!
    
    @IBOutlet weak var userPostCaption: UILabel!
    // userProfileImage userFullName userUsername userPostImage userPostCaption
    @IBOutlet weak var userPostLikeButton: UIButton!
    @IBOutlet weak var userPostCommentButton: UIButton!
   
    
    weak var delegate: OthereUserCellDelegate? //OthereUserTableViewCell.OthereUserCellDelegate
    
    protocol OthereUserCellDelegate: AnyObject {
        func didTapLikeButton(in cell: OthereUserTableViewCell)
        func didTapCommentButton(in cell: OthereUserTableViewCell)
    
    }
    
    override func awakeFromNib() {
         super.awakeFromNib()
        // Ensure the caption label is allowed to expand
                userPostCaption.numberOfLines = 0 // Allow it to grow based on content
         // Assign actions to the buttons
         userPostLikeButton.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
         userPostCommentButton.addTarget(self, action: #selector(commentButtonTapped), for: .touchUpInside)
         
     }
    
    // Button actions
       @objc func likeButtonTapped() {
           delegate?.didTapLikeButton(in: self)
       }
       
       @objc func commentButtonTapped() {
           delegate?.didTapCommentButton(in: self)
       }
       
       
}
