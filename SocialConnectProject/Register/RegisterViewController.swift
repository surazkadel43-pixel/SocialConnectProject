//
//  RegisterViewController.swift
//  SocialConnectProject
//
//  Created by user259543 on 10/26/24.
//

import UIKit
import FirebaseCore
import FirebaseAuth

class RegisterViewController: UIViewController {

    
    
    
    @IBOutlet weak var userUsername: UITextField!
    
    @IBOutlet weak var userEmail: UITextField!
    
    @IBOutlet weak var userPassword: UITextField!
    
    @IBOutlet weak var passwordConfirmation: UITextField!
    
    var userRegister: User!
    var repository: Repositories! = Repositories()
    
    var allUser = [User]()
    var foundUser: Bool = false;
    override func viewDidLoad() {
        super.viewDidLoad()
        repository.getAllUser("User") { userCollection in
            self.allUser = userCollection
      
        }
    }
    

    
    
    @IBAction func buttonRegister(_ sender: Any) {
        
        guard !userUsername.text.isBlank else{
            showAlertMessage("Validation", "Username is mandatory")
            return
        }
        guard userEmail.text.isEmailValid else{
            showAlertMessage("Validation", "InValid Email Format")
            return
        }
        guard !userPassword.text.isBlank else{
            showAlertMessage("Validation", "Password is mandatory")
            return
        }
        guard !passwordConfirmation.text.isBlank else{
            showAlertMessage("Validation", "Confirm Password Does not Match with Enterd Password")
            return
        }
        guard let username = userUsername.text,
        let email = userEmail.text,
        let password = userPassword.text,
        let passwordConfirmation = passwordConfirmation.text,
        password == passwordConfirmation
        else{
            showAlertMessage("Validation", "Confirm Password Does not Match with Enterd Password")
            return
        }
        repository.userFound("User", username){ userfound in
           // self.foundUser = userfound;
            guard !userfound else{
                self.showAlertMessage("Error", "Username\(username) Has already been taken Please choose another username")
                return
            }
            
                
                let registerUser : () ->Void = {
                    // get user Details
                    let userAuthId = Auth.auth().currentUser?.uid
                    print("signed up id \(userAuthId ?? "NIL")")
                    
                    // create a userObject
                    
                    self.userRegister = User(username: username, email: email, password: password,userAuthId: userAuthId!, registered: Timestamp(date: Date()) )
                    if self.repository.registerUser(self.userRegister, userAuthId ?? ""){
                        
                        print("User added \(self.userRegister.email)")
                    }
                                        
                    let LoginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                    LoginVC.userFromRegister = self.userRegister
                    self.navigationController?.popViewController(animated: true)
                }
                
                // lets authenticate the user
                Auth.auth().createUser(withEmail: email, password: password){
                    authResult, error in
                    
                    guard error == nil else{
                        
                        self.showAlertMessage("We could not create the account", "\(error!.localizedDescription)")
                        return
                    }
                    // at this point in the code the userwas created in Firebase Auth
                    Auth.auth().currentUser?.sendEmailVerification{
                        error in
                        if let error = error {
                            // there is an error
                            self.showAlertMessage("Error", "\(error)")
                        }
                        self.showAlertMessage("Email Confirmation Sent", "A confirmation email has been sent to your email, please confirm the email before you login", registerUser)
                    }
                }
            
            
        }
        
   
    }
    
    @IBAction func buttonSignIn(_ sender: Any) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination.isKind(of: LoginViewController.self){
            let LoginVC = segue.destination as! LoginViewController
            LoginVC.userFromRegister = self.userRegister
            
    
        }
    }
    
    @IBAction func unwindToRegisterVC(_ unwindSegue: UIStoryboardSegue) {
        let sourceViewController = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
    }
    
    

}
