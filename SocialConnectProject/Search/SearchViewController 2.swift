import UIKit

class SearchViewController2: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    
    @IBOutlet weak var searchText: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    var listUser = [String: User]() // Cache user data by userId

    var filteredUsers = [User]() // To hold filtered users for search functionality
        
    var repository: Repositories! = Repositories()
    var postRepository = PostRepository()
    var selectedPost: Post?
    var currentUser: User!
    var selectedUser: User!
    var FollowersOrFollowingorFriends: String!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableView.dataSource = self
        tableView.delegate = self
        
        FetchCurrentUser()
        FetchSelectedUser()
        FetchAllUser()
        
       
        // Set the search bar delegate
        searchText.delegate = self
        
        
    }

    // MARK: - Number Of Section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 // One section
    }
    // MARK: - Table View Data Source Methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUsers.count // Return the number of items in the data array
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue or create a new cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchUserCell", for: indexPath) as! SearchTableViewCell
        
    

        // Get the user to be displayed
        let user = filteredUsers[indexPath.row]
        // Set the user's full name
        cell.userFullName.text = "\(user.firstname) \(user.lastname)"
        cell.userUserName.text = "@\(user.username)"

        // Load the user's image if available, or set a placeholder
        if let photoURL = URL(string: user.photo), !user.photo.isEmpty {
            cell.userImage.loadCircularImageFromFileURL(fileURL: photoURL)
        } else {
            cell.userImage.setPlaceholderImage(for: user.username)
        }
        
        return cell
    }
    
    // MARK: - Table View Delegate Methods

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedUser = filteredUsers[indexPath.row] // Ensure filteredUsers contains user data
        print("Selected item: \(selectedUser.username)")
        
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
                //self.navigationController?.popViewController(animated: true)
                self.navigationController?.pushViewController(otherUserVC, animated: true)
            } else {
                self.showAlertMessage("Error", "Could not instantiate OtherUserViewController")
            }
        }
    }

    
    // MARK: - Search Functionality

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Filter users by full name and username based on search input
        if searchText.isEmpty {
            // If search text is empty, show all users
            filteredUsers = Array(listUser.values)
        } else {
            // Filter users based on both full name and username
            filteredUsers = Array(listUser.values).filter {
                let fullName = "\($0.firstname) \($0.lastname)".lowercased()
                let username = $0.username.lowercased()
                return fullName.contains(searchText.lowercased()) || username.contains(searchText.lowercased())
            }
        }
        
        // Reload the table view to reflect the filtered results
        tableView.reloadData()
    }
    
    func FetchAllUser() {
        if FollowersOrFollowingorFriends == "Followers" {
            // Fetch followers
            repository.getAllFollowersUsers(selectedUser.userAuthId) { followers in
                DispatchQueue.main.async {
                    // Loop through followers and ensure no duplicate keys in the dictionary
                    for user in followers {
                        self.listUser[user.userAuthId] = user // This will replace the user if the key already exists
                    }
                    self.filteredUsers = Array(self.listUser.values) // Initialize filtered users with all followers
                    self.tableView.reloadData()
                    
                    // Handle empty list case
                    if self.listUser.isEmpty {
                        self.showAlertMessage("Error", "No followers found.")
                    }
                }
            }
        } else if FollowersOrFollowingorFriends == "Following" {
            // Fetch following users
            repository.getAllFollowingUsers(selectedUser.userAuthId) { following in
                DispatchQueue.main.async {
                    // Loop through following and ensure no duplicate keys in the dictionary
                    for user in following {
                        self.listUser[user.userAuthId] = user // This will replace the user if the key already exists
                    }
                    self.filteredUsers = Array(self.listUser.values) // Initialize filtered users with all following users
                    self.tableView.reloadData()
                    
                    // Handle empty list case
                    if self.listUser.isEmpty {
                        self.showAlertMessage("Error", "No following found.")
                    }
                }
            }
        }
    }


    func FetchSelectedUser(){
        repository.getUserData(userId: selectedUser.userAuthId) { selectedUser in
            if let user = selectedUser {
                self.selectedUser = user
                
            }
        }
    }
    
    func FetchCurrentUser(){
        repository.getUserData { currentUser in
            if let user = currentUser {
                self.currentUser = user
            }
        }
    }
    
  
}
