//
//  ResetPasswordViewController.swift
//  SocialConnectProject
//
//  Created by user259543 on 10/31/24.
//

import UIKit
import FirebaseAuth

class ResetPasswordViewController: UIViewController {

    
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    var userResetUser: User!
    var authUserId: String!
    var reposotory = Repositories()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func buttonReset(_ sender: Any) {
        guard !newPassword.text.isBlank else{
            showAlertMessage("Validation", "Password is mandatory")
            return
        }
        guard !confirmPassword.text.isBlank else{
            showAlertMessage("Validation", "Confirm Password Does not Match with Enterd Password")
            return
        }
        guard let newPassword = newPassword.text,
        let confirmPassword = confirmPassword.text,
        newPassword == confirmPassword
        else{
            showAlertMessage("Validation", "Confirm Password Does not Match with Enterd Password")
            return
        }
        
        guard let user = userResetUser else{
            showAlertMessage("Error", "User not found in the daatabase")
            return
        }
        userResetUser.password = confirmPassword
        // Get the userAuthId (UID) of the current user
            guard let userAuthId = Auth.auth().currentUser?.uid else {
                print("No user is signed in.")
                return
            }
        Auth.auth().currentUser?.updatePassword(to: confirmPassword) { error in
            guard  error == nil else{
                self.showAlertMessage("Failed to Update password", "\(error!.localizedDescription)")
                return
            }
            let result = self.reposotory.registerUser(user, userAuthId)
            guard result else{
                self.showAlertMessage("Error", "Operation coulnot not completer. Please try again")
                return
            }
            self.showAlertMessage("Sucessfull", "Password changed")
//                let LoginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
//                       // LoginVC.userFromRegister
//            self.navigationController?.popViewController( animated: true)
                //self.navigationController?.pushViewController(LoginVC, animated: true)
            
        }
        
        
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
