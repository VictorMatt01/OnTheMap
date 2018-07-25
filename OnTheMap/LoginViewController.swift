//
//  ViewController.swift
//  OnTheMap
//
//  Created by Victor Matthijs on 20/07/2018.
//  Copyright © 2018 Victor Matthijs. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var LoginButton: UIButton!
    @IBOutlet weak var EmailTextField: UITextField!
    @IBOutlet weak var PasswordTextField: UITextField!
    @IBOutlet weak var SignUpButton: UIButton!
    
    var appDelegate: AppDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func LoginButtonPressed(_ sender: UIButton) {
        //check if email and/or password aren't empty
        if(EmailTextField.text?.isEmpty ?? true){
            showAlertMessage(messageType: "Email", messageText: "You must insert an email!")
        } else if(PasswordTextField.text?.isEmpty ?? true){
            showAlertMessage(messageType: "Password", messageText: "You must insert a password!")
        }else{
            let email:String = EmailTextField.text!
            let password:String = PasswordTextField.text!
            loginToUdacity(email: email, password: password)
        }
        
    }
    
    func loginToUdacity(email:String, password:String){
        var request = URLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}".data(using: .utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error: show the type of error to the user
                return
            }
            let range = Range(5..<data!.count)
            let newData = data?.subdata(in: range) /* subset response data! */
            
            //parse the data
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: newData!, options: .allowFragments) as! [String:AnyObject]
            } catch {
                print("Could not parse the data as JSON: '\(String(describing: newData))'")
                return
            }
            //check if status is ok
            if let val = parsedResult["status"]{
                DispatchQueue.main.async {
                    self.showAlertMessage(messageType: "error \(val)", messageText: parsedResult["error"] as! String)
                }
                return
            }
            
            //get the sessionid out of the data
            /* GUARD: Did we receive a session? */
            guard let sessionSolution = parsedResult["session"] else {
                print("Could not find key 'session' in  \(parsedResult)")
                return
            }
            //grab the sessionid
            guard let sessionId = sessionSolution["id"] as? String else{
                DispatchQueue.main.async() {
                    self.showAlertMessage(messageType: "error", messageText: "Could not find sessionId in data!")
                }
                return
            }
            // !!!!!!!!! de sessionid nog opslaan  !!!!!!!!!!
            
            DispatchQueue.main.async {
                if let tabViewController = self.storyboard?.instantiateViewController(withIdentifier: "loginOk") {
                    self.loadStudentLocations()
                    self.present(tabViewController, animated: true, completion: nil)
                }
            }
            
        }
        task.resume()
    }
    
    @IBAction func SignUpButtonClicked(_ sender: UIButton) {
        if let url = URL(string: "https://auth.udacity.com/sign-up"){
            UIApplication.shared.open(url, options:[:], completionHandler: nil)
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
    
    func loadStudentLocations(){
        var request = URLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation?limit=20")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error...
                return
            }
            //parse the data
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:AnyObject]
            } catch {
                print("Could not parse the data as JSON: '\(String(describing: data))'")
                return
            }
            
            DispatchQueue.main.async {
                let object = UIApplication.shared.delegate as! AppDelegate
                var arrayOfStudentLocationStructs:[StudentLocation] = []
                for sl in parsedResult["results"] as! [NSDictionary] {
                    arrayOfStudentLocationStructs.append(StudentLocation(dictionary: sl))
                }
                object.studentLoactionArray = arrayOfStudentLocationStructs
            }
        }
        task.resume()
        
    }
}

