import UIKit
import FirebaseCore

class MessangerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var fileAttachmentButton: UIButton!
    @IBOutlet weak var messageText: UITextField!
    @IBOutlet weak var messageSentButton: UIButton!
    @IBOutlet weak var MessageBarButton: UIBarButtonItem!
    @IBOutlet weak var deleteConversationButton: UICommand!

    var currentUser: User!
    var otherUser: User!
    var currentConversation: Conversation!
    var messages: [Message] = []  // Simple array to hold all messages

    var repository = Repositories()
    var postRepository = PostRepository()
    var conversationRepository = ConversationRepository()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the table view's data source and delegate
        tableview.dataSource = self
        tableview.delegate = self

        // Fetch user details and messages
        FetchCurrentuser()
        FetchOtherUser()
        fetchMessages()
    }
    
    // MARK: - Fetch otherUser Details
    func FetchOtherUser() {
        guard let userId = otherUser?.userAuthId else { return }
        repository.getUserData(userId: userId) { selectedUser in
            if let user = selectedUser {
                self.otherUser = user
                // Optionally reload data if necessary
            } else {
                self.showAlertMessage("Error", "User data could not be fetched.")
            }
        }
    }
    
    // MARK: - Fetch Current User Details
    func FetchCurrentuser() {
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
    
    // MARK: - Fetch Messages
    func fetchMessages() {
        guard let conversationId = currentConversation?.conversationId else { return }
        
        conversationRepository.fetchMessages(for: conversationId) { [weak self] messages, error in
            if let error = error {
                print("Error fetching messages: \(error)")
                return
            }

            // Combine all messages into a single array
            self?.messages = messages ?? []

            // Reload the table view to display the messages
            DispatchQueue.main.async {
                self?.tableview.reloadData()
            }
        }
    }

    // MARK: - UITableViewDataSource

    // Return the number of rows based on the messages array
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    // Configure the cell with the message data
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Messanger", for: indexPath) as! MessangerTableViewCell
        
        // Get the message for the current indexPath
        let message = messages[indexPath.row]

        // Configure the cell with the message data
        cell.messageContent.text = message.content  // Set the message content in the label
        cell.messageContent.numberOfLines = 0
        
        // Set the sender image based on the sender of the message
        if message.senderId == currentUser.userAuthId {
            if let photoProfileURL = URL(string: currentUser.photo), !currentUser.photo.isEmpty {
                cell.userSenderImage.loadCircularImageFromFileURL(fileURL: photoProfileURL)
            } else {
                // Ensure currentUser has a username to fallback to
                cell.userSenderImage.setPlaceholderImage(for: currentUser.username)
            }
        } else {
            // Safely handle the case where otherUser might be nil
            if let otherUser = otherUser, let photoProfileURL = URL(string: otherUser.photo), !otherUser.photo.isEmpty {
                cell.userSenderImage.loadCircularImageFromFileURL(fileURL: photoProfileURL)
            } else {
                // If otherUser is nil or photo is empty, use placeholder
                cell.userSenderImage.setPlaceholderImage(for: otherUser?.username ?? "Unknown User")
            }
        }

        
        // Set the status and time
        let formattedDate = Date.formattedSocialDate(from: message.sendTime) // Use your custom formattedSocialDate method
        let statusAndTimeText = "\(message.status) - \(formattedDate)"
        cell.statusAndtime.text = statusAndTimeText  // Format the sendTime into a readable string

        // Ensure layout updates
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        
        return cell
    }

    // MARK: - UITableViewDelegate (Optional)

    // Handle row selection if needed
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Deselect the row
            tableView.deselectRow(at: indexPath, animated: true)

            // Get the cell for the selected row
            if let cell = tableView.cellForRow(at: indexPath) as? MessangerTableViewCell {
                // Toggle the visibility of status and time
                cell.toggleStatusAndTimeVisibility()
            }
    }

    // MARK: - Button Actions

    @IBAction func messageSentButton(_ sender: Any) {
        // Check if the message text is not empty
        guard let messageContent = messageText.text, !messageContent.isEmpty else {
            showAlertMessage("Error", "Message cannot be empty.")
            return
        }
        
        // Create a new Message object
        let message = Message(
            content: messageContent,
            sendTime: Timestamp(date: Date()),
            senderId: currentUser.userAuthId,  // Assuming currentUser has a userAuthId
            status: "sent",  // Set appropriate status
            type: "Text"  // Assuming text message type, you can modify for media type
        )
        
        // Add the message to the conversation
        guard let conversationId = currentConversation?.conversationId else {
            showAlertMessage("Error", "Conversation ID is missing.")
            return
        }

        conversationRepository.addMessage(to: conversationId, message: message) { success, message in
            if success {
                DispatchQueue.main.async {
                    self.messageText.text = ""  // Clear the message input field
                    self.fetchMessages()  // Reload messages after sending
                }
            } else {
                // Handle failure (show an alert or log the error)
                self.showAlertMessage("Error", message)
            }
        }
    }

    @IBAction func fileAttachmentButton(_ sender: Any) {
        // Handle file attachment action
        // Logic to handle file attachment (e.g., opening the file picker)
    }

    @IBAction func deleteConversationButton(_ sender: Any) {
        // Handle conversation deletion
        // Logic to delete conversation
    }
    lazy var onComplete: () -> Void = { [weak self] in
        guard let self = self else { return }
        
        
            
            self.navigationController?.popViewController(animated: true)
        
    }

    @IBAction func buttonSelection(_ sender: UIAction){
        print("delete conversation")
        guard let conversationId = currentConversation?.conversationId else {
               showAlertMessage("Error", "Conversation ID is missing.")
               return
           }
           
           // Show Yes/No alert
           showYesNoAlertMessage(
               title: "Confirm Deletion",
               message: "Are you sure you want to delete this conversation?",
               yesAction: { [weak self] in
                   self?.conversationRepository.deleteConversation(with: conversationId) { success, message in
                       DispatchQueue.main.async {
                           if success {
                               self?.showAlertMessage("Success", "Conversation deleted successfully.", self?.onComplete)
                               
                           } else {
                               self?.showAlertMessage("Error", message ?? "Unknown error occurred while deleting the conversation.")
                           }
                       }
                   }
               },
               noAction: {
                   // Optional: Handle "No" action here if needed
                   print("User canceled deletion.")
               }
           )
    }
}
