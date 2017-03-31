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
                            }
                        }
                    }
                })
            }
        }
        
    }
    
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
        
        let _ = taskForGETMethod(Constants.Methods.StudentLocations, httpHeaderFields: httpHeaderFields) { (data, error) in
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
