//
//  PostRepository.swift
//  SocialConnectProject
//
//  Created by user259543 on 11/29/24.
//

import Foundation
import FirebaseFirestore
import FirebaseCore
import FirebaseAuth
import FirebaseStorage

class PostRepository{
    var db = Firestore.firestore()
    // Get Firebase Storage reference
    //let storage = Storage.storage()
    let storageRef = Storage.storage().reference()
    
    // Function to fetch all posts from a dynamic collection path
    func getAllPosts(from collectionPath: String, completion: @escaping ([Post]) -> Void) {
        var posts = [Post]()
        
        // Firestore query to get all documents from the specified collection path, ordered by 'updatedAt'
        db.collection(collectionPath)
            .order(by: "updatedAt", descending: true) // Order by updatedAt in descending order (most recent first)
            .addSnapshotListener { snapshot, error in
                
                // Check if there are any documents in the snapshot
                if let documents = snapshot?.documents {
                    // Map the documents to Post objects
                    posts = documents.compactMap { doc -> Post? in
                        let data = doc.data()
                        return Post(dictionary: data) // Assuming your Post class has a dictionary initializer
                    }
                    
                    // Call the completion handler with the array of posts
                    completion(posts)
                } else {
                    print("Error fetching posts: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
    }

    
    
    // Function to fetch a specific post by document ID from a collection path
        func getPost(byId postId: String, from collectionPath: String, completion: @escaping (Post?) -> Void) {
            // Fetching the specific post document by its ID
            db.collection(collectionPath).document(postId).getDocument { snapshot, error in
                if let error = error {
                    print("Error fetching post: \(error.localizedDescription)")
                    completion(nil)
                } else if let snapshot = snapshot, snapshot.exists, let data = snapshot.data() {
                    let post = Post(dictionary: data)
                    completion(post)
                } else {
                    print("Post not found")
                    completion(nil)
                }
            }
        }
    
    
    func savePost(_ post: Post, completion: @escaping (Error?) -> Void) {
        
        let ref = db.collection("Posts").document()
        var data = [
            "commentsCount": post.commentsCount,
            "content": post.content,
            "createdAt": post.createdAt,
            "imageURL": post.imageURL,
            "likes": post.likes,
            "updatedAt": post.updatedAt,
            "userId": post.userId,
            "postId": post.postId ?? "0"
        ] as [String: Any]
        
        // Add a new document using the existing db reference
        ref.setData(data){ error in
            if let error = error {
                completion(error)
                return
            }
            
            // Update the postId field with the document ID
            ref.updateData(["postId": ref.documentID]) { error in
                completion(error)
            }
        }
    }
    
    func getAllPostUser(forUser userAuthId: String, completion: @escaping ([Post]) -> Void) {
        var posts = [Post]()
        
        // Firestore query with whereField to filter documents and order them by 'updatedAt'
        db.collection("Posts")
            .whereField("userId", isEqualTo: userAuthId) // Filter posts by user ID
            .order(by: "updatedAt", descending: true) // Order by updatedAt in descending order
            .addSnapshotListener { snapshot, error in
                
                // Check for snapshot and errors
                if let documents = snapshot?.documents {
                    // Map the documents to Post objects
                    posts = documents.compactMap { doc -> Post? in
                        let data = doc.data()
                        return Post(dictionary: data) // Assuming your Post class has a dictionary initializer
                    }
                    
                    // Call the completion handler with the array of filtered and ordered posts
                    completion(posts)
                } else {
                    print("Error fetching posts: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
    }


    func deletePost(with postId: String, completion: @escaping (String) -> Void) {
       
        
        db.collection("Posts").document(postId).delete { error in
            if let error = error {
                // Pass the error message to the completion handler
                completion(error.localizedDescription)
            } else {
                // Pass an empty string to indicate success
                completion("")
            }
        }
    }
    
    func updatePost(post: Post, completion: @escaping (String) -> Void) {
        // Ensure the postId exists
        guard let postId = post.postId else {
            completion("Invalid post ID")
            return
        }
        
        // Prepare the data for updating
        let postData: [String: Any] = [
            "commentsCount": post.commentsCount,
            "content": post.content,
            "createdAt": post.createdAt,
            "imageURL": post.imageURL,
            "likes": post.likes,
            "updatedAt": FieldValue.serverTimestamp(), // Automatically update to server time
            "userId": post.userId
        ]
        
        // Update the post document in Firestore
        db.collection("Posts").document(postId).setData(postData, merge: true) { error in
            if let error = error {
                // Pass the error message to the completion handler
                completion(error.localizedDescription)
            } else {
                // Pass an empty string to indicate success
                completion("")
            }
        }
    }

    func addCommentToPost(comment: Comment, postId: String, completion: @escaping (Error?, String?) -> Void) {
        // Reference to the Firestore collection where comments are stored
        let commentsRef = db.collection("Posts").document(postId).collection("Comments")
        
        // Create a dictionary for the comment data
        var commentData = comment.toDictionary()
        commentData["postId"] = postId  // Ensure the postId is associated with the comment
        
        // Add a new comment document to Firestore
        let ref = commentsRef.document() // This automatically generates a document ID
        ref.setData(commentData) { error in
            if let error = error {
                // If an error occurs, pass it back via the completion handler
                completion(error, nil)
            } else {
                // After adding the comment, update the commentId with the Firestore-generated document ID
                ref.updateData(["commentId": ref.documentID]) { error in
                    if let error = error {
                        // Return any error from updating the commentId
                        completion(error, nil)
                    } else {
                        // Successfully added the comment and updated the commentId
                        // Update the post's comment count
                        self.updatePostCommentCount(postId: postId) { error in
                            if let error = error {
                                // Return any error from updating the comment count
                                completion(error, nil)
                            } else {
                                // Successfully updated the comment count
                                completion(nil, ref.documentID) // Return the commentId
                            }
                        }
                    }
                }
            }
        }
    }

    private func updatePostCommentCount(postId: String, completion: @escaping (Error?) -> Void) {
        let postRef = db.collection("Posts").document(postId)
        
        // Fetch the current post data to get the current comment count
        postRef.getDocument { document, error in
            if let error = error {
                completion(error)
                return
            }
            
            // Check if the document exists and retrieve the current commentsCount
            if let document = document, document.exists, let data = document.data(),
               let currentCommentsCountString = data["commentsCount"] as? String,
               let currentCommentsCount = Int(currentCommentsCountString) {
                
                // Increment the comment count
                let newCommentsCount = currentCommentsCount + 1
                
                // Update the comment count in Firestore as a string
                postRef.updateData([
                    "commentsCount": "\(newCommentsCount)" // Store it as a string
                ]) { error in
                    if let error = error {
                        completion(error)
                    } else {
                        completion(nil)
                    }
                }
            } else {
                // Handle the case where the document does not exist or the commentsCount is missing
                let error = NSError(domain: "FirestoreError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Post not found or comments count is missing"])
                completion(error)
            }
        }
    }


    // Function to fetch all comments for a specific post
    func getAllCommentsForPost(postId: String, completion: @escaping ([Comment]?) -> Void) {
        var comments = [Comment]()
        
        // Firestore query to get all comments for a specific postId
        db.collection("Posts")
            .document(postId)  // Reference the post by its postId
            .collection("Comments") // Reference the Comments subcollection
            .order(by: "createdAt", descending: true) // Order by timestamp, descending (latest first)
            .addSnapshotListener { snapshot, error in
                // Check for snapshot and errors
                if let documents = snapshot?.documents {
                    // Map the documents to Comment objects using the dictionary initializer
                    comments = documents.compactMap { doc -> Comment? in
                        let data = doc.data()
                        return Comment(dictionary: data) // Assuming your Comment class has a dictionary initializer
                    }
                    
                    // Call the completion handler with the array of comments
                    completion(comments)
                } else {
                    print("Error fetching comments: \(error?.localizedDescription ?? "Unknown error")")
                    completion(nil)
                }
            }
    }

}
