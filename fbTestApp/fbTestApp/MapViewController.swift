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

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var locationManager = CLLocationManager()
    var myPosition: CLLocation?
    var selectedAnnotation: MKAnnotation?
    var userEmail:String = ""
    var userFirstName:String = ""
    var userLastName:String = ""
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //GET current user data
        self.getUserProfile()
        
        //setup mapView
        mapView.delegate = self
        setupLocationManager()
        
        let tapRecogniser = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.handleTapRemove(_:)))
        longPress.minimumPressDuration = 0.9
        mapView.addGestureRecognizer(tapRecogniser)
        mapView.addGestureRecognizer(longPress)
    }
    
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
    
    
   @objc func handleTap(_ gestureReconizer: UITapGestureRecognizer) {
   
        let location = gestureReconizer.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
    
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
            mapView.removeAnnotation(selectedAnnotation!)

    }
        
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        self.selectedAnnotation = view.annotation!
    }
    
    
    // facebook logout btn
    
    func logoutFB () {
        if let toket = AccessToken.current {
            AccessToken.current = nil
            let loginVC = self.storyboard?.instantiateViewController(identifier: "LoginViewController") as!     LoginViewController
            self.present(loginVC, animated: true)
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
    
}
