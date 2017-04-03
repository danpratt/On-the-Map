//
//  OTMConvenience.swift
//  On the Map
//
//  Created by Daniel Pratt on 3/23/17.
//  Copyright © 2017 Daniel Pratt. All rights reserved.
//

import UIKit
import Foundation
import MapKit

// MARK: - OTMClient (Convenient Resource Methods)

extension OTMClient {
    
    // MARK: Authentication
    
    func authenticateWithUdacity(_ hostViewController: OTMAuthViewViewController, completionHandlerForAuth: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        self.hostViewController = hostViewController
        
        hostViewController.loginButton.isEnabled = false
        hostViewController.loginActivity.startAnimating()
        
        // Start the login process
        
        // TODO: - Add error handling
        getLoginItems() { (success, userID, sessionID, errorString) in
            if success {
                // Write User and session ID's
                self.userID = userID!
                self.sessionID = sessionID!
                
                // Get the logged in user's data
                self.getUsersData({ (success, first, last, errorString) in
                    if success {
                        // Write the User's First / Last Name
                        self.firstName = first
                        self.lastName = last
                        
                        // Get the data to populate the map with
                        self.getMapPinData() { (success, mapPinData, errorString) in
                            
                            if success {
                                
                                self.hostViewController.loginActivity.stopAnimating()
                                self.mapPinData = mapPinData!
                                
                                completionHandlerForAuth(success, nil)
                            } else {
                                // Unable to get the mapPinData
                                print("Error String Message: \(String(describing: errorString))")
                                completionHandlerForAuth(false, "MAPDATA")
                            }
                        }
                    } else {
                        // Unable to get user data
                        print("Error String Message: \(String(describing: errorString))")
                        completionHandlerForAuth(false, "USERDATA")
                    }
                })
            } else {
                // Unable to login
                print("Error String Message: \(String(describing: errorString))")
                completionHandlerForAuth(false, "LOGIN")
            }
        }
        
    }
    
    // Call to add a location
    func addUserLocation(withUserMapPinData data: OTMMapData, completionHandlerForAddLocation: @escaping (_ success: Bool, _ wasNewEntry: Bool, _ errorString: String?) -> Void) {
        
        // Setup the headers and parameters that both calls will use
        let httpHeaderFields = [Constants.ParameterKeys.API_Key:Constants.JSONParameterKeys.APIHeaderField,
                                Constants.ParameterKeys.ApplicationID:Constants.JSONParameterKeys.IDHeaderField
        ]
        
        // Everything will be here in order to get to this point, so we can force unwrap safely
        let parametersDictionary = [Constants.ParameterKeys.UniqueKey:data.uniqueKey!,
                                    Constants.ParameterKeys.FirstName:data.firstName!,
                                    Constants.ParameterKeys.LastName:data.lastName!,
                                    Constants.ParameterKeys.MapString:data.mapString!,
                                    Constants.ParameterKeys.MediaURL:data.mediaURL!,
                                    Constants.ParameterKeys.Latitude:String(data.latitude),
                                    Constants.ParameterKeys.Longitude:String(data.longitude)
                                    ]
        
        // If the user has never uploaded go ahead and do a post
        // Otherwise warn user and do put
        if usersExistingObjectID == nil {
            // Post Data
            let method = Constants.Methods.StudentLocation
            print("We would be posting data using:")
            print("httpHeaderFields: \(String(describing: httpHeaderFields))")
            print("parametersDictionary: \(String(describing: parametersDictionary))")
            print("method: \(String(describing: method))")
            // Assign object ID to prevent duplicates
            completionHandlerForAddLocation(true, true, nil)
        } else {
            // warn user
            // Put
            let method = (Constants.Methods.StudentLocation) + (self.usersExistingObjectID)!
            print("We would be posting data using:")
            print("httpHeaderFields: \(String(describing: httpHeaderFields))")
            print("parametersDictionary: \(String(describing: parametersDictionary))")
            print("method: \(String(describing: method))")
            completionHandlerForAddLocation(true, false, nil)
        }
        
        
        
    }
    
    // MARK: - Privater Helper Functions
    
    // Tries to login using UN/PW and gets the user id and session id
    private func getLoginItems(_ completionHandlerForLogin: @escaping (_ success: Bool, _ userID: String?, _ sessionID: String?, _ errorString: String?) -> Void) {
        
        // Setup paramets and headers for method call
        // Username / Password check was done before getting here, so at least something exists
        let parameters = [OTMClient.Constants.ParameterKeys.Username: hostViewController.username, OTMClient.Constants.ParameterKeys.Password: hostViewController.password]
        
        let headerFields = [OTMClient.Constants.JSONParameterKeys.JSONApplication:OTMClient.Constants.JSONParameterKeys.Accept]
        
        let _ = taskForPOSTMethod(Constants.Methods.AuthenticateSession, parameters: parameters as! [String : String], httpHeaderFields: headerFields) { (loginItems, error) in
            
            // check for error
            if let error = error {
                print(error)
                completionHandlerForLogin(false, nil, nil, "Login Failed")
            } else {
                guard let accountDictionary = loginItems?[Constants.JSONResponseKeys.Account] as? NSDictionary, let sessionDictionary = loginItems?[Constants.JSONResponseKeys.Session] as? NSDictionary else {
                    completionHandlerForLogin(false, nil, nil, "Unable to parse JSON data (Login)")
                    return
                }
                
                guard let userID = accountDictionary[Constants.JSONResponseKeys.UserID], let sessionID = sessionDictionary[Constants.JSONResponseKeys.SessionID] else {
                    completionHandlerForLogin(false, nil, nil, "Unable to parse JSON data (Login)")
                    return
                }
                
                completionHandlerForLogin(true, (userID as! String), (sessionID as! String), nil)
            }
        }
        
    }
    
    // Get logged in user's info to use when added locations
    private func getUsersData(_ completionHandlerForGetUserDate: @escaping (_ success: Bool, _ firstName: String?, _ lastName: String?, _ errorString: String?) -> Void) {
        
        // Make sure the UserID has been populated
        guard let ID = self.userID else {
            completionHandlerForGetUserDate(false, nil, nil, "Getting User ID Failed")
            return
        }
        
        let method = ("\(Constants.Methods.GetPublicUserData)\(ID)")
        
        let _ = taskForGETMethod(method) { (data, error) in
            if let error = error {
                print(error)
                completionHandlerForGetUserDate(false, nil, nil, "Unable to get User Data")
                return
            } else {
                if let userDataDictionary = data?[Constants.JSONUserDataResponseKeys.User] as? [String:AnyObject] {
                    guard let first = userDataDictionary[Constants.JSONUserDataResponseKeys.FirstName] as? String else {
                        completionHandlerForGetUserDate(false, nil, nil, "Unable to get User First Name")
                        return
                    }
                    
                    guard let last = userDataDictionary[Constants.JSONUserDataResponseKeys.LastName] as? String else {
                        completionHandlerForGetUserDate(false, nil, nil, "Unable to get User Last Name")
                        return
                    }
                    
                    completionHandlerForGetUserDate(true, first, last, nil)
                }
                
            }
        }
    }
    
    // Get existing user data to show map locations
    private func getMapPinData(_ completionHandlerForGetMapPindata: @escaping (_ succes: Bool, _ mapPinData: [OTMMapData]?, _ errorString: String?) -> Void) {
        let httpHeaderFields = [OTMClient.Constants.ParameterKeys.ApplicationID:OTMClient.Constants.JSONParameterKeys.IDHeaderField, OTMClient.Constants.ParameterKeys.API_Key:OTMClient.Constants.JSONParameterKeys.APIHeaderField]
        
        let _ = taskForGETMethod(Constants.Methods.StudentLocation, httpHeaderFields: httpHeaderFields) { (data, error) in
            if let error = error {
                print(error)
                completionHandlerForGetMapPindata(false, nil, "Unable to get map data")
                return
            } else {
                let dictionaries = data?[Constants.JSONMapResponseKeys.Results] as! [[String:AnyObject]]
                let mapData = OTMMapData.mapDataFromDictionaries(dictionaries)
                
                completionHandlerForGetMapPindata(true, mapData, nil)
            }
        }
    }
}
