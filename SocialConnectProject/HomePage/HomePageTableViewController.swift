import UIKit
import Firebase
import FirebaseAuth

class HomePageTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, HomePageTableViewCell.HomePageCellDelegate {
    
    
    
    
    
    

    var posts = [Post]()  // Array to hold posts
    var currentUser: User!
    var repository: Repositories! = Repositories()
    var postRepository = PostRepository()
    var userAuthId: String!
    var listUser = [String: User]() // Cache user data by userId
    var userPost: User!
    @IBOutlet weak var tableView: UITableView! // Connected via IBOutlet

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up the tableView
        tableView.dataSource = self
        tableView.delegate = self

        
        // Set dynamic row height
                tableView.rowHeight = UITableView.automaticDimension
                tableView.estimatedRowHeight = 100  // Adjust estimated row height based on expected content size

        // Fetch user data asynchronously
        fetchUserData()
        
        // Fetch all posts
        postRepository.getAllPosts(from: "Posts") { posts in
            self.posts = posts

          
            self.FetchAllUser()

            DispatchQueue.main.async {
                self.tableView.reloadData() // Reload data after fetching posts
            }
        }
    }

    // MARK: - TableView DataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 // One section
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! HomePageTableViewCell
        let post = posts[indexPath.row]
        
        // Set post content
        cell.postContent.text = post.content

        // Fetch the user for this post using the userId from the dictionary
            if let postUser = listUser[post.userId] {
                // Successfully retrieved the user for this post
                cell.userFullname.text = "\(postUser.firstname) \(postUser.lastname)"
                cell.userUsername.text = "@\(postUser.username)"
                
                // Load user image
                if let photoURL = URL(string: postUser.photo), !postUser.photo.isEmpty {
                    cell.userImage.loadCircularImageFromFileURL(fileURL: photoURL)
                } else {
                    cell.userImage.setPlaceholderImage(for: postUser.username)
                }
            } else {
                // Handle case where user is not found in the dictionary
                cell.userFullname.text = "Unknown User"
                cell.userUsername.text = "Anonymous"
                cell.userImage.setPlaceholderImage(for: "default")
            }
            

        // Check and load post image
        if post.imageURL.isEmpty {
            cell.postImage.setPlaceholderImage(for: "default")
        } else {
            // Assuming 'post.imageURL' is a valid URL string
            if let imageURL = URL(string: post.imageURL) {
                cell.postImage.loadImageFromFileURL(fileURL: imageURL)
            }
        }

        cell.delegate = self // Assign the delegate
        return cell
    }

    // MARK: - Cell Configuration

    
    // MARK: - Table View Delegate Methods

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Get the selected post
        let selectedPost = posts[indexPath.row]
        
        // Find the user associated with the post
        guard let postUser = listUser[selectedPost.userId] else {
            self.showAlertMessage("Error", "User data not found for the selected post.")
            return
        }
        
        
        if postUser.userAuthId == currentUser.userAuthId {
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
                otherUserVC.userFromHomePage = postUser
                otherUserVC.currentUser = self.currentUser
                self.navigationController?.pushViewController(otherUserVC, animated: true)
            } else {
                self.showAlertMessage("Error", "Could not instantiate OtherUserViewController")
            }
        }
        
        
    }


    
    
    
    
    
    func FetchAllUser() {
        repository.getAllUser("User") { userList in
            DispatchQueue.main.async {
                // Convert the userList array into a dictionary
                self.listUser = Dictionary(uniqueKeysWithValues: userList.map { ($0.userAuthId, $0) })
                self.tableView.reloadData()
                // If needed, you can check if the list is empty:
                if self.listUser.isEmpty {
                    self.showAlertMessage("Error", "No users found.")
                }
            }
        }
    }


    

    // MARK: - Button Actions
    func didTapLikeButton(in cell: HomePageTableViewCell) {
        
    }
    
    func didTapCommentButton(in cell: HomePageTableViewCell) {
        // Get the index path of the cell
            guard let indexPath = tableView.indexPath(for: cell) else { return }

            // Get the post associated with the cell
            let post = posts[indexPath.row]

        let CommentVC = self.storyboard?.instantiateViewController(withIdentifier: "CommentsViewController") as! CommentViewController
        CommentVC.postFromUserPage = post;
        CommentVC.userFromUserPage = self.currentUser
       
        self.navigationController?.pushViewController(CommentVC, animated: true)
        
    }

    // MARK: - Fetch User Data

    func fetchUserData() {
        repository.getUserData { user in
            DispatchQueue.main.async {
                if let user = user {
                    self.currentUser = user
                    self.userAuthId = user.userAuthId
                } else {
                    self.showAlertMessage("Error", "User data could not be fetched.")
                }
            }
        }
    }

    // MARK: - Load Users for Posts

    

    // MARK: - Prepare for Segue
//userProfilePost
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createPostSegue" {
            if let destinationVC = segue.destination as? CreatePostTableViewController {
                destinationVC.userFromHomePage = self.currentUser
            }
        }
        if segue.identifier == "userProfilePost" {
            if let destinationVC = segue.destination as? UserProfileViewController {
                destinationVC.userFromHomePage = self.currentUser
              
            }
        }
        //commentsSegue
        
           
    }
    
    @IBAction func unwindToHomeVC(_ unwindSegue: UIStoryboardSegue) {
        let sourceViewController = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
    }
}
