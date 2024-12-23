//
//  LoginViewController.swift
//  SocialConnectProject
//
//  Created by user259543 on 10/26/24.
//

import UIKit
import FirebaseAuth
class LoginViewController: UIViewController {

    
    
    @IBOutlet weak var loginUsername: UITextField!
    
    @IBOutlet weak var loginPassword: UITextField!
    let repostory = Repositories()
    var userFromRegister: User!
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTextFields();
        configureTapGesture();
        
        //loginUsername.text(in: userFromRegister.email as! UITextRange)
        // Do any additional setup after loading the view.
    }
    private func loadDataFromRegister(){
       
        guard let email = userFromRegister?.email else{
            return
        }
        
        loginUsername.text = "\(email)"
        if let password = userFromRegister?.password{
            loginPassword.text = "\(password)"
            print("\(self.userFromRegister.email)")
        }
        
    }
    private func configureTextFields(){
        loginUsername.delegate = self;
        loginPassword.delegate = self;
    }
    private func configureTapGesture(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.handelTap ) )
        view.addGestureRecognizer(tapGesture)
                                                
    }
    
    
    @IBAction func forgettenPasswordButton(_ sender: Any) {
        //self.navigationController?.popViewController( animated: true)
    }
    
    @IBAction func buttonLogin(_ sender: Any) {
        view.endEditing(true)
        loadDataFromRegister();
        guard loginUsername.text.isEmailValid else{
            showAlertMessage("Validation", "InValid Email Format")
            return
        }
        guard !loginPassword.text.isBlank else{
            showAlertMessage("Validation", "Password is mandatory")
            return
        }
        
        var username: String! = loginUsername.text
        let password: String! = loginPassword.text
        
        repostory.validateUser("User", username, password) { (foundUser, userEmail) in
            guard foundUser else{
                self.showAlertMessage("Incorrect username and Password", "Please Enter your password and email again")
                return
            }
            //
            Auth.auth().signIn(withEmail: userEmail, password: password){ AuthDataResult, error in
                guard  error == nil else{
                    self.showAlertMessage("Failed to Login", "\(error!.localizedDescription)")
                    return
                }
                // verify the email is valid
                guard let authUser =  Auth.auth().currentUser, authUser.isEmailVerified else{
                    self.showAlertMessage("Pending email Vertification", "we have sent you an email to your to verify you account, please folloe the instruction")
                    return
                }
                self.repostory.setUserOnline()
                // let it pass to the next scence
                self.showAlertMessage("You are in ", ":-)")
                // If login is successful, check if user details are filled
                self.repostory.checkUserDetails { isFilled in
                    
                    if isFilled {
                        
                        // If details are filled, go to HomeViewController
                        self.showAlertMessage("You are in", ":-)")
                        if let homeVC = self.storyboard?.instantiateViewController(identifier: "HomeViewController") as? UITabBarController {
                            self.view.window?.rootViewController = homeVC
                            self.view.window?.makeKeyAndVisible()
                        }
                    } else {
                        // If details are not filled, go to SaveDetailsTableViewController
                        if let saveDetailsVC = self.storyboard?.instantiateViewController(identifier: "SaveDetailsController") as? SaveDetailsTableViewController {
                            saveDetailsVC.usernameFromLogin = username
                            self.view.window?.rootViewController = saveDetailsVC
                            self.view.window?.makeKeyAndVisible()
                        }
                    }
                }
                
                
            }
            
            
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination.isKind(of: RegisterViewController.self){
            let RegisterVC = segue.destination as! RegisterViewController
            //LoginVC.surajStudent = self.surajStudent
        }
    }
    
    @IBAction func unwindToLoginVC(_ unwindSegue: UIStoryboardSegue) {
        let sourceViewController = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
    }

}


