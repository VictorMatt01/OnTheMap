//
//  Model.swift
//  OnTheMap
//
//  Created by Victor Matthijs on 02/08/2018.
//  Copyright © 2018 Victor Matthijs. All rights reserved.
//

import Foundation
import UIKit

class Model {
    
    var studentLoactionArray:[StudentInformation] = []
    
    func loadStudentLocations(_ completionHandlerForGetStudentLoactions: @escaping (_ result: [StudentInformation]?, _ error: NSError?) -> Void) {
        var request = URLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation?limit=100&order=-updatedAt")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error...
                completionHandlerForGetStudentLoactions(nil, error! as NSError)
                return
            }
            
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:AnyObject]
            } catch {
                print("Could not parse the data as JSON: '\(String(describing: data))'")
                return
            }
            
            var arrayOfStudentLocationStructs:[StudentInformation] = []
            for sl in parsedResult["results"] as! [NSDictionary] {
                arrayOfStudentLocationStructs.append(StudentInformation(dictionary: sl))
            }
            completionHandlerForGetStudentLoactions(arrayOfStudentLocationStructs, nil)
        }
        task.resume()
    }
    
    func loginToUdacityApi(email:String, password:String, _ completionHandlerForUdacityLogin: @escaping (_ result: [String:AnyObject]?, _ error: String) -> Void){
        var request = URLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}".data(using: .utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            
            if error != nil { // Handle error: show the type of error to the user
                
                completionHandlerForUdacityLogin(nil, (error?.localizedDescription)!)
                return
            }
            let range = Range(5..<data!.count)
            let newData = data?.subdata(in: range) /* subset response data! */
            
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: newData!, options: .allowFragments) as! [String:AnyObject]
            } catch {
                print("Could not parse the data as JSON: '\(String(describing: data))'")
                return
            }
            //check for status
            if let status = parsedResult["status"] {
                let error = parsedResult["error"]
                completionHandlerForUdacityLogin(nil, error as! String)
                return
            }
            completionHandlerForUdacityLogin(parsedResult, "")
        }
        task.resume()
    }
    
    func logOutFromUdacity(_ completionHandlerLogOutFromUdacity: @escaping (_ result: [String:AnyObject]?, _ error: NSError?) -> Void){
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
                completionHandlerLogOutFromUdacity(nil, error! as NSError)
                return
            }
            let range = Range(5..<data!.count)
            let newData = data?.subdata(in: range) /* subset response data! */
            
            //parse the data
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: newData!, options: .allowFragments) as! [String:AnyObject]
            } catch {
                completionHandlerLogOutFromUdacity(nil, error as NSError)
                return
            }
            
            guard parsedResult["session"] != nil else {
                completionHandlerLogOutFromUdacity(nil, error! as NSError)
                return
            }
            
            completionHandlerLogOutFromUdacity(parsedResult, nil)
            
        }
        task.resume()
    }
    
    func lookForStudentLocation(sessionKey:String, _ completionHandlerLookingForStudentLocation: @escaping (_ result: NSArray?, _ error: NSError?) -> Void){
        let urlStringGetStudentLocation = "where={\"uniqueKey\":\"\(sessionKey)\"}"
        let escapedURLGetSL = urlStringGetStudentLocation.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        let totalURL = "https://parse.udacity.com/parse/classes/StudentLocation?" + escapedURLGetSL!
        
        let url = URL(string: totalURL)
        var request = URLRequest(url: url!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil {
                completionHandlerLookingForStudentLocation(nil, error! as NSError)
                return
            }
            
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:AnyObject]
            } catch {
                completionHandlerLookingForStudentLocation(nil, error as NSError)
                return
            }
            let results = parsedResult["results"] as! NSArray
            completionHandlerLookingForStudentLocation(results, nil)
        }
        task.resume()
    }
    
    func postNewStudentLocation(uniqueKey:String, mapString:String, mediaURl:String, latitude:Double, longtitude:Double, firstName:String, lastName:String, completionHandlerForPostingNewLocation: @escaping (_ result: [String:AnyObject]?, _ error: NSError?) -> Void){
        
        var request = URLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
        request.httpMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(uniqueKey)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURl)\",\"latitude\": \(latitude), \"longitude\": \(longtitude)}".data(using: .utf8)
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil {
                completionHandlerForPostingNewLocation(nil, error! as NSError)
                return
            }
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:AnyObject]
            } catch {
                completionHandlerForPostingNewLocation(nil, error as NSError)
                return
            }
            completionHandlerForPostingNewLocation(parsedResult, nil)
        }
        task.resume()
    }
    
    func updateStudentLocation(objectId:String, uniqueKey:String, mapString:String, mediaURl:String, latitude:Double, longtitude:Double, firstName:String, lastName:String, completionHandlerForUpdatingStudentLocation: @escaping (_ result: [String:AnyObject]?, _ error: NSError?) -> Void){
        let urlString = "https://parse.udacity.com/parse/classes/StudentLocation/\(objectId)"
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.httpMethod = "PUT"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(uniqueKey)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURl)\",\"latitude\": \(latitude), \"longitude\": \(longtitude)}".data(using: .utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil {
                completionHandlerForUpdatingStudentLocation(nil, error! as NSError)
                return
            }
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:AnyObject]
            } catch {
                completionHandlerForUpdatingStudentLocation(nil, error as NSError)
                return
            }
            completionHandlerForUpdatingStudentLocation(parsedResult, nil)
        }
        task.resume()
    }
    
}
