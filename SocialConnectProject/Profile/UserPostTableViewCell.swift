//
//  UserPostTableViewCell.swift
//  SocialConnectProject
//
//  Created by user259543 on 12/2/24.
//

import UIKit

class UserPostTableViewCell: UITableViewCell {

    @IBOutlet weak var userProfileImage: UIImageView!
    
    @IBOutlet weak var userFullName: UILabel!
    
    @IBOutlet weak var userUsername: UILabel!
    
    @IBOutlet weak var userPostImage: UIImageView!
    
    @IBOutlet weak var userPostCaption: UILabel!
    // userProfileImage userFullName userUsername userPostImage userPostCaption
    @IBOutlet weak var userPostLikeButton: UIButton!
    @IBOutlet weak var userPostCommentButton: UIButton!
    
    @IBOutlet weak var userPostEditPostButton: UIButton!
    
    
    @IBOutlet weak var userPostDeletePostButton: UIButton!
    
    weak var delegate: UserPostCellDelegate?
    
    protocol UserPostCellDelegate: AnyObject {
        func didTapLikeButton(in cell: UserPostTableViewCell)
        func didTapCommentButton(in cell: UserPostTableViewCell)
        func didTapEditButton(in cell: UserPostTableViewCell)
        func didTapDeleteButton(in cell: UserPostTableViewCell)
    }
    
    override func awakeFromNib() {
         super.awakeFromNib()
         
         // Assign actions to the buttons
         userPostLikeButton.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
         userPostCommentButton.addTarget(self, action: #selector(commentButtonTapped), for: .touchUpInside)
         userPostEditPostButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
         userPostDeletePostButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
     }
    
    // Button actions
       @objc func likeButtonTapped() {
           delegate?.didTapLikeButton(in: self)
       }
       
       @objc func commentButtonTapped() {
           delegate?.didTapCommentButton(in: self)
       }
       
       @objc func editButtonTapped() {
           delegate?.didTapEditButton(in: self)
       }
       
       @objc func deleteButtonTapped() {
           delegate?.didTapDeleteButton(in: self)
       }
    
}
