import Foundation
import FirebaseFirestore

class Post {
    var postId: String? // Optional to handle cases where postId might not be available
    var commentsCount: String
    var content: String
    var createdAt: Timestamp
    var imageURL: String
    var likes: String
    var updatedAt: Timestamp
    var userId: String
    
    // Designated initializer
    init(postId: String? = nil, commentsCount: String, content: String, createdAt: Timestamp, imageURL: String, likes: String, updatedAt: Timestamp, userId: String) {
        self.postId = postId
        self.commentsCount = commentsCount
        self.content = content
        self.createdAt = createdAt
        self.imageURL = imageURL
        self.likes = likes
        self.updatedAt = updatedAt
        self.userId = userId
    }
    
    // Convenience initializer for minimal data
    convenience init(content: String, userId: String) {
        self.init(postId: nil,
                  commentsCount: "0",
                  content: content,
                  createdAt: Timestamp(date: Date()),
                  imageURL: "",
                  likes: "0",
                  updatedAt: Timestamp(date: Date()),
                  userId: userId)
    }
    
    // Convenience initializer from Firestore dictionary
    convenience init(dictionary: [String: Any]) {
        self.init(
            postId: dictionary["postId"] as? String,
            commentsCount: dictionary["commentsCount"] as? String ?? "0",
            content: dictionary["content"] as? String ?? "",
            createdAt: dictionary["createdAt"] as? Timestamp ?? Timestamp(date: Date()),
            imageURL: dictionary["imageURL"] as? String ?? "",
            likes: dictionary["likes"] as? String ?? "0",
            updatedAt: dictionary["updatedAt"] as? Timestamp ?? Timestamp(date: Date()),
            userId: dictionary["userId"] as? String ?? ""
        )
    }
    
    // Convenience initializer for creating an empty post
    convenience init() {
        self.init(postId: nil,
                  commentsCount: "0",
                  content: "",
                  createdAt: Timestamp(date: Date()),
                  imageURL: "",
                  likes: "0",
                  updatedAt: Timestamp(date: Date()),
                  userId: "")
    }
}
