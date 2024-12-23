import UIKit

class UserProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UserPostTableViewCell.UserPostCellDelegate {
    
    // Outlets for profile elements
    @IBOutlet weak var userImageProfile: UIImageView!
    @IBOutlet weak var userFullnameProfile: UILabel!
    @IBOutlet weak var userUsernameProfile: UILabel!
    var repository = Repositories()
    var postRepository = PostRepository()
    
    // Outlet for the table view
    @IBOutlet weak var userPosttableView: UITableView!
    
    var userFromHomePage: User!
    var postForEdit: Post!
    
    @IBOutlet weak var userFollowingCount: UILabel!
    @IBOutlet weak var userFollowersCount: UILabel!
    // Example data source for the table view
    var userPosts = [Post]()
    var isSegueInProgress = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the data source and delegate
        userPosttableView.dataSource = self
        userPosttableView.delegate = self
        
        // Fetch user data asynchronously
        fetchUserData()
        
        postRepository.getAllPostUser(forUser: userFromHomePage.userAuthId) { posts in
            // Handle the fetched posts
            self.userPosts = posts
            DispatchQueue.main.async {
                self.userPosttableView.reloadData() // Reload data after fetching posts
            }
        }
    }

    func numberOfSections(in userPosttableView: UITableView) -> Int {
        return 1 // One section
    }

    // MARK: - UITableViewDataSource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userPosts.count  // Number of rows equals the number of user posts
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserPostCell", for: indexPath) as? UserPostTableViewCell else {
            return UITableViewCell()
        }
        
        let post = userPosts[indexPath.row]
        
        // Set the text for userPostCaption and allow it to expand
        cell.userPostCaption.text = post.content
        cell.userPostCaption.numberOfLines = 0 // Allow the label to expand based on content
        
        // Set other user and post data
        cell.userFullName.text = "\(userFromHomePage.firstname) \(userFromHomePage.lastname)"
        cell.userUsername.text = "@\(userFromHomePage.username)"
        
        // Load user image
        if let photoProfileURL = URL(string: userFromHomePage.photo), !userFromHomePage.photo.isEmpty {
            cell.userProfileImage.loadCircularImageFromFileURL(fileURL: photoProfileURL)
        } else {
            cell.userProfileImage.setPlaceholderImage(for: userFromHomePage.username)
        }
        
        // Check and load post image
        if post.imageURL.isEmpty {
            cell.userPostImage.setPlaceholderImage(for: "default")
        } else {
            // Assuming 'post.imageURL' is a valid URL string
            if let imageURL = URL(string: post.imageURL) {
                cell.userPostImage.loadImageFromFileURL(fileURL: imageURL)
            }
        }
        
        cell.delegate = self // Set the delegate for the buttons
        
        // Ensure layout updates
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        
        return cell
    }

    // MARK: - UITableViewDelegate Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - UserPostCellDelegate Methods
    func didTapLikeButton(in cell: UserPostTableViewCell) {
        if let indexPath = userPosttableView.indexPath(for: cell) {
            print("Like button tapped in row \(indexPath.row)")
            // Handle like action
        }
    }
    
    func didTapCommentButton(in cell: UserPostTableViewCell) {
        
        
        // Get the index path for the cell
    guard let indexPath = userPosttableView.indexPath(for: cell) else { return }

                // Get the post associated with this cell
        let post = userPosts[indexPath.row]
        
        let CommentVC = self.storyboard?.instantiateViewController(withIdentifier: "CommentsViewController") as! CommentViewController
        CommentVC.postFromUserPage = post;
        CommentVC.userFromUserPage = self.userFromHomePage
       
        self.navigationController?.pushViewController(CommentVC, animated: true)
        
    }
    
    func didTapEditButton(in cell: UserPostTableViewCell) {
        if isSegueInProgress { return } // Prevent multiple triggers
        isSegueInProgress = true
        
        if let indexPath = userPosttableView.indexPath(for: cell) {
            print("Edit button tapped in row \(indexPath.row)")
            
            // Set the postForEdit property
            self.postForEdit = userPosts[indexPath.row]
            
            // Trigger the segue after setting the value
            performSegue(withIdentifier: "editPostDetails", sender: self)
        }
        
        // Reset the flag after a delay to allow the segue to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isSegueInProgress = false
        }
    }
    
    func didTapDeleteButton(in cell: UserPostTableViewCell) {
        // Get the indexPath of the tapped cell
        if let indexPath = userPosttableView.indexPath(for: cell) {
            print("Delete button tapped in row \(indexPath.row)")
            
            // Get the post ID from the data source
            let postId = userPosts[indexPath.row].postId! // Assuming your posts array contains Post objects
            
            // Show the confirmation alert
            showYesNoAlertMessage(
                title: "Delete Post",
                message: "Are you sure you want to delete this post?",
                yesAction: { [weak self] in
                    guard let self = self else { return }
                    
                    // Call the deletePost function
                    self.postRepository.deletePost(with: postId) { errorMessage in
                        if errorMessage.isEmpty {
                            // On successful deletion, remove the post from the data source and update the UI
                            print("Post deleted successfully.")
                            self.userPosttableView.reloadData()
                        } else {
                            // Handle the error
                            self.showAlertMessage("Error", errorMessage)
                        }
                    }
                },
                noAction: {
                    print("User cancelled the deletion.")
                }
            )
        }
    }
    
    @IBAction func followingButton(_ sender: Any) {
        let destinationVC = self.storyboard?.instantiateViewController(withIdentifier: "FollowersandFollowingViewController") as! SearchViewController2
        destinationVC.FollowersOrFollowingorFriends = "Following"
        destinationVC.selectedUser = self.userFromHomePage
        self.navigationController?.pushViewController(destinationVC, animated: true)
    }
    
    @IBAction func followersButton(_ sender: Any) {
        let destinationVC = self.storyboard?.instantiateViewController(withIdentifier: "FollowersandFollowingViewController") as! SearchViewController2
        destinationVC.FollowersOrFollowingorFriends = "Followers"
        destinationVC.selectedUser = self.userFromHomePage
        self.navigationController?.pushViewController(destinationVC, animated: true)
    }
    func fetchUserData() {
        repository.getUserData { user in
            DispatchQueue.main.async {
                if let user = user {
                    self.userFromHomePage = user
                    self.displayUserData()
                } else {
                    self.showAlertMessage("Error", "User data could not be fetched.")
                }
            }
        }
    }

    func displayUserData() {
        userFullnameProfile.text = "\(userFromHomePage.firstname) \(userFromHomePage.lastname)"
        userUsernameProfile.text = "@\(userFromHomePage.username)"
        userFollowersCount.text = String(userFromHomePage.followersCount)
        userFollowingCount.text = String(userFromHomePage.followingCount)
        // Handle user image
        if let photoURL = URL(string: userFromHomePage.photo), !userFromHomePage.photo.isEmpty {
            userImageProfile.loadCircularImageFromFileURL(fileURL: photoURL)
        } else {
            userImageProfile.setPlaceholderImage(for: userFromHomePage.username)
        }
    }
    
    
    @IBAction func viewFriendsButton(_ sender: Any) {
    }
    
    @IBAction func viewMessageButton(_ sender: Any) {
    }
    @IBAction func unwindToUserProfileVC(_ unwindSegue: UIStoryboardSegue) {
        let sourceViewController = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editPostDetails" {
            guard let destinationVC = segue.destination as? EditPostTableViewController else { return }
            
            // Pass the necessary data
            destinationVC.userFromHomePage = self.userFromHomePage
            destinationVC.postFromHomePage = self.postForEdit
        }
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "editPostDetails" {
            // Only allow programmatic trigger
            return false
        }
        return true
    }
}
