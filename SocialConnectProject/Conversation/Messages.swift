import Foundation
import FirebaseFirestore

class Message {
    var content: String
    var mediaURL: String?
    var messageId: String
    var sendTime: Timestamp!
    var senderId: String
    var status: String
    var type: String

    // Primary initializer
    init(content: String, mediaURL: String?, messageId: String, sendTime: Timestamp? = nil, senderId: String, status: String, type: String) {
        self.content = content
        self.mediaURL = mediaURL
        self.messageId = messageId
        self.sendTime = sendTime ?? Timestamp(date: Date())
        self.senderId = senderId
        self.status = status
        self.type = type
    }

    // Secondary initializer
    init(content: String, sendTime: Timestamp? = nil, senderId: String, status: String, type: String) {
        self.content = content
        self.sendTime = sendTime ?? Timestamp(date: Date()) // Default to current time if not provided
        self.senderId = senderId
        self.status = status
        self.type = type
        self.messageId = "" // Generate a unique message ID
        self.mediaURL = nil // No media URL in this initializer
    }

    // Convenience initializer for Firestore data (dictionary)
    convenience init(dictionary: [String: Any]) {
        self.init(
            content: dictionary["content"] as? String ?? "",
            mediaURL: dictionary["mediaURL"] as? String,
            messageId: dictionary["messageId"] as? String ?? "",
            sendTime: dictionary["sendTime"] as? Timestamp ?? Timestamp(date: Date()),
            senderId: dictionary["senderId"] as? String ?? "",
            status: dictionary["status"] as? String ?? "",
            type: dictionary["type"] as? String ?? ""
        )
    }

    // Default initializer
    convenience init() {
        self.init(
            content: "",
            mediaURL: nil,
            messageId: UUID().uuidString,
            sendTime: Timestamp(date: Date()),
            senderId: "",
            status: "",
            type: ""
        )
    }
}
