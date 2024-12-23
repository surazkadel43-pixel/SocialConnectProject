import Foundation
import FirebaseFirestore

class User {
    var username: String
    var email: String
    var password: String
    var firstname: String
    var lastname: String
    var DOB: String
    var phone: String
    var photo: String
    var gender: String
    var registered: Timestamp!
    var userAuthId: String
    var isOnline: Bool
    var followersCount: Int  // New property added
    var followingCount: Int  // New property added
    
    init(username: String, email: String, password: String, firstname: String, lastname: String, DOB: String, phone: String, photo: String, gender: String, userAuthId: String, registered: Timestamp? = nil, isOnline: Bool, followersCount: Int = 0, followingCount: Int = 0) {
        self.username = username
        self.email = email
        self.password = password
        self.firstname = firstname
        self.lastname = lastname
        self.DOB = DOB
        self.phone = phone
        self.photo = photo
        self.gender = gender
        self.userAuthId = userAuthId
        self.registered = registered
        self.isOnline = isOnline
        self.followersCount = followersCount
        self.followingCount = followingCount
    }
    
    convenience init(username: String, email: String, password: String, userAuthId: String, registered: Timestamp!) {
        self.init(
            username: username,
            email: email,
            password: password,
            firstname: "",
            lastname: "",
            DOB: "",
            phone: "",
            photo: "",
            gender: "",
            userAuthId: userAuthId,
            registered: registered ?? Timestamp(date: Date()),
            isOnline: false,
            followersCount: 0,
            followingCount: 0
        )
    }
    
    convenience init(dictionary: [String: Any]) {
        self.init(
            username: dictionary["Username"] as? String ?? "",
            email: dictionary["Email"] as? String ?? "",
            password: dictionary["Password"] as? String ?? "",
            firstname: dictionary["firstname"] as? String ?? "",
            lastname: dictionary["lastname"] as? String ?? "",
            DOB: dictionary["DOB"] as? String ?? "",
            phone: dictionary["phoneNumber"] as? String ?? "",
            photo: dictionary["photo"] as? String ?? "",
            gender: dictionary["gender"] as? String ?? "",
            userAuthId: dictionary["userAuthId"] as? String ?? "",
            registered: dictionary["registered"] as? Timestamp ?? Timestamp(date: Date()),
            isOnline: dictionary["isOnline"] as? Bool ?? false,
            followersCount: dictionary["followersCount"] as? Int ?? 0,
            followingCount: dictionary["followingCount"] as? Int ?? 0
        )
    }
    
    convenience init(_ nil: String) {
        self.init(
            username: "",
            email: "",
            password: "",
            firstname: "",
            lastname: "",
            DOB: "",
            phone: "",
            photo: "",
            gender: "",
            userAuthId: "",
            registered: Timestamp(date: Date()),
            isOnline: false,
            followersCount: 0,
            followingCount: 0
        )
    }
}
