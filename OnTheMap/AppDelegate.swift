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
    
    var udacitySessionId: String? = nil
    
    var studentLoactionArray:[StudentLocation] = []
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

struct StudentLocation {
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
