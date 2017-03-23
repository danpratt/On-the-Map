//
//  OTMConvenience.swift
//  On the Map
//
//  Created by Daniel Pratt on 3/23/17.
//  Copyright © 2017 Daniel Pratt. All rights reserved.
//

import UIKit
import Foundation

// MARK: - OTMClient (Convenient Resource Methods)

extension OTMClient {
    
    // MARK: Authentication
    
    func authenticateWithUdacity(_ hostViewController: OTMAuthViewViewController, completionHandlerForAuth: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        self.hostViewController = hostViewController
        
        hostViewController.loginButton.isEnabled = false
        hostViewController.loginActivity.startAnimating()
        
        getLoginItems() { (success, userID, sessionID, errorString) in
            if success {
                print("User ID: \(userID)")
                print("Session ID: \(sessionID)")
                self.userID = userID!
                self.sessionID = sessionID!
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
    
}
