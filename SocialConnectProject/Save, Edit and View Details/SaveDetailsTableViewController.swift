//
//  SaveDetailsTableViewController.swift
//  SocialConnectProject
//
//  Created by user259543 on 11/22/24.
//

import UIKit
import FirebaseAuth
import FirebaseCore
class SaveDetailsTableViewController: UITableViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    
    var repository: Repositories! = Repositories()
    
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userFirstName: UITextField!
    
    @IBOutlet weak var userLastName: UITextField!
    
    
    @IBOutlet weak var userPhoneNumber: UITextField!
    @IBOutlet weak var userGender: UITextField!
    @IBOutlet weak var userAge: UITextField!
    @IBOutlet weak var selectImageButton: UIButton! // Add an IBOutlet for the select image button
    var usernameFromLogin: String!
    var userPhotoURL: URL!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Check if usernameFromLogin is available
        if let username = usernameFromLogin, !username.isEmpty {
            // Set the placeholder image using the extension method
            userImage.setPlaceholderImage(for: username)
            
            // Check if the placeholder image exists
            if let placeholderImage = userImage.image {
                // Convert the placeholder image to a file URL
                if let fileURL = userImage.imageToFileURL(image: placeholderImage, username: username) {
                    // Save the file URL (as a string) to the user object
                    userPhotoURL = fileURL
                } else {
                    self.showAlertMessage("Error", "Failed to generate file URL for placeholder image.")
                    print("Failed to generate file URL for placeholder image.")
                }
            } else {
                self.showAlertMessage("Error", "Placeholder image is not set.")
                print("Placeholder image is not set.")
            }
        }
    }
    
    @IBAction func buttonSkip(_ sender: Any) {
        let HomeViewController = self.storyboard?.instantiateViewController(identifier: "HomeViewController") as? UITabBarController
        
        self.view.window?.rootViewController = HomeViewController
        self.view.window?.makeKeyAndVisible();
    }
    // MARK: - Table view data source
    
    
    
    @IBAction func buttonSave(_ sender: Any) {
        
        // Get the userAuthId (UID) of the current user
        guard let userAuthId = Auth.auth().currentUser?.uid else {
            print("No user is signed in.")
            return
        }
        // Validate the fields before creating the User object
        guard let firstName = userFirstName.text, !userFirstName.text.isBlank else {
            showAlertMessage("Validation", "First name is mandatory")
            return
        }
        
        guard let lastName = userLastName.text, !userLastName.text.isBlank else {
            showAlertMessage("Validation", "Last name is mandatory")
            return
        }
        
        // Validate the image in UIImageView
        guard let userProfileImage = userImage.image, userProfileImage.size.width > 0, userProfileImage.size.height > 0 else {
            showAlertMessage("Validation", "User image is mandatory")
            return
        }
        
        guard let phoneNumber = userPhoneNumber.text, !userPhoneNumber.text.isBlank else {
            showAlertMessage("Validation", "Phone number is mandatory")
            return
        }
        
        guard let gender = userGender.text, !userGender.text.isBlank else {
            showAlertMessage("Validation", "Gender is mandatory")
            return
        }
        
        guard let ageText = userAge.text, !userAge.text.isBlank else {
            showAlertMessage("Validation", "Age is mandatory")
            return
        }
        // Assuming age needs to be an integer, you can convert it to an Int if needed
        guard let age = Int(ageText), age > 0 else {
            showAlertMessage("Validation", "Invalid age entered")
            return
        }
        // Now, create a User object with the validated data
        var user: User = User(
            username: usernameFromLogin,
            email: "",
            password: "",
            firstname: firstName,
            lastname: lastName,
            DOB: ageText,  // Assuming DOB is stored as age for now
            phone: phoneNumber,
            photo: userPhotoURL.absoluteString,  // Set this if you have a photo field, or leave it empty
            gender: gender,
            userAuthId: "",
            registered: nil,
            isOnline: true
            
        )
        
         //copy and paste the entire
         //copy and paste the entire self.repository.updateUserDetails(user)
                                self.repository.updateUserDetails(user) { success in
                                    if success {
                                        self.showAlertMessage("Success", "User details updated successfully!")
                                        // 1 second delay
                                        if let homeVC = self.storyboard?.instantiateViewController(identifier: "HomeViewController") as? UITabBarController {
        
                                            // Set HomeViewController as the root view controller
                                            self.view.window?.rootViewController = homeVC
                                            self.view.window?.makeKeyAndVisible()
                                        }
                                    }
                                    else {
                                        self.showAlertMessage("Error", "Failed to save user details.")
                                    }
        
                                }
        
            
//            repository.uploadImage(image: userProfileImage) { imageURL, success in
//                if success {
//                    self.showAlertMessage("Image URL", imageURL)
//                } else {
//                    self.showAlertMessage("Error", "Failed to upload image")
//                }
//            }
        
//        // Save user details with image
//           repository.saveUserDetailsWithImage(user: user, userImage: userProfileImage) { success, user in
//                    if success {
//        
//                        // copy and paste the entire self.repository.updateUserDetails(user)
//                        self.repository.updateUserDetails(user) { success in
//                            if success {
//                                self.showAlertMessage("Success", "User details updated successfully!")
//                                // 1 second delay
//                                if let homeVC = self.storyboard?.instantiateViewController(identifier: "HomeViewController") as? UITabBarController {
//                                    
//                                    // Set HomeViewController as the root view controller
//                                    self.view.window?.rootViewController = homeVC
//                                    self.view.window?.makeKeyAndVisible()
//                                }
//                            }
//                            else {
//                                self.showAlertMessage("Error", "Failed to save user details.")
//                            }
//                            
//                        }
//                    }
//        
//                        else {
//                                self.showAlertMessage("Error", "Failed to save Image .")
//                            }
//                        }
    
    
            
        }
            
            
            
            @IBAction func chooseImageButton(_ sender: Any) {
                
                let vc = UIImagePickerController()
                vc.sourceType = .photoLibrary
                vc.delegate = self
                vc.allowsEditing = true
                self.present(vc, animated: true)
            }
            
            func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
                
                
                if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage{
                    self.userImage.image = image
                    self.userPhotoURL = userImage.imageToFileURL(image: image, username: usernameFromLogin)
                    
                    // Make sure the "Select Image" button is visible after image selection
                            selectImageButton.isHidden = false  // Set the button visible
                }
                
                //userProfileImage = imageData;
                
                
                // upload image data
                // get download url
                // save download url to userdefaults
                
                
                picker.dismiss(animated: true, completion: nil)
            }
            func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
                picker.dismiss(animated: true, completion: nil)
            }
        
}
