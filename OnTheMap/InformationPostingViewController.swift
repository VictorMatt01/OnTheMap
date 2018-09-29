//
//  InformationPostingViewController.swift
//  OnTheMap
//
//  Created by Victor Matthijs on 28/07/2018.
//  Copyright © 2018 Victor Matthijs. All rights reserved.
//

import UIKit
import MapKit

class InformationPostingViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var CancelButton: UIBarButtonItem!
    @IBOutlet weak var LocationTextField: UITextField!
    @IBOutlet weak var LinkTextField: UITextField!
    @IBOutlet weak var LoactionMap: MKMapView!
    @IBOutlet weak var FinishButton: UIButton!
    @IBOutlet weak var FindLocationButton: UIButton!
    @IBOutlet weak var ActivityIndicator: UIActivityIndicatorView!
    
    let regionRadius: CLLocationDistance = 4000
    lazy var geocoder = CLGeocoder()
    let object = UIApplication.shared.delegate as! AppDelegate
    let model = Model.init()
    
    var studentLatitude:Double = 0.0
    var studentLongtitude:Double = 0.0
    var studentPlace:String = ""
    var studentLink:String = ""
    
    var isBottom = false
    
    override func viewDidLoad() {
        LoactionMap.isHidden = true
        FinishButton.isHidden = true
        ActivityIndicator.isHidden = true
        LocationTextField.delegate = self
        LinkTextField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.placeholder = ""
        if(textField === LinkTextField){
            if UIDevice.current.orientation.isLandscape {
                isBottom = true
            }
        } else {
            isBottom = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        if(isBottom){
            view.frame.origin.y -= 50
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification){
        view.frame.origin.y = 0
    }
    
    
    @IBAction func CancelButtonClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func FindNewLocationClicked(_ sender: Any) {
        if(LocationTextField.text?.isEmpty ?? true){
            showAlertMessage(messageType: "Error", messageText: "Location textfield is empty!")
        }else if(LinkTextField.text?.isEmpty ?? true){
            showAlertMessage(messageType: "Error", messageText: "Link textfield is empty!")
        }else{
            self.ActivityIndicator.isHidden = false
            self.ActivityIndicator.startAnimating()
            
            //when the two textfields are correct then we start to forward geocode the location
            studentPlace = (LocationTextField?.text)!
            studentLink = (LinkTextField?.text)!
            geocoder.geocodeAddressString(studentPlace, completionHandler: { (placemarks, error) in
                self.processResponse(withPlacemarks: placemarks, error: error)
                })
        }
    }
    
    private func processResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) {
        if let error = error {
            ActivityIndicator.stopAnimating()
            showAlertMessage(messageType: "Error", messageText: "Unable to Forward Geocode Address (\(error))")
        } else {
            var location: CLLocation?
            
            if let placemarks = placemarks, placemarks.count > 0 {
                location = placemarks.first?.location
            }
            
            if let location = location {
                //show the map with the right coordinates!
                hideComponents()
                centerMapOnLocation(location: location)
                studentLatitude = location.coordinate.latitude
                studentLongtitude = location.coordinate.longitude
                ActivityIndicator.stopAnimating()
                ActivityIndicator.isHidden = true
            } else {
                showAlertMessage(messageType: "Error", messageText: "No Matching Location Found")
            }
        }
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius, regionRadius)
        LoactionMap.setRegion(coordinateRegion, animated: true)
    }
    
    func hideComponents(){
        LocationTextField.isHidden = true
        LinkTextField.isHidden = true
        FindLocationButton.isHidden = true
        LoactionMap.isHidden = false
        FinishButton.isHidden = false
    }
    
    @IBAction func FinishButtonClicked(_ sender: Any) {
        //first check if the user already has a studentLocation. We can check this with the unique key.
        lookForStudentLocation()
    }
    
    func lookForStudentLocation(){
        model.lookForStudentLocation(sessionKey: object.appSessionInfo.key) { (result, error) in
            if let error = error {
                DispatchQueue.main.async {
                    self.showAlertMessage(messageType: "Error", messageText: (error.localizedDescription))
                }
            }
            if result?.count == 0 {
                let existingLocation = result![0] as! NSDictionary
                let firstName = existingLocation["firstName"] as! String
                let lastName = existingLocation["lastName"] as! String
                self.postNewStudentLocation(firstName: firstName, lastName: lastName)
            }else{
                //show alert wiev and ask user to overwrite other location
                DispatchQueue.main.async {
                    // create the alert
                    let alert = UIAlertController(title: "Warning", message: "Their is already a location on your name, would you like to overwrite it?", preferredStyle: UIAlertControllerStyle.alert)
                    
                    // add the actions (buttons)
                    alert.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.default, handler: { action in
                        let existingLocation = result![0] as! NSDictionary
                        let firstName = existingLocation["firstName"] as! String
                        let lastName = existingLocation["lastName"] as! String
                        let objectId = existingLocation["objectId"] as! String
                        self.updateStudentLocation(objectId: objectId,firstName: firstName, lastName: lastName)
                    }))
                    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { action in
                        self.dismiss(animated: true, completion: nil)
                    }))
                    
                    // show the alert
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func postNewStudentLocation(firstName:String, lastName:String){
        model.postNewStudentLocation(uniqueKey: object.appSessionInfo.key, mapString: studentPlace, mediaURl: studentLink, latitude: studentLatitude, longtitude: studentLongtitude, firstName: firstName, lastName: lastName) { (result, error) in
            if let error = error {
                DispatchQueue.main.async {
                    self.showAlertMessage(messageType: "Error", messageText: (error.localizedDescription))
                }
            }
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
            
        }
    }
    
    func updateStudentLocation(objectId:String, firstName:String, lastName:String){
        model.updateStudentLocation(objectId: objectId, uniqueKey: object.appSessionInfo.key, mapString: studentPlace, mediaURl: studentLink, latitude: studentLatitude, longtitude: studentLongtitude, firstName: firstName, lastName: lastName){ (result, error) in
            if let error = error {
                DispatchQueue.main.async {
                    self.showAlertMessage(messageType: "Error", messageText: (error.localizedDescription))
                }
            }
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
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
