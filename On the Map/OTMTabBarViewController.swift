//
//  OTMTabBarViewController.swift
//  On the Map
//
//  Created by Daniel Pratt on 4/4/17.
//  Copyright © 2017 Daniel Pratt. All rights reserved.
//

import UIKit

class OTMTabBarViewController: UITabBarController {
    
    // Indicator View
    let Indicator = OTMActivityIndicator()
    
    @IBAction func reloadButtonPressed(_ sender: Any) {
        
        let activity = Indicator.StartActivityIndicator(obj: self)
        
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
