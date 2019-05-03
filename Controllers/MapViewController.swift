//
//  MapViewController.swift
//  OnTheMapDarin
//
//  Created by Darin Williams on 4/28/19.
//  Copyright © 2019 dwilliams. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    
    
    @IBOutlet weak var mapView: MKMapView!
    var mapAnnotations = [MKAnnotation]()
    var studentInformation:[StudentLocations] = [StudentLocations]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
         self.getStudentLocations()
        // Do any additional setup after loading the view.
    }
    
    
    @objc func getStudentLocations() {
        
        OnTheMapRestClient.requestSignedInUserInfo(completionHandler: handleGetSingleStudentInfo(studentInfo:error:))
         ParseClient.requestLimitedStudents(completion: handleGetStudentLocation(studentLocation:error:))
      }

    func handleGetSingleStudentInfo(studentInfo:StudentInfo?, error:Error?) {
        guard let studentInfo = studentInfo else {
            showFailure(message: "Unable to Download Your Student Location")
            print(error!)
            return
        }
        print("handleGetSingleStudentInfo: \(studentInfo)")
        
    }
    
    @IBAction func StudentIfoData(_ sender: Any) {
    }
    
    
    
    func handleGetStudentLocation(studentLocation:[StudentLocations]?, error:Error?) {
        guard let studentLocation = studentLocation else {
            showFailure(message: "Unable to Download Student Locations")
            print(error!)
            return
        }
//        createMapAnnotation(studentInfos:studentInfos)
        print("handelGetStudentLocation \(studentLocation)")
        updateMapWithStudentLocations(studentLocations: studentLocation)
    }
    
    
    func updateMapWithStudentLocations(studentLocations:[StudentLocations]){
        
        print("udpateMapwithStudents\(studentLocations.count)")
        //           self.mapView.removeAnnotations(mapView.annotations)
        
        for student in studentLocations {
            print("Inside for loop with studnet \(student)")
            let lat = CLLocationDegrees(student.latitude ?? 0)
            let long = CLLocationDegrees(student.longitude ?? 0)
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = student.studentFullName
            annotation.subtitle = student.studentUrl
            
            mapAnnotations.append(annotation)
        }
        
        self.mapView.addAnnotations(mapAnnotations)
        
    }
    
    // each pin's rendering
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationId)
            pinView?.canShowCallout = true
            pinView?.pinTintColor = .red
            pinView?.rightCalloutAccessoryView = UIButton(type:.detailDisclosure)
        } else {
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if (control == view.rightCalloutAccessoryView) {
            let app = UIApplication.shared
            if let url = view.annotation?.subtitle! {
                guard !url.isEmpty else {
                    print("NOT VALID URL")
                    return
                }
                DispatchQueue.main.async {
               
                    app.open(URL(string: url)!, options: [:], completionHandler:self.handleURLResponse(success:))
            
            }
        }
      }
    }
    
    func handleURLResponse(success:Bool?){
        guard let success = success else {
            print("failute invalid url")
            return
        }
        
        print("Valid URL")
    }
    
    @IBAction func addStudentLocation(_ sender: Any) {
        
        performSegue(withIdentifier: "findlocationfromMapView", sender: nil)
    }
    
    
    @IBAction func refreshStudent(_ sender: Any) {
        self.getStudentLocations()
    }
    
    @IBAction func logOutAndDeleteSession(_ sender: UIBarButtonItem) {
        
        OnTheMapRestClient.taskForDelete {
        }
        DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
        }
    }


}
