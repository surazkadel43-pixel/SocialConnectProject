//
//  Extension.swift
//  SocialConnectProject
//
//  Created by user259543 on 10/29/24.
//

import Foundation
import UIKit
import FirebaseCore


extension Optional where Wrapped == String{
    
    var isBlank: Bool {
        // if we manage to unwrap it then it means is not nill, else is nill
        guard let notNilString = self else {
            // as it is nill, we considered nil as blank string
            return true
        }
        
        return notNilString.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var isEmailValid: Bool {
        // if we manage to unwrap it then it means is not nill, else is nill
        guard  self.isBlank else {
            // as it is nill, we considered nil as blank string
//            let emailPredicate = NSPredicate(
//                        format: "SELF MATCHES %@", "<regular expression>"
//                    )
//            guard let email = self,emailPredicate.evaluate(with: email) else {
//                return false;
//                    }
            return true;
        }
        //self = self.trimmingCharacters(in: .whitespaces);
        
        return false;
    }
    

    
}

extension UIViewController {
    
    func showAlertMessage(_ errorTitle: String, _ errorMessage: String){
        let alert = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true, completion: nil)
    }
    func showYesNoAlertMessage(
        title: String,
        message: String,
        yesAction: @escaping () -> Void,
        noAction: (() -> Void)? = nil
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Yes button
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            yesAction()
        }))
        
        // No button
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { _ in
            noAction?()
        }))
        
        present(alert, animated: true, completion: nil)
    }
    func showAlertMessage(_ errorTitle: String, _ errorMessage: String,_ onComplete: (() ->Void)?){
        let alert = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        let onCompleteAction: UIAlertAction = UIAlertAction(title: "Ok", style: .default){ action in
            onComplete?()
        }
        //alert.addAction(UIAlertAction(title: "OK", style: .default))
        alert.addAction(onCompleteAction)
        present(alert, animated: true, completion: nil)
        
    }
    @objc func  handelTap() {
        print("Hello tap was called")
        view.endEditing(true)
    }
}
extension UIViewController: @retroactive UITextFieldDelegate {
    
    public func textFieldShouldReturn(_ textField: UITextField) ->Bool {
        textField.resignFirstResponder()
        return true;
    }
}
// Extension for UIImageView
extension UIImageView {

    // Function to load image from a file URL
        func loadImageFromFileURL(fileURL: URL) {
            // Check if the file exists at the URL
            if FileManager.default.fileExists(atPath: fileURL.path) {
                // Load the image from the file URL
                if let image = UIImage(contentsOfFile: fileURL.path) {
                    // Set the image to the UIImageView
                    self.image = image
                } else {
                    print("Error loading image from file")
                }
            } else {
                print("File does not exist at the specified path")
            }
        }
    // Function to load image from a file URL
        func loadCircularImageFromFileURL(fileURL: URL) {
            // Check if the file exists at the URL
            if FileManager.default.fileExists(atPath: fileURL.path) {
                // Load the image from the file URL
                if let image = UIImage(contentsOfFile: fileURL.path) {
                    // Make the image circular
                                    if let circularImage = makeImageCircular(image: image) {
                                        // Set the circular image to the UIImageView
                                        self.image = circularImage
                                    } else {
                                        print("Error making image circular")
                                    }
                } else {
                    print("Error loading image from file")
                }
            } else {
                print("File does not exist at the specified path")
            }
        }
    // Function to load an image from a URL
    func loadCircularImageFrom(urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error loading image: \(error)")
                completion(nil)
                return
            }

            if let data = data, let image = UIImage(data: data) {
                // Apply circular mask to the image
                            let circularImage = self.makeImageCircular(image: image)
                DispatchQueue.main.async {
                    self.image = circularImage
                }
                completion(circularImage)
            } else {
                DispatchQueue.main.async {
                    self.image = nil
                }
                completion(nil)
            }
        }.resume()
    }
    // Function to load an image from a URL
    func loadImageFrom(urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error loading image: \(error)")
                completion(nil)
                return
            }

            if let data = data, let image = UIImage(data: data) {
                
                DispatchQueue.main.async {
                    self.image = image
                }
                completion(image)
            } else {
                DispatchQueue.main.async {
                    self.image = nil
                }
                completion(nil)
            }
        }.resume()
    }
    // Function to apply circular mask to an image
    func makeImageCircular(image: UIImage) -> UIImage? {
        let size = image.size
        let rect = CGRect(origin: .zero, size: size)
        
        // Begin image context
        UIGraphicsBeginImageContextWithOptions(size, false, image.scale)
        
        // Create a circular path
        let path = UIBezierPath(ovalIn: rect)
        
        // Clip to the circular path
        path.addClip()
        
        // Draw the image inside the circular path
        image.draw(in: rect)
        
        // Get the new image from the context
        let circularImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return circularImage
    }
    // Function to create and set a placeholder image for the username
    func setPlaceholderImage(for username: String) {
        let placeholderView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        placeholderView.backgroundColor = .systemPink
        placeholderView.layer.cornerRadius = placeholderView.frame.size.width / 2
        placeholderView.clipsToBounds = true

        let initialLabel = UILabel(frame: placeholderView.bounds)
        initialLabel.textAlignment = .center
        initialLabel.textColor = .white
        initialLabel.font = UIFont.boldSystemFont(ofSize: 40)
        initialLabel.text = String(username.prefix(1)).uppercased()

        placeholderView.addSubview(initialLabel)

        // Convert the placeholderView to an image
        UIGraphicsBeginImageContextWithOptions(placeholderView.bounds.size, false, 0.0)
        placeholderView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let placeholderImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        self.image = placeholderImage
    }
    /// Function to convert UIImage to a file URL
    func imageToFileURL(image: UIImage, username: String) -> URL? {
        // Get the path for the 'Assest' directory in the app's documents directory (or wherever you want to store the images)
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        // Create the 'Assest' directory URL (if it doesn't already exist)
        let assetDirectoryURL = documentsDirectory.appendingPathComponent("Assets")
        
        // Create the directory if it doesn't exist
        if !fileManager.fileExists(atPath: assetDirectoryURL.path) {
            do {
                try fileManager.createDirectory(at: assetDirectoryURL, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Error creating asset directory: \(error)")
                return nil
            }
        }
        
        // Create the file URL using the username as the file name
        let fileURL = assetDirectoryURL.appendingPathComponent("\(username).png")
        
        // Convert the image to PNG data (you can use JPEG if needed, adjust the compression quality accordingly)
        guard let imageData = image.pngData() else {
            print("Error converting image to data")
            return nil
        }
        
        // Write the image data to the file
        do {
            try imageData.write(to: fileURL)
            return fileURL
        } catch {
            print("Error saving image to file: \(error)")
            return nil
        }
    }


    // Function to convert the placeholder image to a URL
    func convertPlaceholderToURL(username: String) -> URL? {
        // Generate the placeholder image based on the username
        self.setPlaceholderImage(for: username)
        
        // Convert the generated placeholder image to a file URL
        if let image = self.image {
            return imageToFileURL(image: image, username: username)
        }
        
        return nil
    }
}



extension Date {
    static func formattedSocialDate(from timestamp: Timestamp?) -> String {
        guard let timestamp = timestamp else {
            return "N/A"
        }
        
        let date = timestamp.dateValue()
        let calendar = Calendar.current
        let formatter = DateFormatter()
        
        if calendar.isDateInToday(date) {
            formatter.dateStyle = .none
            formatter.timeStyle = .short // e.g., "4:30 PM"
            return formatter.string(from: date)
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else if let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())),
                  date >= startOfWeek {
            formatter.dateFormat = "EEEE" // e.g., "Monday"
            return formatter.string(from: date)
        } else if calendar.component(.year, from: date) == calendar.component(.year, from: Date()) {
            formatter.dateFormat = "MMM d" // e.g., "Mar 15"
            return formatter.string(from: date)
        } else {
            formatter.dateFormat = "MMM d, yyyy" // e.g., "Mar 15, 2022"
            return formatter.string(from: date)
        }
    }
}


