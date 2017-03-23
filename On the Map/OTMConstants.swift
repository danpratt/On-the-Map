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
            // Account
            static let Udacity = "udacity"
            static let Username = "username"
            static let Password = "password"
            
            // PUT Location
            static let UniqueKey = "uniqueKey"
            static let FirstName = "firstName"
            static let LastName = "lastName"
            static let MapString = "mapString"
            static let MediaURL = "mediaURL"
            static let Latitude = "latitude"
            static let Longitude = "longitude"
            
            // Application and API Keys
            static let ApplicationID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
            static let API_Key = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        }
        
        // MARK: JSONParameterKeys
        struct JSONParameterKeys {
            // Post
            static let JSONApplication = "application/json"
            static let Accept = "Accept"
            static let Content = "Content-Type"
            static let IDHeaderField = "X-Parse-Application-Id"
            static let APIHeaderField = "X-Parse-REST-API-Key"
        }
        
        // MARK: HTTP Method
        struct HTTPMethods {
            static let Post = "POST"
            static let Put = "PUT"
            static let Delete = "DELETE"
        }
        
        // MARK: JSON Response Keys
        struct JSONResponseKeys {
            
            static let Account = "account"
            static let Session = "session"
            
            static let IsRegistered = "registered"
            static let UserID = "key"
            
            
        }
        
        // MARK: Methods
        struct Methods {
            
            // Authentication
            static let AuthenticateSession = "https://www.udacity.com/api/session"
            
            // Getting Student Locations
            static let StudentLocations = "https://parse.udacity.com/parse/classes/StudentLocation"
            
            // Getting Public User Data
            static let GetPublicData = "https://www.udacity.com/api/users/"
        }
    }
    
}
