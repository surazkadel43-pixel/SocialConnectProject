//
//  ConversationReposotory.swift
//  SocialConnectProject
//
//  Created by user259543 on 12/18/24.
//

import Foundation
import FirebaseFirestore
import FirebaseCore
import FirebaseAuth
//import FirebaseStorage


class ConversationRepository {
    
    var db = Firestore.firestore()
    
    func checkIfConversationExists(currentUserAuthId: String, otherUserAuthId: String, completion: @escaping (Bool, Conversation?) -> Void) {
        let conversationsRef = db.collection("Conversation")
        
        // Query to check if a conversation exists where the current user is a participant
        conversationsRef.whereField("participants", arrayContains: currentUserAuthId).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error checking for conversation: \(error.localizedDescription)")
                completion(false, nil)
                return
            }
            
            // Ensure snapshot exists
            guard let snapshot = snapshot else {
                print("No conversations found.")
                completion(false, nil)
                return
            }
            
            // Iterate through documents to find a matching conversation
            for document in snapshot.documents {
                let data = document.data()
                
                // Ensure participants field exists and is an array
                if let participants = data["participants"] as? [String],
                   participants.contains(otherUserAuthId),
                   participants.contains(currentUserAuthId) {
                    
                    // Create a Conversation object from the document data
                    let conversation = Conversation(
                        conversationId: document.documentID,
                        lastMessage: data["lastMessage"] as? String ?? "",
                        lastUpdated: data["lastUpdated"] as? Timestamp ?? Timestamp(date: Date()),
                        participants: participants
                    )
                    
                    // Conversation exists, return it
                    completion(true, conversation)
                    return
                }
            }
            
            // No conversation found
            completion(false, nil)
        }
    }



    func createConversation(currentUserAuthId: String, otherUserAuthId: String, lastMessage: String, completion: @escaping (Bool, Conversation) -> Void) {
        let conversationsRef = db.collection("Conversation")
        
        // Firestore auto-generates a unique document ID for the conversation
        let newConversationRef = conversationsRef.document()  // This generates the document ID automatically
        let newConversationId = newConversationRef.documentID  // Get the auto-generated document ID
        
        let currentTimestamp = FieldValue.serverTimestamp() // Use Firestore server timestamp
        
        // Data to be saved to Firestore
        let conversationData: [String: Any] = [
            "conversationId": newConversationId,  // Save the Firestore document ID as the conversationId
            "lastMessage": lastMessage,
            "lastUpdated": currentTimestamp,
            "participants": [currentUserAuthId, otherUserAuthId]
        ]
        
        // Create the new conversation document with the generated document ID
        newConversationRef.setData(conversationData) { error in
            if let error = error {
                print("Error creating conversation: \(error.localizedDescription)")
                completion(false, Conversation())  // Return an empty Conversation if creation fails
                return
            }
            
            print("Conversation created successfully with ID: \(newConversationId)")
            
            // Create the Conversation object
            let conversation = Conversation(
                conversationId: newConversationId,
                lastMessage: lastMessage,
                lastUpdated: currentTimestamp as? Timestamp ?? Timestamp(date: Date()),
                participants: [currentUserAuthId, otherUserAuthId]
            )
            
            // Successfully created the conversation, return the Conversation object
            completion(true, conversation)
        }
    }



    func updateLastMessage(conversationId: String, newMessage: String, completion: @escaping (Bool) -> Void) {
        let conversationsRef = db.collection("Conversation")
        
        // Update the last message and last updated timestamp
        let updatedData: [String: Any] = [
            "lastMessage": newMessage,
            "lastUpdated": FieldValue.serverTimestamp() // Use Firestore server timestamp
        ]
        
        conversationsRef.document(conversationId).updateData(updatedData) { error in
            if let error = error {
                print("Error updating last message: \(error)")
                completion(false)
                return
            }
            
            print("Last message updated successfully.")
            completion(true)
        }
    }
    
    // Function to get all conversations for a user
    // Function to get all conversations for a user
    func getAllConversations(currentUserAuthId: String, completion: @escaping ([Conversation]) -> Void) {
        // Firestore query to get all conversations where the user is a participant, ordered by 'lastUpdated'
        db.collection("Conversation")
            .whereField("participants", arrayContains: currentUserAuthId) // Filter conversations by participants
            .order(by: "lastUpdated", descending: true) // Order by lastUpdated in descending order (most recent first)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching conversations: \(error.localizedDescription)")
                    completion([]) // Return an empty array on error
                    return
                }
                
                // Check if there are any documents in the snapshot
                if let documents = snapshot?.documents {
                    // Map the documents to Conversation objects using compactMap
                    let conversations = documents.compactMap { doc -> Conversation? in
                        let data = doc.data()
                        return Conversation(dictionary: data) // Assuming your Conversation class has a dictionary initializer
                    }
                    
                    // Call the completion handler with the array of conversations
                    completion(conversations)
                } else {
                    print("No conversations found.")
                    completion([]) // Return an empty array if no conversations are found
                }
            }
    }


    
    

    

    func addMessage(to conversationId: String, message: Message, completion: @escaping (Bool, String) -> Void) {
        //let db = Firestore.firestore()
        let messagesCollectionRef = db.collection("Conversation").document(conversationId).collection("Messages")
        
        // Generate a new document ID
        let documentId = messagesCollectionRef.document().documentID
        
        // Create message data including `messageId`
        var messageData: [String: Any] = [
            "content": message.content,
            "sendTime": message.sendTime ?? Timestamp(date: Date()),
            "senderId": message.senderId,
            "status": message.status,
            "type": message.type,
            "messageId": documentId // Use the generated document ID as `messageId`
        ]
        
        // Add `mediaURL` only if it's not nil
        if let mediaURL = message.mediaURL, !mediaURL.isEmpty {
            messageData["mediaURL"] = mediaURL
        }
        else{
            messageData["mediaURL"] = ""
        }
        
        // Add the message to Firestore with the generated document ID
        messagesCollectionRef.document(documentId).setData(messageData) { error in
            if let error = error {
                print("Failed to add message: \(error.localizedDescription)")
                completion(false, "Failed to add message: \(error.localizedDescription)")
            } else {
                print("Message added successfully with ID \(documentId).")
                completion(true, "Message added successfully with ID \(documentId).")
            }
        }
    }
    
    

    func fetchMessages(for conversationId: String, completion: @escaping ([Message]?, String?) -> Void) {
        //let db = Firestore.firestore()
        let messagesCollectionRef = db.collection("Conversation").document(conversationId).collection("Messages")
        
        // Add a snapshot listener for real-time updates
        messagesCollectionRef.order(by: "sendTime", descending: false).addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error fetching messages: \(error.localizedDescription)")
                completion(nil, "Error fetching messages: \(error.localizedDescription)")
                return
            }
            
            // Check if snapshot exists
            guard let snapshot = snapshot else {
                print("No data found for conversationId: \(conversationId)")
                completion(nil, "No data found for conversationId: \(conversationId)")
                return
            }
            
            // Map snapshot documents to Message objects
            let messages = snapshot.documents.compactMap { document -> Message? in
                let data = document.data()
                return Message(dictionary: data)
            }
            
            print("Fetched \(messages.count) messages.")
            completion(messages, nil)
        }
    }



    func deleteConversation(with conversationId: String, completion: @escaping (Bool, String?) -> Void) {
        let conversationDocRef = db.collection("Conversation").document(conversationId)

        conversationDocRef.delete { error in
            if let error = error {
                print("Error deleting conversation: \(error.localizedDescription)")
                completion(false, "Error deleting conversation: \(error.localizedDescription)")
                return
            }
            
            print("Conversation \(conversationId) successfully deleted.")
            completion(true, nil)
        }
    }



}

