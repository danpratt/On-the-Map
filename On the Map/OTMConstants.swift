//
//  OTMConstants.swift
//  On the Map
//
//  Created by Daniel Pratt on 3/16/17.
//  Copyright © 2017 Daniel Pratt. All rights reserved.
//

// MARK: = OTMClient (Constants)

extension OTMClient {
    
    // MARK: Constants
    struct Constants {
        
        // MARK: Parameter Keys
        struct ParameterKeys {
            static let Udacity = "udacity"
            static let Username = "username"
            static let Password = "password"
        }
        
        // MARK: JSON Response Keys
        struct JSONResponseKeys {
            
            static let Account = "account"
            static let Session = "session"
            
            static let IsRegistered = "registered"
            static let Key = "key"
            
            
        }
        
        // MARK: Methods
        struct Methods {
            
            // MARK: Account
            
            // MARK: Authentication
            static let AuthenticateSessionNew = "https://www.udacity.com/api/session"
        }
    }
    
}
