//
//  UserModel.swift
//  fbTestApp
//
//  Created by Admin on 30.04.2020.
//  Copyright © 2020 com.orestkashchiy. All rights reserved.
//

import Foundation
import RealmSwift

class User : Object {
    @objc dynamic var email : String? = ""
    @objc dynamic var long: Double = 0.0
    @objc dynamic var lat: Double = 0.0
    
//    let long = RealmOptional<Double>()
//    let lat = RealmOptional<Double>()
}

//extension User {
//    func writeToRealm() {
//        try! uiRealm.write {
//            uiRealm.add(self)
//        }
//    }
//}
