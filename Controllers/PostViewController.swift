//
//  PostViewController.swift
//  OnTheMapDarin
//
//  Created by Darin Williams on 4/29/19.
//  Copyright © 2019 dwilliams. All rights reserved.
//

import UIKit
import MapKit

class PostViewController: UIViewController {

    
    var postLatitude: Double = 0.0,
        postLongitude: Double = 0.0,
        postMediaURL: String = "",
        postNewLocation: String  = ""
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        print(postLongitude)
        print(postLatitude)
        print(postNewLocation)
        print(postMediaURL)
        print(AuthenticationStore.userKey)
        // Do any additional setup after loading the view.
        postPinToMapAnnotation()

    }
    
    
    
    @IBAction func finishToPostBtn(_ sender: Any) {
      postStudentDataWithParse()
        
    }
    
    func postStudentDataWithParse(){
        let studentNewLocation = StudentNewLocation(uniqueKey: AuthenticationStore.userKey, firstName: "Udacity", lastName: "Student", mapString: postNewLocation, mediaURL: postMediaURL, latitude: postLatitude, longitude: postLongitude)
        
        ParseClient.postStudentNewLocation(postInformation: studentNewLocation, completionHandler: handlePostLocationReponse(postStudentLocationResponse:error:))
    }
    
    
    //MARK: THIS IS HOW PINS ARE POSTED TO THE MAP
    func postPinToMapAnnotation() {
        let lat = CLLocationDegrees(postLatitude)
        let long = CLLocationDegrees(postLongitude)
        let cordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        let annotation = MKPointAnnotation()
        annotation.coordinate = cordinate
        annotation.title = "Marker: \(postNewLocation)"
        self.mapView.addAnnotation(annotation)
        let coordinateRegion = MKCoordinateRegion.init(center: annotation.coordinate, latitudinalMeters: 30000, longitudinalMeters: 30000  )
        mapView.setRegion(coordinateRegion, animated: true)
        
    }
    
    
    func handlePostLocationReponse(postStudentLocationResponse:StudentPostLocationResponse?, error:Error?) {
        
        guard let response = postStudentLocationResponse else {
            print(error!)
            let alertVC = UIAlertController(title: "Add New Location", message: error?.localizedDescription, preferredStyle: .alert)
            
            alertVC.addAction(UIAlertAction(title:"OK" , style: UIAlertAction.Style.default, handler: { (action) in
                self.dismiss(animated: true, completion: nil)
            })
            )
            activityIndicator.stopAnimating()
            present(alertVC, animated: true, completion: nil)
            return
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    

}
