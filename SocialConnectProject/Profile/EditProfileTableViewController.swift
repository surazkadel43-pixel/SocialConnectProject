//
//  EditProfileTableViewController.swift
//  SocialConnectProject
//
//  Created by user259543 on 11/22/24.
//

import UIKit
import FirebaseAuth

class EditProfileTableViewController: UITableViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    var repository: Repositories! = Repositories()
    @IBOutlet weak var updateImage: UIImageView!
    
    
    @IBOutlet weak var UserFirstName: UITextField!
    
    @IBOutlet weak var UserLastName: UITextField!
    
    @IBOutlet weak var userUserName: UITextField!
    @IBOutlet weak var userPhoneNumber: UITextField!
    
    @IBOutlet weak var userAge: UITextField!
    @IBOutlet weak var selectImageButton: UIButton! // Add an IBOutlet for the select image button
    @IBOutlet weak var userPassword: UITextField!
    
    @IBOutlet weak var userEmail: UITextField!
    var userFromProfile: User! // Add a variable to hold the user data
    var imageUrl: URL?
    @IBOutlet weak var userGender: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        selectImageButton.isHidden = false
        if let user = userFromProfile {
                    // Use the user data to update UI or perform other tasks
                    print("Received user: \(user)")
            updateUserProfile(user)
                }
        
    }
    // Function to fetch user data asynchronously
        func fetchUserData() {
            repository.getUserData { user in
                
                    if let user = user {
                        self.updateUserProfile(user)
                    } else {
                        self.showAlertMessage("Error","User data could not be fetched.")
                    }
                
            }
        }
    // Populate fields with the user data
        func updateUserProfile(_ user: User) {
            //userEmail.text = user.email
            userPhoneNumber.text = user.phone
            UserFirstName.text = user.firstname
            UserLastName.text = user.lastname
            userPassword.text = user.password
            userUserName.text = user.username
            userAge.text = user.DOB
            userGender.text = user.gender
            
            // Handle user image
                   if !user.photo.isEmpty {
                       let photoURL = user.photo
                       updateImage.loadImageFrom(urlString: photoURL) { image in
                           // You can use the image if needed
                       }
                   } else {
                       updateImage.setPlaceholderImage(for: user.username)
                       // Convert the placeholder image to base64 string using the extension method
                       // Convert the placeholder image to a file URL
                          if let fileURL = updateImage.convertPlaceholderToURL(username: user.username) {
                              // Save the file URL (as a string) to the user object
                              user.photo = fileURL.absoluteString
                          } else {
                              self.showAlertMessage("Error", "Failed to save placeholder image as a URL.")
                              print("Failed to save placeholder image as a URL.")
                          }
                   }
        }
    
    
    
    @IBAction func backButton(_ sender: Any) {
        
    }
    
    @IBAction func buttonSave(_ sender: Any) {
        
        // Get the userAuthId (UID) of the current user
                guard let userAuthId = Auth.auth().currentUser?.uid else {
                    print("No user is signed in.")
                    showAlertMessage("Error", "No user is signed in.")
                    return
                }
                
                
        guard !UserFirstName.text.isBlank else {
                showAlertMessage("Validation", "First name is mandatory")
                return
            }

            // Ensure the last name is not blank
            guard !UserLastName.text.isBlank else {
                showAlertMessage("Validation", "Last name is mandatory")
                return
            }

            // Ensure the username is not blank
            guard !userUserName.text.isBlank else {
                showAlertMessage("Validation", "Username is mandatory")
                return
            }

            // Ensure the phone number is not blank
            guard !userPhoneNumber.text.isBlank else {
                showAlertMessage("Validation", "Phone number is mandatory")
                return
            }

            
            

            // Ensure the password is not blank
            guard !userPassword.text.isBlank else {
                showAlertMessage("Validation", "Password is mandatory")
                return
            }

            // Ensure passwords match (you can also add password confirmation if needed)
            guard !userAge.text.isBlank else {
                showAlertMessage("Validation", "Age is mandatory")
                return
            }
        // Create the User object
            let user = User(
                username: userUserName.text!,
                email: userFromProfile!.email,
                password: userPassword.text!,
                firstname: UserFirstName.text!,
                lastname: UserLastName.text!,
                DOB: userAge.text!,
                phone: userPhoneNumber.text!,
                photo: imageUrl?.absoluteString ?? userFromProfile.photo,
                gender: userGender.text!, // Add gender if needed
                userAuthId: userAuthId,
                registered: nil, // You can set a timestamp here if needed
                isOnline: true
            )
        
        // Save the user details to Firestore
        repository.saveUserDetails(user: user) { success, error in
            if success {
                // If save to Firestore was successful, update the Firebase Auth email and password
                self.repository.updateFirebaseAuthPassword(user: user) { authSuccess, error  in
                    if authSuccess {
                        // go to ProfileViewController
                        self.navigationController?.popViewController( animated: true)
                        // Get the storyboard and instantiate the EditProfileViewController
//                        if let ProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileDetailsTableViewController {
//                            
//                                        self.navigationController?.pushViewController(ProfileVC, animated: true)
//
//                            }
                        self.showAlertMessage("Sucess","Sucessfully profile Updated")
                        
                    } else {
                        self.showAlertMessage("Error","\(error)")
                    }
                }
            } else {
                self.showAlertMessage("Error", "\(error)")
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
                    self.updateImage.image = image
                    self.imageUrl = updateImage.imageToFileURL(image: image, username: userUserName.text!)
                    // Make sure the "Select Image" button is visible after image selection
                            selectImageButton.isHidden = false  // Set the button visible
                }
                
                picker.dismiss(animated: true, completion: nil)
            }
            func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
                picker.dismiss(animated: true, completion: nil)
            }
        


}
