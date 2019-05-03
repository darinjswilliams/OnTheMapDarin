//
//  FindViewController.swift
//  OnTheMapDarin
//
//  Created by Darin Williams on 4/29/19.
//  Copyright © 2019 dwilliams. All rights reserved.
//

import UIKit
import MapKit

class FindViewController: UIViewController, UITextFieldDelegate {

    
    
    @IBOutlet weak var studentLocation: UITextField!
    
    @IBOutlet weak var mediaURL: UITextField!
    
    //Initialize variables to get rid of warning
    var addressLatitude: Double = 0.0
    var addressLongitude: Double = 0.0
    var mapItems: [MKMapItem]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    


    @IBAction func findStudentLocationButton(_ sender: Any) {
       
        guard let _ = studentLocation.text?.isEmpty else {
              showFailure(message: "Not a valid location")
            
            return
        }
        
        findCoordinates(validAddress: studentLocation.text!, completionHandler: handleCoordinates(response:error:))
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        
        //MAR
        let returnToMainController =  self.storyboard?.instantiateViewController(withIdentifier: "HomeTabBarController") as! UITabBarController
        self.present(returnToMainController, animated: true, completion: nil)
    }
    
    
    func findCoordinates(validAddress: String, completionHandler: @escaping(CLLocationCoordinate2D,
        NSError?) -> Void ) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(validAddress) { (placemarks, error) in
            if error == nil {
                if let placemark = placemarks?[0] {
                    let location = placemark.location!
                    
                    completionHandler(location.coordinate, nil)
                    return
                }
            }
            
           //Use KCLLocationCoordinate2DInvalid Use this constant when you want to indicate that a coordinate is invalid.
            completionHandler(kCLLocationCoordinate2DInvalid, error as NSError?)
        }
    }
    
    func handleCoordinates(response: CLLocationCoordinate2D, error: NSError? ){
        if response.latitude == -180 || response.longitude == -180{
            showFailure(message: "Please enter a valid address")
        } else {
            addressLongitude = response.longitude
            addressLatitude = response.latitude
            
            performSegue(withIdentifier: "postAddressOnMap", sender: nil)
        }
    }
    
    
    //prepare vars to pass to contorller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as!  PostViewController
    
        guard let controllerViewDest = segue.destination as? PostViewController else {
            showFailure(message: "Please recheck address")
            return
        }
        
        controllerViewDest.postLatitude = addressLatitude
        controllerViewDest.postLongitude = addressLongitude
        controllerViewDest.postMediaURL = mediaURL.text ?? ""
        
    }
    
}
