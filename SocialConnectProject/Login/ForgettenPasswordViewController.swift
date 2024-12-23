//
//  ForgettenPasswordViewController.swift
//  SocialConnectProject
//
//  Created by user259543 on 10/31/24.
//

import UIKit
import FirebaseAuth

class ForgettenPasswordViewController: UIViewController {

    
    @IBOutlet weak var emailVerify: UITextField!
    var reposotory: Repositories = Repositories()
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    @IBAction func buttonVerifyEmail(_ sender: Any)  {
        
        guard emailVerify.text.isEmailValid else{
            showAlertMessage("Validation", "InValid Email Format")
            return
        }
        
        
        let email: String! = emailVerify.text
      
        reposotory.userFound("User", email ?? "") { result, password, user in
            guard result == 1 else{
                self.showAlertMessage("UnsucessFull Operation", "We Could not find the email in our database")
                return
            }
            
            Auth.auth().signIn(withEmail: email, password: password){ AuthDataResult, error in
                guard  error == nil else{
                    self.showAlertMessage("Failed to Login", "\(error!.localizedDescription)")
                    return
                }
                // verify the email is valid
                guard let authUser =  Auth.auth().currentUser, authUser.isEmailVerified else{
                    self.showAlertMessage("Pending email Vertification", "we have sent you an email to your to verify you account, please folloe the instruction")
                    return
                }
                
                let ResetPasswordVC = self.storyboard?.instantiateViewController(withIdentifier: "ResetPasswordViewController") as! ResetPasswordViewController
                ResetPasswordVC.userResetUser = user;
               
                self.navigationController?.pushViewController(ResetPasswordVC, animated: true)
                // go to ProfileViewController
                //self.navigationController?.popViewController( animated: true)
                
                
                
                
            }
        }
        
    }
    
    

}
