//
//  LocationTableViewController.swift
//  OnTheMap
//
//  Created by Victor Matthijs on 24/07/2018.
//  Copyright © 2018 Victor Matthijs. All rights reserved.
//

import UIKit

class LocationTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var locationTableView: UITableView!
    
    let object = UIApplication.shared.delegate as! AppDelegate
    var model:Model! = nil
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.studentLoactionArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell")!
        
        let studentLocation = model.studentLoactionArray[indexPath.row]
        
        cell.textLabel?.text = studentLocation.firstName + " " + studentLocation.lastName
        cell.detailTextLabel?.text = studentLocation.mediaURL
        cell.imageView?.image = #imageLiteral(resourceName: "LocationIcon")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let studentLocation = model.studentLoactionArray[indexPath.row]
        if(studentLocation.mediaURL.prefix(5) == "https" || studentLocation.mediaURL.prefix(4) == "http"){
            if let url = URL(string: studentLocation.mediaURL){
                UIApplication.shared.open(url, options:[:], completionHandler: nil)
            }
        }else{
            showAlertMessage(messageType: "LinkError", messageText: "Could not open link")
        }
    }
    @IBAction func AddStudentLocation(_ sender: Any) {
        if let tabViewController = self.storyboard?.instantiateViewController(withIdentifier: "InfoPostingView") {
            self.present(tabViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func RefreshButtonClicked(_ sender: Any) {
        model.studentLoactionArray.removeAll()
        model.loadStudentLocations() { (result, error) in
            if result != nil {
                DispatchQueue.main.async {
                    self.model.studentLoactionArray = result!
                    self.locationTableView.reloadData()
                }
            }else {
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
                    self.showAlertMessage(messageType: "Error", messageText: (error?.localizedDescription)!)
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
