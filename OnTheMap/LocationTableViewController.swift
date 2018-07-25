//
//  LocationTableViewController.swift
//  OnTheMap
//
//  Created by Victor Matthijs on 24/07/2018.
//  Copyright © 2018 Victor Matthijs. All rights reserved.
//

import UIKit

class LocationTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let object = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return object.studentLoactionArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell")!
        
        let studentLocation = object.studentLoactionArray[indexPath.row]
        
        cell.textLabel?.text = studentLocation.firstName + " " + studentLocation.lastName
        cell.detailTextLabel?.text = studentLocation.mediaURL
        cell.imageView?.image = #imageLiteral(resourceName: "LocationIcon")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let studentLocation = object.studentLoactionArray[indexPath.row]
        if(studentLocation.mediaURL.prefix(5) == "https" || studentLocation.mediaURL.prefix(4) == "http"){
            if let url = URL(string: studentLocation.mediaURL){
                UIApplication.shared.open(url, options:[:], completionHandler: nil)
            }
        }else{
            let alert = UIAlertController(title: "LinkError", message: "could not open link", preferredStyle: UIAlertControllerStyle.alert)
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
    
    
    @IBAction func LogoutButtonPressed(_ sender: Any) {
        var request = URLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error…
                return
            }
            let range = Range(5..<data!.count)
            let newData = data?.subdata(in: range) /* subset response data! */
            DispatchQueue.main.sync {
                if let tabViewController = self.storyboard?.instantiateViewController(withIdentifier: "loginView") {
                    self.present(tabViewController, animated: true, completion: nil)
                }
            }
        }
        task.resume()
        
    }
    
}
