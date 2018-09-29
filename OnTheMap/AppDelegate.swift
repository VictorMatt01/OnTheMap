//
//  AppDelegate.swift
//  OnTheMap
//
//  Created by Victor Matthijs on 20/07/2018.
//  Copyright © 2018 Victor Matthijs. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var appSessionInfo:Constants.Session!

}

struct StudentInformation {
    var createdAt:String
    var firstName:String
    var lastName:String
    var mapString:String
    var mediaURL:String
    var objectId:String
    var uniqueKey:String
    var updatedAt:String
    var latitude:NSNumber
    var longitude:NSNumber
    
    init(dictionary: NSDictionary) {
        self.createdAt = dictionary["createdAt"] as? String ?? ""
        self.firstName = dictionary["firstName"] as? String ?? ""
        self.lastName = dictionary["lastName"] as? String ?? ""
        self.mapString = dictionary["mapString"] as? String ?? ""
        self.mediaURL = dictionary["mediaURL"] as? String ?? ""
        self.objectId = dictionary["objectId"] as? String ?? ""
        self.uniqueKey = dictionary["uniqueKey"] as? String ?? ""
        self.updatedAt = dictionary["updatedAt"] as? String ?? ""
        self.latitude = dictionary["latitude"] as? NSNumber ?? 0
        self.longitude = dictionary["longitude"] as? NSNumber ?? 0
    }
    
}
