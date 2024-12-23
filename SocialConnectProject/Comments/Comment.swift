//
//  Comment.swift
//  SocialConnectProject
//
//  Created by user259543 on 12/12/24.
//

import Foundation
import FirebaseCore
class Comment {
    var commentId: String
    var commentBy: String
    var commentText: String
    var createdAt: Timestamp!
    var postId: String
    
    init(commentId: String, commentBy: String, commentText: String, createdAt: Timestamp!, postId: String) {
        self.commentId = commentId
        self.commentBy = commentBy
        self.commentText = commentText
        self.createdAt = createdAt
        self.postId = postId
    }
    
    // Convenience initializer for creating a Comment instance from a Firestore dictionary
        convenience init(dictionary: [String: Any]) {
            let commentId = dictionary["commentId"] as? String ?? ""
            let commentBy = dictionary["commentBy"] as? String ?? ""
            let commentText = dictionary["commentText"] as? String ?? ""
            let createdAt = dictionary["createdAt"] as? Timestamp ?? Timestamp(date: Date())
            let postId = dictionary["postId"] as? String ?? ""
            
            self.init(commentId: commentId, commentBy: commentBy, commentText: commentText, createdAt: createdAt, postId: postId)
        }
    // Convert Comment to a dictionary for Firestore
    func toDictionary() -> [String: Any] {
        return [
            "commentBy": commentBy,
            "commentText": commentText,
            "createdAt": createdAt!,
            "postId": postId
        ]
    }
}
