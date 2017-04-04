//
//  AddLocationViewController.swift
//  On the Map
//
//  Created by Daniel Pratt on 3/24/17.
//  Copyright © 2017 Daniel Pratt. All rights reserved.
//

import UIKit
import MapKit

// MARK: - OTMAddLocationViewController Class

class OTMAddLocationViewController: UIViewController, UITextFieldDelegate {

    // MARK: - Properties
    
    // User Entry
    var userMapPinData: OTMMapData!
    
    // Previous View Controller
    var previousVC: UIViewController? = nil
    
    // IBOutlets
    @IBOutlet weak var addPointMapView: MKMapView!
    @IBOutlet weak var urlEntryTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centerMap()
        urlEntryTextField.delegate = self
    }
    
    // MARK: - Private Functions
    
    // Center the map at a specific point
    private func centerMap() {
        let coordinate = CLLocationCoordinate2D(latitude: userMapPinData.latitude, longitude: userMapPinData.longitude)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = userMapPinData.mapString
        addPointMapView.addAnnotation(annotation)
        addPointMapView.setRegion(MKCoordinateRegion.init(center: annotation.coordinate, span: .init(latitudeDelta: 1, longitudeDelta: 1)), animated: true)
    }
    
    // Add the locatoin to the map, and return to the navigation view
    private func addLocation() {
        OTMClient.sharedInstance().addUserLocation(withUserMapPinData: userMapPinData) { (success, wasNew, error) in
            if success {
                // Add the location to the array of mapPinData so we don't need to load from the network again.
                if wasNew {
                    OTMClient.sharedInstance().mapPinData?.append(self.userMapPinData)
                } else {
                    // Find and replace the old one
                    for (index, data) in OTMClient.sharedInstance().mapPinData!.enumerated() {
                        if data.objectID == OTMClient.sharedInstance().usersExistingObjectID {
                            OTMClient.sharedInstance().mapPinData?[index] = self.userMapPinData
                        }
                    }
                }
                
                // Tell the VC to reload data
                OTMClient.sharedInstance().mapPinDataUpdated = true
                OTMClient.sharedInstance().listDataUpdated = true
                self.dismiss(animated: true, completion: nil)
            } else {
                print("Error adding new pin data: \(String(describing: error))")
                self.createAlertWithTitle("Error", message: "Unable to upload data.  Please try again later.", actionMessage: "OK", completionHandler: { (alert) in
                    self.dismiss(animated: true, completion: nil)
                })
            }
        }
        
    }
    
    // MARK: - Delegate Functions
    
    // Clear text entry when user clicks into field
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.text = ""
        return true
    }
    
    // When Go Button is Pressed, begin adding URL
    // Go button will only work if user has typed something, so checking
    // that something is in the textField will be redundant
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        // This will always work, but I would rather do it safely
        if let locationVC = previousVC as? OTMLocatoinInputViewController {
            // lets OTMLocationInputVC know that it can dismiss itself after we dismiss this VC
            locationVC.doneAdding = true
        }
        
        // Textfield must have something in it to get this far, so no check for empty string is necessary
        let url = self.urlEntryTextField.text
        
        // Make sure that the user has entered http:// or https:// at the start of the URL
        if (url?.characters.count)! > 8 {
            let http = url?.substring(to: (url?.index((url?.startIndex)!, offsetBy: 7))!).lowercased()
            let https = url?.substring(to: (url?.index((url?.startIndex)!, offsetBy: 8))!).lowercased()
            if (http == "http://") || (https == "https://") {
                
                var addURL: Bool = true
                
                // check to see if user data exists
                if OTMClient.sharedInstance().usersExistingObjectID != nil {
                    createAlertWithTitle("Existing Data", message: "You have an existing map point.  Would you like to overwrite it?", actionMessages: ["Yes", "No"], completionHandler: { (alert) in
                        if alert.title == "No" {
                            addURL = false
                        }
                    })
                }
                
                // Make sure that the URL can be added, and that the user hasn't said they don't want to overwrite
                if (userMapPinData.addURL(url!)) && addURL {
                    addLocation()
                } else {
                    //  This really should never happen
                    createAlertWithTitle("Not Added", message: "The URL and Location was not submitted.  Tap Ok to return to pin data overview.", actionMessage: "OK", completionHandler: { (alert) in
                        self.dismiss(animated: true, completion: nil)
                    })

                }
                
            }
        } else {
            // Show popup warning
            createAlertWithTitle("Invalid URL", message: "You must enter a valid URL. \n(e.g. https://www.udacity.com)", actionMessage: "OK", completionHandler: nil)
        }
    
        
        return true
    }
    
    // If user taps out, we want the keyboard to go away, but we don't want to start the search
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.urlEntryTextField.isFirstResponder {
            self.urlEntryTextField.resignFirstResponder()
        }
    }

}
