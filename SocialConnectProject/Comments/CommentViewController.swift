//
//  CommentViewController.swift
//  SocialConnectProject
//
//  Created by user259543 on 12/12/24.
//

import UIKit
import FirebaseCore

class CommentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UserCommentTableViewCell.UserCommentCellDelegate {
    
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userEnteredComment: UITextField!
    var postReposotory = PostRepository()
    var usersReposotory = Repositories()
    var postFromUserPage: Post!
    var userFromUserPage: User!
    var currentUser: User!
    var commentPerUser: Comment!
    
    // Example dynamic data for the table view
    var comments = [Comment]()
    var listUser = [String: User]() // Cache user data by userId

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set table view delegate and data source
        tableView.delegate = self
        tableView.dataSource = self
        
        
        

        fetchUserData()
        // Fetch all the comments
        fetchCommentsForPost()
        
        
    }

    // MARK: - Fetch Comments
    func fetchCommentsForPost() {
        // Fetch all comments for the current post
        guard let postId = postFromUserPage?.postId else { return }
        
        postReposotory.getAllCommentsForPost(postId: postId) { comments in
            if let comments = comments {
                self.comments = comments
                
                // Fetch user data only for the users in the comments
                self.fetchUsersForComments(comments: comments)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData() // Reload table view with new data
                }
            }
        }
    }
    
    // MARK: - Fetch Current User Data
    func fetchUserData() {
        usersReposotory.getUserData { user in
            DispatchQueue.main.async {
                if let user = user {
                    self.currentUser = user
                    
                } else {
                    self.showAlertMessage("Error", "User data could not be fetched.")
                }
            }
        }
    }

    // MARK: - Fetch Users for Comments
    func fetchUsersForComments(comments: [Comment]) {
        // Get unique user IDs from comments
        let userIds = Set(comments.map { $0.commentBy })
        
        for userId in userIds {
            // Skip fetching if user is already cached
            if listUser[userId] != nil {
                continue
            }
            
            usersReposotory.getUserData(userId: userId) { user in
                guard let user = user else {
                    print("Error: User data not found for userId \(userId)")
                    return
                }
                
                // Cache the user data
                self.listUser[userId] = user
                
                DispatchQueue.main.async {
                    self.tableView.reloadData() // Reload table view to update UI
                }
            }
        }
    }

    // MARK: - Table View Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count // Return the number of comments
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue the reusable cell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as? UserCommentTableViewCell else {
            return UITableViewCell()
        }

        
        
        // Configure the cell with comment data
        let commentUser = comments[indexPath.row] // Get the current comment
        cell.userComment.text = commentUser.commentText
        cell.userComment.numberOfLines = 0
  
        
        // Check if user data is cached
        if let cachedUser = listUser[commentUser.commentBy] {
            // Update the button's title with the full name of the user
                cell.userFullnameButton.setTitle("@\(cachedUser.firstname) \(cachedUser.lastname)", for: .normal)
            
            if let photoProfileURL = URL(string: cachedUser.photo), !cachedUser.photo.isEmpty {
                cell.userImage.loadCircularImageFromFileURL(fileURL: photoProfileURL)
            } else {
                cell.userImage.setPlaceholderImage(for: cachedUser.username)
            }
        } else {
            // Fetch user data asynchronously if not cached
            usersReposotory.getUserData(userId: commentUser.commentBy) { user in
                guard let user = user else {
                    print("Error: User data not found for userId \(commentUser.commentBy)")
                    return
                }
                
                // Cache the user data
                self.listUser[commentUser.commentBy] = user
                
                DispatchQueue.main.async {
                    // Update the cell's UI if still visible
                    if let currentIndexPath = tableView.indexPath(for: cell), currentIndexPath == indexPath {
                        cell.userFullnameButton.setTitle("@\(user.firstname) \(user.lastname)", for: .normal)
                        if let photoProfileURL = URL(string: user.photo), !user.photo.isEmpty {
                            cell.userImage.loadCircularImageFromFileURL(fileURL: photoProfileURL)
                        } else {
                            cell.userImage.setPlaceholderImage(for: user.username)
                        }
                    }
                }
            }
        }
        
        cell.delegate = self // Assign the delegate
        
        // Ensure layout updates
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        return cell
    }

    // MARK: - Button Actions
    @IBAction func postCommentButton(_ sender: Any) {
        // Guard to make sure postId and currentUser are available
        guard let postId = postFromUserPage?.postId else { return }
        guard let currentUser = self.currentUser else { return }
        
        // Validate that the user has entered a comment
        guard let userComment = userEnteredComment.text, !userComment.isEmpty else {
            showAlertMessage("Validation", "Please enter a valid comment.")
            return
        }
        
        // Create a new Comment object
        let newComment = Comment(
            commentId: "",
            commentBy: currentUser.userAuthId,
            commentText: userComment,
            createdAt: Timestamp(date: Date()),
            postId: postId  // Use the post's ID
        )
        
        // Call addCommentToPost to add the comment
        postReposotory.addCommentToPost(comment: newComment, postId: postId) { error, commentId in
            if let error = error {
                // Handle any error that occurs while adding the comment
                self.showAlertMessage("Error", "Failed to add comment: \(error.localizedDescription)")
            } else if let commentId = commentId {
                // Successfully added the comment, commentId will be returned
                print("Comment added successfully with ID: \(commentId)")
                
                // Optionally, reload your comments list or update UI
                self.userEnteredComment.text = ""  // Clear the input field
            }
        }
    }

    func didTapFullNameButton(in cell: UserCommentTableViewCell) {
        // Get the index path of the tapped cell
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        // Get the selected comment and its corresponding user data
        let commentUser = comments[indexPath.row]
        
        // Check if the user data is cached
        guard let selectedUser = listUser[commentUser.commentBy] else {
            print("Error: User data not available")
            return
        }
        
        print("Selected user: \(selectedUser.username)")
        if selectedUser.userAuthId == currentUser.userAuthId {
            // Navigate to the current user's profile
            if let userProfileVC = storyboard?.instantiateViewController(withIdentifier: "UserProfileViewController") as? UserProfileViewController {
                userProfileVC.userFromHomePage = currentUser
                self.navigationController?.pushViewController(userProfileVC, animated: true)
            } else {
                self.showAlertMessage("Error", "Could not instantiate UserProfileViewController")
            }
        } else {
            // Navigate to another user's profile
            if let otherUserVC = storyboard?.instantiateViewController(withIdentifier: "OtherUserViewController") as? OtherUserViewController {
                otherUserVC.userFromHomePage = selectedUser
                otherUserVC.currentUser = self.currentUser
                self.navigationController?.pushViewController(otherUserVC, animated: true)
            } else {
                self.showAlertMessage("Error", "Could not instantiate OtherUserViewController")
            }
        }
        
    }

   
}
