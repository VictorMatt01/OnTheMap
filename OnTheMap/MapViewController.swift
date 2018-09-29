//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Victor Matthijs on 29/07/2018.
//  Copyright © 2018 Victor Matthijs. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var LocationMap: MKMapView!
    
    let object = UIApplication.shared.delegate as! AppDelegate
    var model:Model! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LocationMap.delegate = self
        loadStudentAnnotations()
    }
    
    func loadStudentAnnotations(){
        
        for location in model.studentLoactionArray {
            let anno = MKPointAnnotation()
            anno.title = location.firstName + " " + location.lastName
            anno.subtitle = location.mediaURL
            let CLLCoordType = CLLocationCoordinate2D(latitude: location.latitude as! Double,longitude: location.longitude as! Double);
            anno.coordinate = CLLCoordType
            LocationMap.addAnnotation(anno)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView.canShowCallout = true
        pinView.rightCalloutAccessoryView = UIButton.init(type: UIButtonType.detailDisclosure)
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            var canOpen = false
            
            if let annotation = view.annotation {
                if let canOpenURL = URL(string: annotation.subtitle!!) {
                    canOpen = app.canOpenURL(canOpenURL)
                }
                
                if canOpen {
                    let urlOpen = URL(string: annotation.subtitle as! String)
                    UIApplication.shared.open(urlOpen!, options: [:], completionHandler: nil)
                } else {
                    showAlertMessage(messageType: "Error", messageText: "Could not open link!")
                }
            }
        }
    }
    
    
    
    
    
    @IBAction func AddStudentLocation(_ sender: Any) {
        if let tabViewController = self.storyboard?.instantiateViewController(withIdentifier: "InfoPostingView") {
            self.present(tabViewController, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func RefreshButtonClicked(_ sender: Any) {
        //first we remove the old annotations
        LocationMap.removeAnnotations(LocationMap.annotations)
        //reload the new studentLocations
        //first delete the locations in the array then make the request and update the array
        DispatchQueue.main.async {
            self.model.studentLoactionArray.removeAll()
            self.loadStudentLocations()
        }
    }
    
    func loadStudentLocations(){
        model.loadStudentLocations { (result, error) in
            if let result = result {
                DispatchQueue.main.async {
                    self.model.studentLoactionArray = result
                    self.loadStudentAnnotations()
                }
            } else {
                DispatchQueue.main.async {
                    self.showAlertMessage(messageType: "Error", messageText: (error?.localizedDescription)!)
                }
            }
        }
    }
    
    
    @IBAction func LogoutButtonClicked(_ sender: Any) {
        model.logOutFromUdacity() { (result, error) in
            if result != nil {
                DispatchQueue.main.sync {
                    self.dismiss(animated: true, completion: nil)
                }
            }else {
                DispatchQueue.main.async {
                    self.showAlertMessage(messageType: "Erroe", messageText: (error?.localizedDescription)!)
                }
            }
        }
    }
    
    func showAlertMessage(messageType:String, messageText:String){
        let alert = UIAlertController(title: messageType, message: messageText, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style{
            case .default:
                print("default")
                
            case .cancel:
                print("cancel")
                
            case .destructive:
                print("destructive")
            }}))
        self.present(alert, animated: true, completion: nil)
    }
    
}
