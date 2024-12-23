import Foundation
import FirebaseFirestore

class Conversation {
    var conversationId: String
    var lastMessage: String
    var lastUpdated: Timestamp!
    var participants: [String]

    init(conversationId: String, lastMessage: String, lastUpdated: Timestamp? = nil, participants: [String]) {
        self.conversationId = conversationId
        self.lastMessage = lastMessage
        self.lastUpdated = lastUpdated ?? Timestamp(date: Date())
        self.participants = participants
    }
    
    convenience init(conversationId: String, lastMessage: String, lastUpdated: Timestamp!) {
        self.init(
            conversationId: conversationId,
            lastMessage: lastMessage,
            lastUpdated: lastUpdated,
            participants: []
        )
    }
    
    convenience init(dictionary: [String: Any]) {
        self.init(
            conversationId: dictionary["conversationId"] as? String ?? "",
            lastMessage: dictionary["lastMessage"] as? String ?? "",
            lastUpdated: dictionary["lastUpdated"] as? Timestamp ?? Timestamp(date: Date()),
            participants: dictionary["participants"] as? [String] ?? []
        )
    }
    
    convenience init() {
        self.init(
            conversationId: "",
            lastMessage: "",
            lastUpdated: Timestamp(date: Date()),
            participants: []
        )
    }
}
