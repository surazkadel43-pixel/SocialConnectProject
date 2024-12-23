import UIKit

class HomePageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var postContent: UILabel!
    @IBOutlet weak var userUsername: UILabel!
    @IBOutlet weak var userFullname: UILabel!
    @IBOutlet weak var userImage: UIImageView!
   
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    
    // Delegate defined inside the class
    weak var delegate: HomePageCellDelegate?
    
    // Protocol inside the class
    protocol HomePageCellDelegate: AnyObject {
        func didTapLikeButton(in cell: HomePageTableViewCell)
        func didTapCommentButton(in cell: HomePageTableViewCell)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Allow the caption to expand based on the content length
        postContent.numberOfLines = 0  // This allows the label to grow as needed
        
        // Assign actions to the buttons
        likeButton.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
        commentButton.addTarget(self, action: #selector(commentButtonTapped), for: .touchUpInside)
    }
    
    // Button actions
    @objc func likeButtonTapped() {
        delegate?.didTapLikeButton(in: self)
    }
    
    @objc func commentButtonTapped() {
        delegate?.didTapCommentButton(in: self)
    }
}
