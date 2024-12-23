//
//  ProfileDetailsTableViewController.swift
//  SocialConnectProject
//
//  Created by user259543 on 11/22/24.
//

import UIKit
import FirebaseAuth

class ProfileDetailsTableViewController: UITableViewController {

    var repository: Repositories! = Repositories()
    var userData: User!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userEmail: UILabel!
    
    @IBOutlet weak var userGender: UILabel!
    
    @IBOutlet weak var userAge: UILabel!
    
    @IBOutlet weak var userPhoneNumber: UILabel!
    
    @IBOutlet weak var userFullName: UILabel!
    @IBOutlet weak var userPassword: UILabel!
    @IBOutlet weak var userUsername: UILabel!
    @IBOutlet weak var topUsername: UILabel!
    @IBOutlet weak var userNmaeUser: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Fetch user data when the view loads
               fetchUserData()
        
    }
    // Function to fetch user data asynchronously
    func fetchUserData() {
        repository.getUserData { user in
            DispatchQueue.main.async {
                if let user = user {
                    self.userData = user
                    self.updateUserProfile(user)
                } else {
                    self.showAlertMessage("Error", "User data could not be fetched.")
                }
            }
        }
    }
    // Function to update the UI with the fetched user data
        func updateUserProfile(_ user: User) {
            userEmail.text = user.email
            userGender.text = user.gender
            userPhoneNumber.text = user.phone
            userNmaeUser.text = "@\(user.username)"
            userFullName.text = "\(user.firstname) \(user.lastname)"
            userPassword.text = user.password
            topUsername.text = "@\(user.username)"
            userAge.text = user.DOB
            
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

    
        
    @IBAction func unwindToProfileVC(_ unwindSegue: UIStoryboardSegue) {
        let sourceViewController = unwindSegue.source
        // Use data from the view controller that initiated the unwind segue
        print("Unwound to LoginVC from \(sourceViewController)")
        
        // You can add any logic here, for example, updating the UI or saving data
    }
        
    
    @IBAction func editProfileButton(_ sender: Any) {
        // Get the storyboard and instantiate the EditProfileViewController
            if let editProfileVC = storyboard?.instantiateViewController(withIdentifier: "EditProfileViewController") as? EditProfileTableViewController {
                // Pass the user data to the next view controller
                
                editProfileVC.userFromProfile = userData
                // Push the EditProfileViewController onto the navigation stack
                        self.navigationController?.pushViewController(editProfileVC, animated: true)

            }
    }
    @IBAction func logOutButton(_ sender: Any) {
        guard let userAuthId = Auth.auth().currentUser?.uid else {
              showAlertMessage("Logout Failed", "Could not determine user ID. Please try again.")
              return
          }

          // Set the user as offline in Firestore before logging out
        repository.setUserOffline(userAuthId: userAuthId) { success in
              if success {
                  // Successfully set the user offline, now proceed with sign out
                  do {
                      try Auth.auth().signOut()
                      
                      // Navigate to login screen with navigation controller
                      if let loginVC = self.storyboard?.instantiateViewController(identifier: "LoginViewController") {
                          // Ensure the login screen is wrapped in a navigation controller
                          let navigationController = UINavigationController(rootViewController: loginVC)
                          
                          // Set the new navigation controller as the root view controller
                          self.view.window?.rootViewController = navigationController
                          self.view.window?.makeKeyAndVisible()
                      }
                  } catch {
                      self.showAlertMessage("Logout Failed", "Could not log out. Please try again.")
                  }
              } else {
                  self.showAlertMessage("Logout Failed", "Failed to update user status. Please try again.")
              }
          }
    }
    



   
    

}
