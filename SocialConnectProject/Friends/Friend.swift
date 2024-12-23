//
//  Contact.swift
//  SocialConnectProject
//
//  Created by user259543 on 10/26/24.
//

import Foundation
import FirebaseFirestore

class Friend{
    
    var username: String
    var email: String
    var password: String
    var firstname: String
    var lastname: String
    var DOB: Timestamp!
    var phone: String
    var photo: String
    var registered : Timestamp!
    
    init(username: String, email: String, password: String, firstname: String, lastname: String, DOB: Timestamp!, phone: String, photo: String, registered: Timestamp? = nil) {
        self.username = username
        self.email = email
        self.password = password
        self.firstname = firstname
        self.lastname = lastname
        self.DOB = DOB
        self.phone = phone
        self.photo = photo
        self.registered = registered
    }
    
    init(username: String, email: String, password: String, firstname: String, lastname: String, phone: String, photo: String) {
        self.username = username
        self.email = email
        self.password = password
        self.firstname = firstname
        self.lastname = lastname
        self.phone = phone
        self.photo = photo
       
    }
    convenience init(id: String , dictionary: [String : Any]){
        self.init(username: dictionary["username"] as! String,
                  email: dictionary["email"] as! String,
                  password: dictionary["password"] as! String,
                  firstname: dictionary["firstname"] as! String,
                  lastname: dictionary["lastname"] as! String,
                  DOB: dictionary["DOB"] as? Timestamp,
                  phone: dictionary["phone"] as! String,
                  photo: dictionary["photo"] as! String,
                  registered: dictionary["registered"] as? Timestamp)
    }
    
}
