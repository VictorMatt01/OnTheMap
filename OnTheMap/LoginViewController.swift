//
//  ViewController.swift
//  OnTheMap
//
//  Created by Victor Matthijs on 20/07/2018.
//  Copyright © 2018 Victor Matthijs. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var LoginButton: UIButton!
    @IBOutlet weak var EmailTextField: UITextField!
    @IBOutlet weak var PasswordTextField: UITextField!
    @IBOutlet weak var SignUpButton: UIButton!
    
    var appSessionInfo: Constants.Session!
    let model = Model.init()
    let object = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.placeholder = ""
    }
    
    @IBAction func LoginButtonPressed(_ sender: UIButton) {
        //check if email and/or password aren't empty
        if(EmailTextField.text?.isEmpty ?? true){
            showAlertMessage(messageType: "Email", messageText: "You must insert an email!")
        } else if(EmailTextField.text?.range(of:"@") == nil){
            showAlertMessage(messageType: "Email", messageText: "Your email isn't correct!")
        }else if(PasswordTextField.text?.isEmpty ?? true){
            showAlertMessage(messageType: "Password", messageText: "You must insert a password!")
        }else{
            let email:String = EmailTextField.text!
            let password:String = PasswordTextField.text!
            loginToUdacity(email: email, password: password)
        }
        
    }
    
    func loginToUdacity(email:String, password:String){
        model.loginToUdacityApi(email: email, password: password) { (result, error) in
            if error != "" {
                DispatchQueue.main.async {
                    self.showAlertMessage(messageType: "Error", messageText: (error))
                }
            }else{
                let sessionInfo = Constants.Session.init(mainDictionary: result! as NSDictionary)
                DispatchQueue.main.async {
                    self.object.appSessionInfo = sessionInfo
                    self.loadStudentLocations()
                }
            }
        }
    }
    
    @IBAction func SignUpButtonClicked(_ sender: UIButton) {
        if let url = URL(string: "https://auth.udacity.com/sign-up"){
            UIApplication.shared.open(url, options:[:], completionHandler: nil)
        }
    }
    
    func loadStudentLocations(){
        model.loadStudentLocations { (result, error) in
            if let result = result {
                DispatchQueue.main.async {
                    self.model.studentLoactionArray = result
                    if let tabViewController = self.storyboard?.instantiateViewController(withIdentifier: "loginOk") {
                        let mapVC:MapViewController = (tabViewController.childViewControllers[0] as! MapViewController)
                        mapVC.model = self.model
                        let tableVC:LocationTableViewController = (tabViewController.childViewControllers[1] as! LocationTableViewController)
                        tableVC.model = self.model
                        self.present(tabViewController, animated: true, completion: nil)
                    }
                }
            } else {
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
