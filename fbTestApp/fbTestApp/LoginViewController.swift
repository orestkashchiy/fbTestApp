//
//  ViewController.swift
//  fbTestApp
//
//  Created by Admin on 28.02.2020.
//  Copyright © 2020 com.orestkashchiy. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FacebookCore
import FacebookLogin
import RealmSwift


class LoginViewController: UIViewController {

    var userEmail:String = ""
    var userFirstName:String=""
    var userLastName:String=""
    
    
    override func viewDidLoad() {
      super.viewDidLoad()
      // Do any additional setup after loading the view.
    }
    
    func saveUser() {
       var realm = try! Realm()
        let usr = User()
        print(self.userEmail)
        usr.email = self.userEmail
        //only for test
        usr.long = 45.166
        usr.lat = 33.556

    }
    
    @IBAction func loginBtnClicked(_ sender: Any) {
        if let token = AccessToken.current {
            self.getFBUserData()
            self.printProperty()
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
                    mvc.userEmail = self.userEmail
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
                print("Facebook graph request successful! VC1")

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
                    print(self.userEmail)
                    print(self.userLastName)
                }
                
            }
        }
        self.saveUser()
    }
          

    func printProperty () {
        print("Method printProperty")
        print(self.userEmail)
        print(self.userFirstName)
        print(self.userLastName)
    }
    
    
    func getFBUserData() {
        //if function get facebook user details
        if((AccessToken.current) != nil){
            
            GraphRequest(graphPath: "me", parameters: ["fields": "id, name, picture.type(large), email, gender"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    
                    let dict = result as! [String : AnyObject]
                    print(result!)
                    print(dict)
                    let picutreDic = dict as NSDictionary
                    let tmpURL1 = picutreDic.object(forKey: "picture") as! NSDictionary
                    let tmpURL2 = tmpURL1.object(forKey: "data") as! NSDictionary
                    let finalURL = tmpURL2.object(forKey: "url") as! String
                    
                    let nameOfUser = picutreDic.object(forKey: "name") as! String
                   // self.lblUserName.text = nameOfUser
                    
                    var tmpEmailAdd = ""
                    if let emailAddress = picutreDic.object(forKey: "email") {
                        tmpEmailAdd = emailAddress as! String
                        self.userEmail = tmpEmailAdd
                        
                    }
                    else {
                        var usrName = nameOfUser
                        usrName = usrName.replacingOccurrences(of: " ", with: "")
                        tmpEmailAdd = usrName+"@facebook.com"
                    }
                    
                   
                }
                
                print(error?.localizedDescription as Any)
            })
        }
    }
    
}


