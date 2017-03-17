//
//  OTMClient.swift
//  On the Map
//
//  Created by Daniel Pratt on 3/16/17.
//  Copyright © 2017 Daniel Pratt. All rights reserved.
//

import UIKit

// MARK: = OTMClient: NSObject

class OTMClient: NSObject {
    
    // MARK: Properties
    
    // shared session
    var session = URLSession.shared
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> OTMClient {
        struct Singleton {
            static var sharedInstance = OTMClient()
        }
        return Singleton.sharedInstance
    }
    
}
