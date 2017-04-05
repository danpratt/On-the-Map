//
//  OTMTabBarViewController.swift
//  On the Map
//
//  Created by Daniel Pratt on 4/4/17.
//  Copyright © 2017 Daniel Pratt. All rights reserved.
//

import UIKit

class OTMTabBarViewController: UITabBarController {
    
    // MARK: - Properties
    
    // Indicator View
    let Indicator = OTMActivityIndicator()
    var activity = UIActivityIndicatorView()
    
    // MARK: - IBActions
    
    // MARK: - Logoff
    @IBAction func logoutButtonTapped(_ sender: Any) {
        activity = Indicator.StartActivityIndicator(obj: self, color: .blue)
        let method = OTMClient.Constants.Methods.AuthenticateSession
        let _ = OTMClient.sharedInstance().taskForDELETEMethod(method) { (data, error) in
            if let error = error {
                print("Logout Error: \(String(describing: error))")
                self.createAlertWithTitle("Logout Error", message: "There was an error logging off.  Please check your network connection and try again.", actionMessage: "OK", completionHandler: nil)
            }
            
            if let sessionDictionary = data?[OTMClient.Constants.JSONResponseKeys.Session] as? NSDictionary {
                performUIUpdatesOnMain {
                    self.Indicator.StopActivityIndicator(obj: self, indicator: self.activity)
                    print(sessionDictionary)
                    self.dismiss(animated: true, completion: nil)
                }
            } else {
                self.createAlertWithTitle("Logout Error", message: "There was an error logging off.  Please check your network connection and try again.", actionMessage: "OK", completionHandler: nil)
            }
            
            
            
        }
    }

    
    // MARK: - Reload
    @IBAction func reloadButtonPressed(_ sender: Any) {
        
        let activity = Indicator.StartActivityIndicator(obj: self, color: .blue)
        
        let loadQueue = DispatchQueue.init(label: "loadQueue", attributes: .concurrent)
        
        loadQueue.sync {
            OTMClient.sharedInstance().getMapPinData { (success, data, error) in
                if success {
                    if let mapData = data {
                        OTMClient.sharedInstance().mapPinData = mapData
                        performUIUpdatesOnMain {
                            self.Indicator.StopActivityIndicator(obj: self, indicator: activity)
                            _ = self.navigationController?.popToRootViewController(animated: false)
                            let controller = self.storyboard!.instantiateViewController(withIdentifier: "OTMNavController") as! UINavigationController
                            self.present(controller, animated: false, completion: nil)
                        }
                        
                    }
                } else {
                    performUIUpdatesOnMain {
                        self.createAlertWithTitle("Error", message: "There was an error reloading data, please try again.", actionMessage: "OK", completionHandler: nil)
                    }
                }
            }

        }
        
    }

}
