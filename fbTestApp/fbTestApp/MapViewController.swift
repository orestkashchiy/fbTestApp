//
//  MapViewController.swift
//  fbTestApp
//
//  Created by Admin on 02.03.2020.
//  Copyright © 2020 com.orestkashchiy. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin
import CoreLocation
import MapKit
import RealmSwift

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var locationManager = CLLocationManager()
    var myPosition: CLLocation?
    var selectedAnnotation: CLLocationCoordinate2D?
    var userEmail:String = ""
    var userFirstName:String = ""
    var userLastName:String = ""
    var userToAdd = User()
    
    override func viewDidAppear(_ animated: Bool) {
        self.getUserFromRealm()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.saveData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //GET current user data
        self.getFBUserData()
     
        mapView.delegate = self
        setupLocationManager()
        
        let tapRecogniser = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.handleTapRemove(_:)))
        longPress.minimumPressDuration = 0.9
        mapView.addGestureRecognizer(tapRecogniser)
        mapView.addGestureRecognizer(longPress)
    }
    
    //MARK: SetupMap
    func setupLocationManager () {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        mapView.showsUserLocation = true
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        defer {myPosition = locations.last}
        if myPosition == nil {
            // Zoom to user location
            if let userLocation = locations.last {
                let viewRegion = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
                mapView.setRegion(viewRegion, animated: true)
            }
        }

    }
    
    //MARK: dataFromDatabase
    
    func getUserFromRealm() {
        print("getUserFromRealm METHOD")
        let realm = try! Realm()
        var usr = realm.objects(User.self)
        for u in usr {
            var i = 0
            print(u.email)
            
        }
    }
    
    //MARK: GestureMethods
   @objc func handleTap(_ gestureReconizer: UITapGestureRecognizer) {
       //  let vc = LoginViewController()
        print("user emali: \(self.userEmail)")
       // let loginVC = self.storyboard?.instantiateViewController(identifier: "LoginViewController") as!     LoginViewController
           // print(loginVC.userEmail)
        mapView.removeAnnotations(mapView.annotations)
        let location = gestureReconizer.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        self.selectedAnnotation = coordinate
    
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "user annotation"
        mapView.addAnnotation(annotation)
          
                
        
        
    }
           
    @objc func handleTapRemove(_ gestureReconizer: UILongPressGestureRecognizer) {
//        let location = gestureReconizer.location(in: mapView)
//        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
            print ("long tap selected")
//        // remove annotation
//        let annotation = MKPointAnnotation()
//        annotation.coordinate = coordinate
          // mapView.removeAnnotation(selectedAnnotation!)

    }
        
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
       // self.selectedAnnotation = view.annotation!
    }
    
    
    //MARK: facebook logout btn
    
    func logoutFB () {
        if let toket = AccessToken.current {
            AccessToken.current = nil
            let loginVC = self.storyboard?.instantiateViewController(identifier: "LoginViewController") as!     LoginViewController
            self.present(loginVC, animated: true)
        }
    }
    
    func saveData() {
        //for test
        let keyUser = "orest.k@i.ua"
        let realm = try! Realm()
        let object = realm.object(ofType: User.self, forPrimaryKey: keyUser)
        var us = User()
        us.email = self.userEmail
        object?.long = self.selectedAnnotation?.longitude ?? 0.0
        object?.lat = self.selectedAnnotation?.latitude ?? 0.0
        try! realm.write({
            realm.add(object!)
        })
    }
    
    
    func getFBUserData() {
        // if function get facebook user details
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
