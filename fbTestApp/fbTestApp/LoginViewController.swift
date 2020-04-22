//
//  ViewController.swift
//  fbTestApp
//
//  Created by Admin on 28.02.2020.
//  Copyright © 2020 com.orestkashchiy. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin

class LoginViewController: UIViewController {

    var userEmail:String = ""
    var userFirstName:String=""
    var userLastName:String=""
    
    
    override func viewDidLoad() {
      super.viewDidLoad()
      // Do any additional setup after loading the view.
    }
    
    
    
    @IBAction func loginBtnClicked(_ sender: Any) {
        if let token = AccessToken.current {
            let mvc = self.storyboard?.instantiateViewController(identifier: "MapViewController") as!     MapViewController
            self.present(mvc, animated: true, completion: nil)
        } else {
            let manager = LoginManager()
            manager.logIn(permissions: [.publicProfile, .email], viewController: self) { (result) in
                switch result {
                case .cancelled:
                    print ("user cancelled login")
                    break
                case .failed(let error):
                    print("Login error : \(error.localizedDescription)")
                    break
                case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                    print("access toke is == \(accessToken)")
                    let mvc = self.storyboard?.instantiateViewController(identifier: "MapViewController") as!     MapViewController
                    self.present(mvc, animated: true, completion: nil)
                }
                
            }

        }
    
    }
    
    
    func getUserProfile() {
      let token = AccessToken.current?.tokenString
        let params = ["fields": "first_name, last_name, email"]
        let graphRequest = GraphRequest(graphPath: "me", parameters: params, tokenString: token, version: nil, httpMethod: .get)
        graphRequest.start { (connection, result, error) in

            if let err = error {
                print("Facebook graph request error: \(err)")
            } else {
                print("Facebook graph request successful!")

                guard let json = result as? NSDictionary else { return }
                if let email = json["email"] as? String {
                    self.userEmail = email
                    print(self.userEmail)
                }
                if let firstName = json["first_name"] as? String {
                    self.userFirstName = firstName
                    print(self.userFirstName)
                }
                if let lastName = json["last_name"] as? String {
                    self.userLastName = lastName
                    print(self.userLastName)
                }
                
            }
        }
    }
          

    func printProperty () {
        print(self.userEmail)
        print(self.userFirstName)
        print(self.userLastName)
    }
    
}


