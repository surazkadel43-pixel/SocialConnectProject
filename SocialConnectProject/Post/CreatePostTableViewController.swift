//
//  CreatePostTableViewController.swift
//  SocialConnectProject
//
//  Created by user259543 on 11/22/24.
//

import UIKit
import FirebaseCore

class CreatePostTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {

    var postReposotory = PostRepository()
    @IBOutlet weak var userFullName: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var postSelectImage: UIImageView!
    @IBOutlet weak var userUserName: UILabel!
    var userFromHomePage: User!
    @IBOutlet weak var postContent: UITextView!
    @IBOutlet weak var selectImageButton: UIButton! // Add an IBOutlet for the select image button
    var postImageUrl: URL?
    override func viewDidLoad() {
        super.viewDidLoad()

        if let user = userFromHomePage {
            
            self.updateUserProfile(user)
        } else {
            self.showAlertMessage("Error", "User data could not be fetched.")
        }
        
    }
    
    
    lazy var onComplete: () -> Void = { [weak self] in
        guard let self = self else { return }
        
       
            
            self.navigationController?.popViewController(animated: true)
        
    }

    // Function to update the UI with the fetched user data
        func updateUserProfile(_ user: User) {
            
            userFullName.text = "\(user.firstname) \(user.lastname)"
            userUserName.text = user.username
            
            // Handle user image this is for fire store datastore
//                   if !user.photo.isEmpty {
//                       let photoURL = user.photo
//                       userImage.loadCircularImageFrom(urlString: photoURL) { image in
//                           // You can use the image if needed
//                       }
//                   } else {
//                       userImage.setPlaceholderImage(for: user.username)
//                   }
            // Handle user image
                if !user.photo.isEmpty {
                    // Assuming 'user.photo' is a file path or URL
                    if let photoURL = URL(string: user.photo) {
                        userImage.loadCircularImageFromFileURL(fileURL: photoURL)
                    }
                } else {
                    userImage.setPlaceholderImage(for: user.username)
                }
        }
    @IBAction func postButton(_ sender: Any) {
        guard let contentText = postContent.text else {
                    showAlertMessage("Validation", "Content cannot be empty")
                    return
                }
        let newPost = Post()
        newPost.likes = "0"
        newPost.commentsCount = "0"
        newPost.userId = userFromHomePage.userAuthId
        newPost.createdAt = Timestamp(date: Date())
        newPost.updatedAt = Timestamp(date: Date())
        newPost.content = contentText
        newPost.imageURL = postImageUrl?.absoluteString ?? userFromHomePage.photo
        
        postReposotory.savePost(newPost) { error in
            if let error = error{
                self.showAlertMessage("Error", "\(error)")
                return
            }
            self.showAlertMessage("Success", "Your Post has been Sucessfully posted!", self.onComplete)
            
                        
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
                
                // Make sure the "Select Image" button is visible after image selection
                        selectImageButton.isHidden = false  // Set the button visible
            }
            
            picker.dismiss(animated: true, completion: nil)
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true, completion: nil)
        }

}
    
     


    


