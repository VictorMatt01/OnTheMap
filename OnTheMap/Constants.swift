//
//  Constants.swift
//  OnTheMap
//
//  Created by Victor Matthijs on 31/07/2018.
//  Copyright © 2018 Victor Matthijs. All rights reserved.
//

import Foundation

struct Constants {
    
    struct Session {
        let registered:Int
        let key:String
        let id:String
        let expiration:String
        
        init(mainDictionary: NSDictionary) {
            let dicAccount = mainDictionary["account"] as! NSDictionary
            let dicSession = mainDictionary["session"] as! NSDictionary
            self.registered = dicAccount["registered"] as? Int ?? 0
            self.key = dicAccount["key"] as? String ?? ""
            self.id = dicSession["id"] as? String ?? ""
            self.expiration = dicSession["expiration"] as? String ?? ""
        }
    }
    
}
