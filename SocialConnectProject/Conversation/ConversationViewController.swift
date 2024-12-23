import UIKit
import FirebaseAuth
import FirebaseFirestore

class ConversationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var currentUser: User! // Ensure this is set during login or initialization
    var otherUserId: String!
    var otherUser: User!
    var conversations: [Conversation] = []  // All conversations
    var filteredConversations: [Conversation] = [] // Conversations filtered by search
    let conversationRepository = ConversationRepository() // Handles Firestore interactions
    var repository = Repositories()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the table view
        tableView.dataSource = self
        tableView.delegate = self
        
        // Set the delegate for the search bar
        searchBar.delegate = self
        
        // Fetch user data and conversations
                fetchUserData()
                // After fetching user data, start fetching conversations
                self.fetchConversations()
    }
    
    
    
    // MARK: - Fetch User Data
        
        func fetchUserData() {
            guard let userAuthId = Auth.auth().currentUser?.uid else {
                print("No user is currently logged in.")
                
                return
            }
            self.currentUser?.userAuthId = userAuthId
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
    
    func fetchConversations() {
       
        guard let currentUserAuthId = Auth.auth().currentUser?.uid else {
            print("No user is currently logged in.")
            
            return
        }
        
        // Add snapshot listener for real-time updates
        conversationRepository.getAllConversations(currentUserAuthId: currentUserAuthId) { fetchedConversations in
            DispatchQueue.main.async {
                // Set the conversations and filteredConversations properties
                
                        self.conversations = fetchedConversations
                        self.filteredConversations = fetchedConversations // Initialize filteredConversations
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                            
            }
        }
    }
    
    // MARK: - UITableView DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredConversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Conversation", for: indexPath) as? ConversationTableViewCell else {
            fatalError("Could not dequeue ConversationTableViewCell")
        }

        let conversation = filteredConversations[indexPath.row]

        // Extract other user's ID
        let currentUserAuthId = self.currentUser.userAuthId
        guard let otherUserId = conversation.participants.first(where: { $0 != currentUserAuthId }) else {
            print("Error: Failed to identify the other user in the conversation.")
            return cell
        }
        self.otherUserId = otherUserId
        
        // Fetch user data for the other participant asynchronously
        repository.getUserData(userId: otherUserId) { [weak tableView] user in
            guard let user = user else {
                print("Error: User data not found for userId \(otherUserId)")
                return
            }

            DispatchQueue.main.async {
                // Ensure the cell hasn't been reused for a different index path
                if let currentIndexPath = tableView?.indexPath(for: cell), currentIndexPath == indexPath {
                    cell.otherUserFullName.text = "@\(user.firstname) \(user.lastname)"
                    
                    if let photoProfileURL = URL(string: user.photo), !user.photo.isEmpty {
                        cell.otherUserImage.loadCircularImageFromFileURL(fileURL: photoProfileURL)
                    } else {
                        cell.otherUserImage.setPlaceholderImage(for: user.username)
                    }
                }
            }
        }

        // Set last message and timestamp
        cell.lastMessage.text = conversation.lastMessage

        // Format the last updated time
        if let lastUpdated = conversation.lastUpdated {
            cell.lastUpdatedTime.text = Date.formattedSocialDate(from: lastUpdated)
        } else {
            cell.lastUpdatedTime.text = "N/A"
        }

        return cell
    }

    // MARK: - UITableView Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedConversation = filteredConversations[indexPath.row]
        guard let otherUserId = selectedConversation.participants.first(where: { $0 != currentUser.userAuthId }) else {
            print("Error: Failed to identify the other user in the conversation.")
            return
        }
        
        repository.getUserData(userId: otherUserId) { selectedUser in
            if let user = selectedUser {
                self.otherUser = user
                // Navigate to MessengerViewController
                let messengerVC = self.storyboard?.instantiateViewController(withIdentifier: "MessangerViewController") as! MessangerViewController
                messengerVC.currentConversation = selectedConversation
                messengerVC.currentUser = self.currentUser
                messengerVC.otherUser = self.otherUser
                self.navigationController?.pushViewController(messengerVC, animated: true)
            } else {
                self.showAlertMessage("Error", "User data could not be fetched.")
            }
        }
    }
    
    // MARK: - SearchBar Delegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            // If the search text is empty, show all conversations
            filteredConversations = conversations
            tableView.reloadData()
        } else {
            // Filter the conversations based on full name
            var filteredResults: [Conversation] = []
            let group = DispatchGroup()  // Used to wait for all async calls to finish
            
            for conversation in conversations {
                guard let currentUserAuthId = self.currentUser?.userAuthId else { continue }
                
                if let otherUserId = conversation.participants.first(where: { $0 != currentUserAuthId }) {
                    group.enter() // Enter the dispatch group for each conversation
                    
                    // Fetch user data to get the full name
                    repository.getUserData(userId: otherUserId) { user in
                        if let user = user {
                            // Check if the full name matches the search text (case-insensitive)
                            if user.firstname.lowercased().contains(searchText.lowercased()) ||
                                user.lastname.lowercased().contains(searchText.lowercased()) {
                                filteredResults.append(conversation)
                            }
                        }
                        group.leave() // Leave the dispatch group when done
                    }
                }
            }
            
            // Once all async calls are done, update the table view
            group.notify(queue: .main) {
                self.filteredConversations = filteredResults
                self.tableView.reloadData()
            }
        }
    }
}
