//
//  EditPostTableViewController.swift
//  SocialConnectProject
//
//  Created by user259543 on 12/3/24.
//

import UIKit
import FirebaseCore

class EditPostTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var postReposotory = PostRepository()
    @IBOutlet weak var userFullName: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var postSelectImage: UIImageView!
    @IBOutlet weak var userUserName: UILabel!
    var userFromHomePage: User!
    var postFromHomePage: Post!
    @IBOutlet weak var selectImageButton: UIButton! // Add an IBOutlet for the select image button
    @IBOutlet weak var postContent: UITextView!
    var postImageUrl: URL?
    override func viewDidLoad() {
        super.viewDidLoad()

        selectImageButton.isHidden = false
        fetchUserData()
        
    }

    func fetchUserData() {
        // Check if userFromHomePage is properly set and not nil
        if let user = userFromHomePage {
            userFullName.text = "\(user.firstname) \(user.lastname)"
            userUserName.text = user.username
            
            // Handle user image safely
            if !user.photo.isEmpty {
                // Assuming 'user.photo' is a file path or URL
                if let photoURL = URL(string: user.photo) {
                    userImage.loadCircularImageFromFileURL(fileURL: photoURL)
                }
            } else {
                userImage.setPlaceholderImage(for: user.username)
            }
        } else {
            print("Error: userFromHomePage is nil")
        }
        
        // Handle post data
        if let post = postFromHomePage {
            postContent.text = postFromHomePage.content
            
            // Handle post image safely
            if !postFromHomePage.imageURL.isEmpty {
                // Assuming 'post.imageURL' is a file path or URL
                if let photoURL = URL(string: post.imageURL) {
                    postSelectImage.loadImageFromFileURL(fileURL: photoURL)
                }
            } else {
                postSelectImage.setPlaceholderImage(for: userFromHomePage?.username ?? "")
            }
        } else {
            print("Error: postFromHomePage is nil")
        }
    }
    
    lazy var onComplete: () -> Void = { [weak self] in
        guard let self = self else { return }
        
        
            
            self.navigationController?.popViewController(animated: true)
        
    }

    @IBAction func saveButton(_ sender: Any) {
        
        
        guard let user = userFromHomePage, let post = postFromHomePage else {
            print("User or post data is missing")
            return
        }
        
        // Get updated content from the UITextView
        let updatedContent = postContent.text ?? post.content
        
        // Get the updated image URL if available
        let updatedImageURL = postImageUrl?.absoluteString ?? post.imageURL
        
        // Update the post object
        let updatedPost = Post(
            postId: post.postId, // Existing post ID
            commentsCount: post.commentsCount, // Keep existing
            content: updatedContent, // Updated content
            createdAt: post.createdAt, // Keep existing
            imageURL: updatedImageURL, // Updated image URL
            likes: post.likes, // Keep existing
            updatedAt: Timestamp(date: Date()), // Updated timestamp
            userId: user.userAuthId // User ID from userFromHomePage
        )
        
        // Call the repository to update the post
        postReposotory.updatePost(post: updatedPost) { result in
            if result.isEmpty {
                self.showAlertMessage("Success", "Your Post has been Update Sucessfully posted!", self.onComplete)
                
            }
            else {
                self.showAlertMessage("Error", "\(result)")
            }
        }
    }

    
    
    
    @IBAction func selectImage(_ sender: Any) {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        self.present(vc, animated: true)
    }
    
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            
            if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage{
                self.postSelectImage.image = image
                self.postImageUrl = self.postSelectImage.imageToFileURL(image: image, username: userFromHomePage.username)
                
                // Ensure the "Select Image" button is still visible
                            selectImageButton.isHidden = false
            }
            
            picker.dismiss(animated: true, completion: nil)
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true, completion: nil)
        }
    




}
