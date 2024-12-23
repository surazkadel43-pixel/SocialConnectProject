//
//  Repositories.swift
//  SocialConnectProject
//
//  Created by user259543 on 10/26/24.
//

import Foundation
import FirebaseFirestore
import FirebaseCore
import FirebaseAuth
import FirebaseStorage


class Repositories{
     
    var db = Firestore.firestore()
    

   
    // add user to the database to the database
    // Add user to the database
    func registerUser(_ user: User, _ userAuthId: String) -> Bool {
        var result = true
        let dictionary: [String: Any] = [
            "Username": user.username,
            "Email": user.email,
            "Password": user.password,
            "firstname": user.firstname,
            "lastname": user.lastname,
            "phoneNumber": user.phone,
            "DOB": user.DOB,
            "photo": user.photo,
            "gender": user.gender,
            "registered": user.registered ?? FieldValue.serverTimestamp(),
            "userAuthId": userAuthId,
            "isOnline": user.isOnline,
            "followersCount": 0, // Initialize followersCount
            "followingCount": 0  // Initialize followingCount
        ]
        
        db.collection("User").document(userAuthId).setData(dictionary) { error in
            if let error = error {
                print("User could not be added \(user.username): \(error.localizedDescription)")
                result = false
            } else {
                print("User \(user.username) added successfully.")
            }
        }
        
        return result
    }

    func getUserData(completion: @escaping (User?) -> Void) {
        guard let userAuthId = Auth.auth().currentUser?.uid else {
            print("No user is currently logged in.")
            completion(nil)
            return
        }

        // Firestore reference
        let db = Firestore.firestore()

        // Adding a snapshot listener to listen for real-time changes
        db.collection("User")
            .whereField("userAuthId", isEqualTo: userAuthId)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching user data: \(error.localizedDescription)")
                    completion(nil)
                } else {
                    if let document = snapshot?.documents.first {
                        let data = document.data()
                        
                        // Assuming you have a User initializer that takes a dictionary
                        let user = User(dictionary: data)
                        completion(user)
                    } else {
                        print("No user found for the provided userAuthId.")
                        completion(nil)
                    }
                }
            }
    }
    func getUserData(userId: String, completion: @escaping (User?) -> Void) {
           // Reference the "Users" collection and the specific document by userId
           db.collection("User").document(userId).getDocument { document, error in
               if let error = error {
                   // Handle Firestore query error
                   print("Error fetching user data: \(error.localizedDescription)")
                   completion(nil)
               } else if let document = document, document.exists {
                   // Parse the document data into a User object
                   if let data = document.data() {
                       let user = User(dictionary: data)
                       completion(user)
                   } else {
                       print("Document exists but contains no data for userId: \(userId)")
                       completion(nil)
                   }
               } else {
                   // Document not found
                   print("No user found for the provided userId: \(userId)")
                   completion(nil)
               }
           }
       }
    
    func getCurrentUser(completion: @escaping (User?) -> Void) {
        guard let userAuthId = Auth.auth().currentUser?.uid else {
            print("No user is currently logged in.")
            completion(nil)
            return
        }

        // Firestore reference
        let db = Firestore.firestore()

        // Fetch the document for the current user using the userAuthId
        db.collection("User")
            .whereField("userAuthId", isEqualTo: userAuthId)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching user data: \(error.localizedDescription)")
                    completion(nil)
                } else {
                    if let document = snapshot?.documents.first {
                        let data = document.data()
                        
                        // Assuming you have a User initializer that takes a dictionary
                        let user = User(dictionary: data)
                        completion(user)
                    } else {
                        print("No user found for the provided userAuthId.")
                        completion(nil)
                    }
                }
            }
    }



    // Function to save or update user details using userAuthId as the document ID
    func saveUserDetails(user: User, completion: @escaping (Bool, String) -> Void) {
        // Get the current authenticated user's UID
        guard let userAuthId = Auth.auth().currentUser?.uid else {
            print("Error: User not authenticated")
            completion(false, "Error: User not authenticated")
            return
        }

        // Create dictionary of user details
        let userData: [String: Any] = [
            "firstname": user.firstname,
            "lastname": user.lastname,
            "Username": user.username,
            "phoneNumber": user.phone,
            "DOB": user.DOB,
            "gender": user.gender,
            "Password": user.password, // Ensure this is hashed
            "Email": user.email,
            "photo": user.photo, // If you want to store the image URL
            "userAuthId": userAuthId,
            "registered": user.registered ?? Timestamp(date: Date())
        ]

        // Firestore reference to the document by userAuthId
        let db = Firestore.firestore()
        let userDocumentRef = db.collection("User").document(userAuthId)

        // Update or set the user data
        userDocumentRef.setData(userData, merge: true) { error in
            if let error = error {
                print("Failed to update user details: \(error)")
                completion(false, "Failed to update user details: \(error)")
            } else {
                print("User details updated successfully.")
                // Call updateFirebaseAuthPassword after saving user details
                self.updateFirebaseAuthPassword(user: user) { success, message in
                    if success {
                        completion(true, "User details and password updated successfully.")
                    } else {
                        completion(false, "User details updated, but failed to update password: \(message)")
                    }
                }
            }
        }
    }



    
    func updateFirebaseAuthPassword(user: User, completion: @escaping (Bool, String) -> Void) {
        // Get the current authenticated user
        guard let currentUser = Auth.auth().currentUser else {
            print("Error: User not authenticated")
            completion(false, "Error: User not authenticated")
            return
        }

        // Update the password
        Auth.auth().currentUser?.updatePassword(to: user.password) { error in
            if let error = error {
                print("Error updating password: \(error.localizedDescription)")
                completion(false, "Error updating password: \(error.localizedDescription)")
                return
            }

            print("Password updated successfully.")
            completion(true, "Password updated successfully.")
        }
    }


    
    // updateUser
    func updateUserDetails(_ user: User, completion: @escaping (Bool) -> Void) {
        // Get the current authenticated user's UID
        guard let userAuthId = Auth.auth().currentUser?.uid else {
            print("Error: User not authenticated")
            completion(false)
            return
        }

        // Dictionary of fields to update
        let updatedData: [String: Any] = [
            "firstname": user.firstname,
            "lastname": user.lastname,
            "phoneNumber": user.phone,
            "DOB": user.DOB,
            "photo": user.photo,
            "gender": user.gender,
            "isOnline" : true
        ]
        
        // Query the collection for the document with matching userAuthId
        db.collection("User").whereField("userAuthId", isEqualTo: userAuthId).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching user document: \(error)")
                completion(false)
                return
            }
            
            // Ensure we have at least one document that matches the userAuthId
            guard let document = querySnapshot?.documents.first else {
                print("No document found for userAuthId \(userAuthId)")
                completion(false)
                return
            }
            
            // Update the document with the matching userAuthId
            document.reference.updateData(updatedData) { error in
                if let error = error {
                    print("User document update failed: \(error)")
                    completion(false)
                } else {
                    print("User document updated successfully.")
                    completion(true)
                }
            }
        }
    }

    
    func getAllUser(_ username: String, _ completion: @escaping ([User]) -> ()) {
        var users = [User]()
        
        // Firestore query to get documents ordered by 'updatedAt'
        db.collection(username)
            .order(by: "registered", descending: true) // Order by updatedAt in descending order
            .addSnapshotListener { snapshot, error in
                
                if let documents = snapshot?.documents {
                    // Map the documents to User objects
                    users = documents.compactMap({ doc -> User? in
                        let data = doc.data()
                        return User(dictionary: data) // Assuming User has a dictionary initializer
                    })
                    
                    for obj in users {
                        print("\(obj.username)")
                    }
                    
                    // Call the completion handler with the array of users
                    completion(users)
                } else {
                    print("Error fetching users: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
    }

    
    func getAllFollowingUsers(_ userAuthId: String, _ completion: @escaping ([User]) -> ()) {
        var followingUsers = [User]()
        
        // Reference to the following collection in Firestore
        db.collection("User").document(userAuthId).collection("following").addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error fetching following users: \(error.localizedDescription)")
                return
            }
            
            if let documents = snapshot?.documents {
                // For each following user, get the user details using the userAuthId
                let group = DispatchGroup()  // To handle multiple asynchronous fetch requests
                
                for document in documents {
                    group.enter()  // Start a new task for each document
                    
                    let followedUserAuthId = document.documentID  // Get the userAuthId of the followed user
                    
                    // Fetch user details from the 'User' collection using the userAuthId
                    self.db.collection("User").document(followedUserAuthId).getDocument { docSnapshot, error in
                        if let error = error {
                            print("Error fetching user details for \(followedUserAuthId): \(error.localizedDescription)")
                        } else if let docSnapshot = docSnapshot, let data = docSnapshot.data() {
                            // Create a User instance from the document data
                            let user = User(dictionary: data)
                            followingUsers.append(user)
                        }
                        group.leave()  // Mark this task as complete
                    }
                }
                
                // Wait for all user details to be fetched
                group.notify(queue: .main) {
                    // Return the list of following users via the completion handler
                    completion(followingUsers)
                }
            }
        }
    }


    func getAllFollowersUsers(_ userAuthId: String, _ completion: @escaping ([User]) -> ()) {
        var followersUsers = [User]()
        
        // Reference to the followers collection in Firestore
        db.collection("User").document(userAuthId).collection("followers").addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error fetching followers users: \(error.localizedDescription)")
                return
            }
            
            if let documents = snapshot?.documents {
                // For each follower, get the user details using the userAuthId
                let group = DispatchGroup()  // To handle multiple asynchronous fetch requests
                
                for document in documents {
                    group.enter()  // Start a new task for each document
                    
                    let followerUserAuthId = document.documentID  // Get the userAuthId of the follower
                    
                    // Fetch user details from the 'User' collection using the userAuthId
                    self.db.collection("User").document(followerUserAuthId).getDocument { docSnapshot, error in
                        if let error = error {
                            print("Error fetching user details for \(followerUserAuthId): \(error.localizedDescription)")
                        } else if let docSnapshot = docSnapshot, let data = docSnapshot.data() {
                            // Create a User instance from the document data
                            let user = User(dictionary: data)
                            followersUsers.append(user)
                        }
                        group.leave()  // Mark this task as complete
                    }
                }
                
                // Wait for all user details to be fetched
                group.notify(queue: .main) {
                    // Return the list of followers users via the completion handler
                    completion(followersUsers)
                }
            }
        }
    }


    func checkIfFollowing(currentUserAuthId: String, otherUserAuthId: String, completion: @escaping (Bool) -> ()) {
        // Reference to the current user's 'following' collection
        let currentUserRef = db.collection("User").document(currentUserAuthId).collection("following")
        
        // Use SnapshotListener to listen for real-time changes
        currentUserRef.document(otherUserAuthId).addSnapshotListener { (document, error) in
            if let document = document, document.exists {
                // The current user is following the other user
                completion(true)
            } else {
                // The current user is not following the other user
                completion(false)
            }
        }
    }


    func checkIfFollowedBy(currentUserAuthId: String, otherUserAuthId: String, completion: @escaping (Bool) -> ()) {
        // Reference to the other user's 'followers' collection
        let otherUserRef = db.collection("User").document(currentUserAuthId).collection("followers")
        
        // Use SnapshotListener to listen for real-time changes
        otherUserRef.document(otherUserAuthId).addSnapshotListener { (document, error) in
            if let document = document, document.exists {
                // The other user is following the current user
                completion(true)
            } else {
                // The other user is not following the current user
                completion(false)
            }
        }
    }

    func unfriendUser(currentUserAuthId: String, otherUserAuthId: String, completion: @escaping (Bool) -> ()) {
        let currentUserFollowingRef = db.collection("User").document(currentUserAuthId).collection("following").document(otherUserAuthId)
        let otherUserFollowersRef = db.collection("User").document(otherUserAuthId).collection("followers").document(currentUserAuthId)
        let otherUserFollowingRef = db.collection("User").document(otherUserAuthId).collection("following").document(currentUserAuthId)
        let currentUserFollowersRef = db.collection("User").document(currentUserAuthId).collection("followers").document(otherUserAuthId)

        // Delete the follow relationship from both users
        currentUserFollowingRef.delete { error in
            if let error = error {
                print("Error removing following: \(error)")
                completion(false)
                return
            }

            otherUserFollowersRef.delete { error in
                if let error = error {
                    print("Error removing follower: \(error)")
                    completion(false)
                    return
                }
                
                // Delete the reverse follow relationship
                otherUserFollowingRef.delete { error in
                    if let error = error {
                        print("Error removing reverse following: \(error)")
                        completion(false)
                        return
                    }

                    currentUserFollowersRef.delete { error in
                        if let error = error {
                            print("Error removing reverse follower: \(error)")
                            completion(false)
                            return
                        }

                        // Update follower and following counts after unfriend
                        self.updateFollowerAndFollowingCount(userAuthId: currentUserAuthId)
                        self.updateFollowerAndFollowingCount(userAuthId: otherUserAuthId)

                        // If all operations succeed
                        completion(true)
                    }
                }
            }
        }
    }


    func cancelFollow(currentUserAuthId: String, otherUserAuthId: String, completion: @escaping (Bool) -> ()) {
        let currentUserFollowingRef = db.collection("User").document(currentUserAuthId).collection("following").document(otherUserAuthId)
        let otherUserFollowersRef = db.collection("User").document(otherUserAuthId).collection("followers").document(currentUserAuthId)
        
        // Delete from the "following" collection of the current user
        currentUserFollowingRef.delete { error in
            if let error = error {
                print("Error removing from following collection: \(error)")
                completion(false)
                return
            }
            
            // Delete from the "followers" collection of the other user
            otherUserFollowersRef.delete { error in
                if let error = error {
                    print("Error removing from followers collection: \(error)")
                    completion(false)
                    return
                }
                
                // Update follower and following counts after cancel follow
                self.updateFollowerAndFollowingCount(userAuthId: currentUserAuthId)
                self.updateFollowerAndFollowingCount(userAuthId: otherUserAuthId)
                
                // If both deletions succeed
                completion(true)
            }
        }
    }



    func acceptFollowRequest(currentUserAuthId: String, otherUserAuthId: String, completion: @escaping (Bool) -> ()) {
        let currentUserFollowingRef = db.collection("User").document(currentUserAuthId).collection("following").document(otherUserAuthId)
        let otherUserFollowersRef = db.collection("User").document(otherUserAuthId).collection("followers").document(currentUserAuthId)
        
        // Add to the "following" collection of the current user
        currentUserFollowingRef.setData([:]) { error in
            if let error = error {
                print("Error adding to following collection: \(error)")
                completion(false)
                return
            }
            
            // Add to the "followers" collection of the other user
            otherUserFollowersRef.setData([:]) { error in
                if let error = error {
                    print("Error adding to followers collection: \(error)")
                    completion(false)
                    return
                }
                
                // Update follower and following counts after accepting the request
                self.updateFollowerAndFollowingCount(userAuthId: currentUserAuthId)
                self.updateFollowerAndFollowingCount(userAuthId: otherUserAuthId)
                
                // If both operations succeed
                completion(true)
            }
        }
    }



    func sendFollowRequest(currentUserAuthId: String, otherUserAuthId: String, completion: @escaping (Bool) -> ()) {
        let currentUserFollowingRef = db.collection("User").document(currentUserAuthId).collection("following").document(otherUserAuthId)
        let otherUserFollowersRef = db.collection("User").document(otherUserAuthId).collection("followers").document(currentUserAuthId)
        
        // Add to the "following" collection of the current user
        currentUserFollowingRef.setData([:]) { error in
            if let error = error {
                print("Error adding to following collection: \(error)")
                completion(false)
                return
            }
            
            // Add to the "followers" collection of the other user
            otherUserFollowersRef.setData([:]) { error in
                if let error = error {
                    print("Error adding to followers collection: \(error)")
                    completion(false)
                    return
                }
                
                // Update follower and following counts after sending the follow request
                self.updateFollowerAndFollowingCount(userAuthId: currentUserAuthId)
                self.updateFollowerAndFollowingCount(userAuthId: otherUserAuthId)
                
                // If both operations succeed
                completion(true)
            }
        }
    }


    

    func updateFollowerAndFollowingCount(userAuthId: String) {
       
        let followersRef = db.collection("User").document(userAuthId).collection("followers")
        let followingRef = db.collection("User").document(userAuthId).collection("following")

        // Get the count of followers
        followersRef.getDocuments { snapshot, error in
            if let error = error {
                print("Error getting followers count: \(error)")
                return
            }

            let followerCount = snapshot?.documents.count ?? 0

            // Get the count of following
            followingRef.getDocuments { snapshot, error in
                if let error = error {
                    print("Error getting following count: \(error)")
                    return
                }

                let followingCount = snapshot?.documents.count ?? 0

                // Update the user document with the new counts
                let userRef = self.db.collection("User").document(userAuthId)
                userRef.updateData([
                    "followersCount": followerCount,
                    "followingCount": followingCount
                ]) { error in
                    if let error = error {
                        print("Error updating counts: \(error)")
                    } else {
                        print("Successfully updated follower and following counts for user \(userAuthId)")
                    }
                }
            }
        }
    }

    


    func userFound(_ collectionName: String, _ username: String, _ foundUser: @escaping (Bool) -> ()) {
        guard let userAuthId = Auth.auth().currentUser?.uid else {
            print("No user is currently logged in.")
            foundUser(false)
            return
        }

        // Query Firestore to check if the username exists
        db.collection(collectionName)
            .whereField("Username", isEqualTo: username)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching user data: \(error.localizedDescription)")
                    foundUser(false)
                    return
                }

                // Check if a document with the provided username exists
                if let documents = snapshot?.documents, !documents.isEmpty {
                    print("Username found in repositories: \(username)")
                    foundUser(true)
                } else {
                    print("Username not found in repositories.")
                    foundUser(false)
                }
            }
    }

    func validateUser(_ collectionName: String, _ username: String, _ password: String, _ foundUser: @escaping (Bool, String) -> ()) {
        var result: Bool = false
        var userEmail: String!
        
        // Query Firestore to validate the user by username and password
        db.collection(collectionName)
            .whereField("Username", isEqualTo: username)
            .whereField("Password", isEqualTo: password)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching user data: \(error.localizedDescription)")
                    foundUser(false, "")  // return false and empty email on error
                    return
                }

                // If documents are found with the matching username and password
                if let documents = snapshot?.documents, !documents.isEmpty {
                    if let data = documents.first?.data() {
                        // Extract the email and set the result to true if username and password match
                        userEmail = data["Email"] as? String
                        result = true
                    }
                    
                    // Return the result along with the user email
                    foundUser(result, userEmail ?? "")
                } else {
                    print("Invalid username or password.")
                    foundUser(result, "")  // return false and empty email if no match found
                }
            }
    }

    func userFound(_ collectionName: String, _ email: String, _ foundUser: @escaping (Int, String, User) -> ()) {
        var result: Int = 0
        var user: User!
        var password: String!
        
        // Query Firestore to find user with the provided email
        db.collection(collectionName)
            .whereField("Email", isEqualTo: email)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching user data: \(error.localizedDescription)")
                    foundUser(result, "", User("s"))  // return default values on error
                    return
                }
                
                // If documents are found with the provided email
                if let documents = snapshot?.documents, !documents.isEmpty {
                    // Get the first document with the matching email
                    if let data = documents.first?.data() {
                        if let emailFromData = data["Email"] as? String, emailFromData == email {
                            password = data["Password"] as? String
                            user = User(dictionary: data)
                            result = 1
                        }
                    }
                    
                    foundUser(result, password ?? "", user ?? User("s"))
                } else {
                    print("No user found with the provided email.")
                    foundUser(result, "", User("s"))  // return default values if no user found
                }
            }
    }

    
    
    // Function to check if the user details are filled
    func checkUserDetails(completion: @escaping (Bool) -> Void) {
        guard let userAuthId = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }
        
        
        
        // Query the Firestore database to check if the user details are filled
        db.collection("User").whereField("userAuthId", isEqualTo: userAuthId).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            if let document = snapshot?.documents.first {
                // Check if user details like "username", "phoneNumber", etc., are present
                if let username = document.data()["firstname"] as? String,
                   let phoneNumber = document.data()["phoneNumber"] as? String, !username.isEmpty, !phoneNumber.isEmpty {
                    // If details are filled, set isOnline to true
                    //self.setUserOnline(userAuthId: userAuthId)  // Call to set isOnline to true
                    completion(true)
                } else {
                    // If details are not filled, return false
                    completion(false)
                }
            } else {
                completion(false)
            }
        }
    }
    // function to set user offline
    func setUserOffline(userAuthId: String, completion: @escaping (Bool) -> Void) {
        let userRef = db.collection("User").document(userAuthId)
        
        // Update the 'isOnline' field to false
        userRef.updateData([
            "isOnline": false
        ]) { error in
            if let error = error {
                print("Error updating isOnline field to false: \(error.localizedDescription)")
                completion(false)  // Return false if there's an error
            } else {
                print("User is now offline")
                completion(true)  // Return true if the update is successful
            }
        }
    }

    // Function to set the 'isOnline' field to true
    func setUserOnline() {
        guard let userAuthId = Auth.auth().currentUser?.uid else {
            print("Error: User is not authenticated")
            return
        }
        
        let userRef = db.collection("User").document(userAuthId)
        
        // Update the 'isOnline' field to true
        userRef.updateData([
            "isOnline": true
        ]) { error in
            if let error = error {
                print("Error updating isOnline field: \(error.localizedDescription)")
            } else {
                print("User is now online")
            }
        }
    }

    func saveUserDetailsWithImage(user: User, userImage: UIImage, completion: @escaping (Bool, User) -> Void) {
        // Retrieve the authenticated user's ID
        guard let userAuthID = Auth.auth().currentUser?.uid else {
            print("Failed to retrieve user Auth ID")
            completion(false, user)
            return
        }

        // Convert UIImage to Data
        guard let imageData = userImage.pngData() else {
            print("Failed to convert image to data")
            completion(false, user)
            return
        }

        // Reference to Firebase Storage
        let storage = Storage.storage().reference()

        // Generate the image path using the user's authentication ID as the file name
        let imagePath = "userImages/\(userAuthID).png"

        // Create a reference for the image in the storage
        let imageRef = storage.child(imagePath)

        print("\(imageRef)")
        // Print the size of the image data in bytes
        print("Image data size: \(imageData.count) bytes")

        // Upload the image to Firebase Storage
        imageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Failed to upload image: \(error.localizedDescription)")
                completion(false, user)
                return
            }

            // Get the download URL of the uploaded image
            imageRef.downloadURL { url, error in
                if let error = error {
                    print("Failed to get download URL: \(error.localizedDescription)")
                    completion(false, user)
                } else if let imageUrl = url?.absoluteString {
                    print("Image URL: \(imageUrl)")

                    // Update the user object with the image URL
                    var updatedUser = user
                    updatedUser.photo = imageUrl
                    completion(true, updatedUser)
                    // Optionally save user details to Firestore here
                }
            }
        }
    }

    func uploadImage(image: UIImage, completion: @escaping(String, Bool) -> Void) {
            guard let imageData = image.jpegData(compressionQuality: 0.75) else {return}
        // Retrieve the authenticated user's ID
        guard let userAuthID = Auth.auth().currentUser?.uid else {
            print("Failed to retrieve user Auth ID")
            //completion(false, user)
            return
        }
            let fileName = userAuthID
            let ref = Storage.storage().reference(withPath: "/userImages/\(fileName)")
            
            ref.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    print("Err: Failed to upload image \(error.localizedDescription)")
                    completion("\(error.localizedDescription)", false)
                    return
                }
                
                ref.downloadURL { url, error in
                    guard let imageURL = url?.absoluteString else {return}
                    completion(imageURL, true)
                }
            }
        }

    func saveUserToFirestore(user: User, completion: @escaping (Bool) -> Void) {
        // Reference to the Firestore document
        let firestore = Firestore.firestore()
        let userDocRef = firestore.collection("Users").document(user.username)

        // Convert the user object to a dictionary
        let userDict: [String: Any] = [
            "firstname": user.firstname,
            "lastname": user.lastname,
            "isOnline": true,
            "phone": user.phone,
            "gender": user.gender,
            "DOB": user.DOB,
            "photo": user.photo  // Updated image URL
            
        ]

        // Save the user data to Firestore
        userDocRef.setData(userDict) { error in
            if let error = error {
                print("Failed to save user details: \(error.localizedDescription)")
                completion(false)
            } else {
                print("User details saved successfully!")
                completion(true)
            }
        }
    }
    
    
}



