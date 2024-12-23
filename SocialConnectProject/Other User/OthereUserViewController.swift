import UIKit

class OtherUserViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, OthereUserTableViewCell.OthereUserCellDelegate  {
    
    
   
    @IBOutlet weak var addFriendButton: UIButton!
    
    // Outlets for profile elements
        @IBOutlet weak var userImageProfile: UIImageView!
        @IBOutlet weak var userFullnameProfile: UILabel!
        @IBOutlet weak var userUsernameProfile: UILabel!
    
    
    @IBOutlet weak var tableView: UITableView!
    // Dynamic data source
    
    var repository = Repositories()
    var postRepository = PostRepository()
    var conversationRepository = ConversationRepository()
    var userFromHomePage: User! // otherUser
    var currentUser: User! // currentUser
    @IBOutlet weak var userFollowersCount: UILabel!
    @IBOutlet weak var userFollowingCount: UILabel!
    // Example data source for the table view
    var userPosts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        // Set dynamic row height
                tableView.rowHeight = UITableView.automaticDimension
                tableView.estimatedRowHeight = 100  // Adjust estimated row height based on expected content size
        // Fetch user data asynchronously
        FetchSelectedUser()
        
        fetchUserData()
        updateFollowButton()
        postRepository.getAllPostUser(forUser: userFromHomePage.userAuthId) { posts in
            // Handle the fetched posts
            self.userPosts = posts
            DispatchQueue.main.async {
                self.tableView.reloadData() // Reload data after fetching posts
            }
            
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 // One section
    }
    // MARK: - UITableViewDataSource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userPosts.count // Return the number of rows based on the data array
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OtherUserTableView", for: indexPath) as! OthereUserTableViewCell
        
        let post = userPosts[indexPath.row]
        // userProfileImage userFullName userUsername userPostImage userPostCaption
        cell.userPostCaption.text = post.content
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
        cell.delegate = self // Set the delegate
        
        
        
        
        
        return cell
    }
    
    // MARK: - UITableViewDelegate Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
       
    }
    
    func didTapLikeButton(in cell: OthereUserTableViewCell) {
        
    }
    
    func didTapCommentButton(in cell: OthereUserTableViewCell) {
        
        // Get the index path for the cell
        guard let indexPath = tableView.indexPath(for: cell) else { return }

                // Get the post associated with this cell
        let post = userPosts[indexPath.row]
        
        let CommentVC = self.storyboard?.instantiateViewController(withIdentifier: "CommentsViewController") as! CommentViewController
        CommentVC.postFromUserPage = post;
        CommentVC.userFromUserPage = self.userFromHomePage
       
        self.navigationController?.pushViewController(CommentVC, animated: true)
        
    }
    
    
    @IBAction func followersButton(_ sender: Any) {
        
        let destinationVC = self.storyboard?.instantiateViewController(withIdentifier: "FollowersandFollowingViewController") as! SearchViewController2
        destinationVC.FollowersOrFollowingorFriends = "Followers"
        destinationVC.selectedUser = self.userFromHomePage
        self.navigationController?.pushViewController(destinationVC, animated: true)
    }
    
    @IBAction func followingButton(_ sender: Any) {
        
        let destinationVC = self.storyboard?.instantiateViewController(withIdentifier: "FollowersandFollowingViewController") as! SearchViewController2
        destinationVC.FollowersOrFollowingorFriends = "Following"
        destinationVC.selectedUser = self.userFromHomePage
        self.navigationController?.pushViewController(destinationVC, animated: true)
    }
    
    func displayUserData(){
        
        userFullnameProfile.text = "\(userFromHomePage.firstname) \(userFromHomePage.lastname)"
        userUsernameProfile.text = "@\(userFromHomePage.username)"
        userFollowersCount.text = String(userFromHomePage.followersCount)
        userFollowingCount.text = String(userFromHomePage.followingCount)
        // Handle user image
            
                // Assuming 'user.photo' is a file path or URL
                if let photoURL = URL(string: userFromHomePage.photo), !userFromHomePage.photo.isEmpty {
                    userImageProfile.loadCircularImageFromFileURL(fileURL: photoURL)
                }
             else {
                userImageProfile.setPlaceholderImage(for: userFromHomePage.username)
            }
        
    }
    
    func fetchUserData() {
        repository.getUserData { user in
            DispatchQueue.main.async {
                if let user = user {
                    self.currentUser = user
                    
                } else {
                    self.showAlertMessage("Error", "User data could not be fetched.")
                }
            }
        }
    }
    
    @IBAction func addFriendButtonTapped(_ sender: Any) {
        // Disable the button to prevent multiple clicks during the operation
        addFriendButton.isEnabled = false
        
        // Ensure that currentUserAuthId and otherUserAuthId are not nil
        guard let currentUserAuthId = currentUser?.userAuthId else {
            print("Current user ID is nil")
            addFriendButton.isEnabled = true
            return
        }
        guard let otherUserAuthId = userFromHomePage?.userAuthId else {
            print("Other user ID is nil")
            addFriendButton.isEnabled = true
            return
        }
        
        // Get the current title of the button
        guard let buttonTitle = addFriendButton.title(for: .normal) else {
            print("Button title is nil")
            addFriendButton.isEnabled = true
            return
        }
        
        switch buttonTitle {
        case "Add Friend":
            // Add the other user to the "Following" collection of the current user
            repository.sendFollowRequest(currentUserAuthId: currentUserAuthId, otherUserAuthId: otherUserAuthId) { success in
                DispatchQueue.main.async {
                    if success {
                        self.addFriendButton.setTitle("Cancel Request", for: .normal)
                        self.addFriendButton.backgroundColor = UIColor.orange
                    } else {
                        print("Error in sending follow request")
                    }
                    self.addFriendButton.isEnabled = true
                }
            }
            
        case "Cancel Request":
            // Show confirmation alert before canceling the request
            showYesNoAlertMessage(
                title: "Cancel Follow Request",
                message: "Are you sure you want to cancel the follow request?",
                yesAction: {
                    self.repository.cancelFollow(currentUserAuthId: currentUserAuthId, otherUserAuthId: otherUserAuthId) { success in
                        DispatchQueue.main.async {
                            if success {
                                self.addFriendButton.setTitle("Add Friend", for: .normal)
                                self.addFriendButton.backgroundColor = UIColor.blue
                            } else {
                                print("Error in canceling follow request")
                            }
                            self.addFriendButton.isEnabled = true
                        }
                    }
                },
                noAction: {
                    self.addFriendButton.isEnabled = true
                }
            )
            
        case "Accept Request":
            // Add the other user to the "Following" collection and establish mutual friendship
            repository.acceptFollowRequest(currentUserAuthId: currentUserAuthId, otherUserAuthId: otherUserAuthId) { success in
                DispatchQueue.main.async {
                    if success {
                        self.addFriendButton.setTitle("Friends", for: .normal)
                        self.addFriendButton.backgroundColor = UIColor.green
                    } else {
                        print("Error in accepting follow request")
                    }
                    self.addFriendButton.isEnabled = true
                }
            }
            
        case "Friends":
            // Show confirmation alert before unfriending the user
            showYesNoAlertMessage(
                title: "Unfriend User",
                message: "Are you sure you want to remove this friend?",
                yesAction: {
                    self.repository.unfriendUser(currentUserAuthId: currentUserAuthId, otherUserAuthId: otherUserAuthId) { success in
                        DispatchQueue.main.async {
                            if success {
                                self.addFriendButton.setTitle("Add Friend", for: .normal)
                                self.addFriendButton.backgroundColor = .systemBlue
                            } else {
                                print("Error in unfriending user")
                            }
                            self.addFriendButton.isEnabled = true
                        }
                    }
                },
                noAction: {
                    self.addFriendButton.isEnabled = true
                }
            )
            
        default:
            print("Unknown button title: \(buttonTitle)")
            addFriendButton.isEnabled = true
        }
        self.tableView.reloadData()
    }


    func FetchSelectedUser(){
        repository.getUserData(userId: userFromHomePage.userAuthId) { selectedUser in
            if let user = selectedUser {
                self.userFromHomePage = user
                self.displayUserData()
                
            }
        }
    }



    
    func updateFollowButton() {
        guard let currentUserAuthId = currentUser?.userAuthId else {
            print("currentUser.userAuthId is nil")
            return
        }
        
        // Check if the current user is following the other user
        repository.checkIfFollowing(currentUserAuthId: currentUserAuthId, otherUserAuthId: userFromHomePage.userAuthId) { isFollowing in
            // Check if the other user is following the current user
            self.repository.checkIfFollowedBy(currentUserAuthId: currentUserAuthId, otherUserAuthId: self.userFromHomePage.userAuthId) { isFollowedBy in
                DispatchQueue.main.async {
                    if isFollowing && isFollowedBy {
                        // Both following and followed by -> "Friends"
                        self.addFriendButton.setTitle("Friends", for: .normal)
                        self.addFriendButton.backgroundColor = UIColor.green
                    } else if isFollowing {
                        // Only following -> "Cancel Request"
                        self.addFriendButton.setTitle("Cancel Request", for: .normal)
                        self.addFriendButton.backgroundColor = UIColor.orange
                    } else if isFollowedBy {
                        // Only followed by -> "Accept Request"
                        self.addFriendButton.setTitle("Accept Request", for: .normal)
                        self.addFriendButton.backgroundColor = UIColor.red
                    } else {
                        // Neither following nor followed by -> "Add Friend"
                        self.addFriendButton.setTitle("Add Friend", for: .normal)
                        self.addFriendButton.backgroundColor = .systemBlue
                    }
                    
                    // Reload the table view after updating the button
                    self.tableView.reloadData()
                }
            }
        }
    }




    
    @IBAction func messageButton(_ sender: Any) {
        // Get the current title of the addFriendButton
        guard let buttonTitle = addFriendButton.title(for: .normal) else {
            print("Button title is nil")
            return
        }
        
        // Only proceed if the title is "Friends"
        if buttonTitle == "Friends" {
            guard let currentUserAuthId = currentUser?.userAuthId,
                  let otherUserAuthId = userFromHomePage?.userAuthId else {
                print("User authentication IDs are missing.")
                return
            }
            
            // Check if a conversation already exists between the current user and the other user
            conversationRepository.checkIfConversationExists(currentUserAuthId: currentUserAuthId, otherUserAuthId: otherUserAuthId) { conversationExists, conversation in
                if conversationExists {
                    // If conversation exists, navigate to MessengerViewController
                    print("Conversation already exists with ID: \(conversation?.conversationId ?? "Unknown")")
                    
                    // Navigate to MessengerViewController after conversation is found
                    DispatchQueue.main.async {
                        let messageVC = self.storyboard?.instantiateViewController(withIdentifier: "MessangerViewController") as! MessangerViewController
                        messageVC.currentConversation = conversation
                        messageVC.currentUser = self.currentUser
                        messageVC.otherUser = self.userFromHomePage
                        self.navigationController?.pushViewController(messageVC, animated: true)
                    }
                } else {
                    // If no conversation exists, create a new conversation
                    self.conversationRepository.createConversation(currentUserAuthId: currentUserAuthId, otherUserAuthId: otherUserAuthId, lastMessage: "Hello") { success, conversation in
                        if success {
                            print("Conversation created successfully.")
                            
                            // Navigate to MessengerViewController after conversation is created
                            DispatchQueue.main.async {
                                let messageVC = self.storyboard?.instantiateViewController(withIdentifier: "MessangerViewController") as! MessangerViewController
                                messageVC.currentConversation = conversation
                                messageVC.currentUser = self.currentUser
                                messageVC.otherUser = self.userFromHomePage
                                self.navigationController?.pushViewController(messageVC, animated: true)
                            }
                        } else {
                            print("Failed to create conversation.")
                        }
                    }
                }
            }
        } else {
            self.showAlertMessage("Sorry!!", "The user is not a friend, so you cannot message.")
        }
    }



    
}
