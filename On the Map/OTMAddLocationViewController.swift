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
    
    // Indicator View
    let Indicator = OTMActivityIndicator()
    
    // IBOutlets
    @IBOutlet weak var addPointMapView: MKMapView!
    @IBOutlet weak var urlEntryTextField: UITextField!
    
    // MARK: - viewDidLoad()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centerMap()
        urlEntryTextField.delegate = self
    }
    
    // MARK: - IBActions
    @IBAction func submitButtonTapped(_ sender: Any) {
        if urlEntryTextField.isFirstResponder {
            self.urlEntryTextField.resignFirstResponder()
        }
        
        checkURLBeforeAddLocation()
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
    
    // Check to make sure that location is valid
    private func checkURLBeforeAddLocation() {
        // This will always work, but I would rather do it safely
        if let locationVC = previousVC as? OTMLocatoinInputViewController {
            // lets OTMLocationInputVC know that it can dismiss itself after we dismiss this VC
            locationVC.doneAdding = true
        }
        
        // Textfield won't be nil, and error handling will be done below.
        let url = self.urlEntryTextField.text
        
        // Make sure that the user has entered http:// or https:// at the start of the URL
        if (url?.characters.count)! > 8 {
            let http = url?.substring(to: (url?.index((url?.startIndex)!, offsetBy: 7))!).lowercased()
            let https = url?.substring(to: (url?.index((url?.startIndex)!, offsetBy: 8))!).lowercased()
            if (http == "http://") || (https == "https://") {
                
                // check to see if user data exists
                // if it does we will initiate addLocation from here
                if OTMClient.sharedInstance().usersExistingObjectID != nil {
                    createAlertWithTitle("Existing Data", message: "You have an existing map point.  Would you like to overwrite it?", actionMessages: ["Yes", "No"], completionHandler: { (alert) in
                        if alert.title == "Yes" {
                            self.addLocation()
                        } else {
                            self.dismiss(animated: true, completion: nil)
                        }
                    })
                }
                
                // Make sure that the URL can be added, and that the user doesn't have existing data that was uploaded
                if (userMapPinData.addURL(url!)) && OTMClient.sharedInstance().usersExistingObjectID == nil {
                    addLocation()
                } else {
                    //  This really should never happen
                    createAlertWithTitle("Not Added", message: "The URL and Location were not submitted.  Tap OK to return to pin data overview.", actionMessage: "OK", completionHandler: { (alert) in
                        self.dismiss(animated: true, completion: nil)
                    })
                    
                }
                
            }
        } else {
            // Show popup warning
            createAlertWithTitle("Invalid URL", message: "You must enter a valid URL. \n(e.g. https://www.udacity.com)", actionMessage: "OK", completionHandler: nil)
        }
    }
    
    // Add the locatoin to the map, and return to the navigation view
    private func addLocation() {
        let activity = Indicator.StartActivityIndicator(obj: self, color: .white)
        
        OTMClient.sharedInstance().addUserLocation(withUserMapPinData: userMapPinData) { (success, wasNew, error) in
            
            if success {
                

                
                // Lets the map view center on the user location
                OTMClient.sharedInstance().userLocation = CLLocationCoordinate2D(latitude: self.userMapPinData.latitude, longitude: self.userMapPinData.longitude)
                
                // Get the objectID from the sharedInstance (was written to during addUserLocatoin call) and add it to the userMapPinData object
                if let objectID = OTMClient.sharedInstance().usersExistingObjectID {
                    self.userMapPinData.objectID = objectID
                    
                } else {
                    // This will never happen if there is a success message, but safety first!
                    self.createAlertWithTitle("Error", message: "There was an error adding your location.  Please exit the app and try again later", actionMessage: "OK", completionHandler: nil)
                }
                
                // Add the location to the array of mapPinData so we don't need to load from the network again.
                if wasNew {
                    OTMClient.sharedInstance().mapPinData?.insert((self.userMapPinData), at: 0)
                } else {
                    // Find and remove the old one.  Put the new one at the top of the list
                    for (index, data) in OTMClient.sharedInstance().mapPinData!.enumerated() {
                        if data.objectID == OTMClient.sharedInstance().usersExistingObjectID {
                            OTMClient.sharedInstance().mapPinData?.remove(at: index)
                            OTMClient.sharedInstance().mapPinData?.insert((self.userMapPinData), at: 0)
                        }
                    }
                }
                
                // Tell the VC to reload data
                OTMClient.sharedInstance().mapPinDataUpdated = true
                OTMClient.sharedInstance().listDataUpdated = true
                performUIUpdatesOnMain {
                    self.Indicator.StopActivityIndicator(obj: self, indicator: activity)
                }
                self.dismiss(animated: true, completion: nil)
            } else {
                print("There was an error")
                print("Error adding new pin data: \(String(describing: error))")
                performUIUpdatesOnMain {
                    self.Indicator.StopActivityIndicator(obj: self, indicator: activity)
                    self.createAlertWithTitle("Error", message: "Unable to upload data.  Please try again later.", actionMessage: "OK", completionHandler: { (alert) in
                        self.dismiss(animated: true, completion: nil)
                    })
                    
                    self.dismiss(animated: true, completion: nil)
                }
                
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
        checkURLBeforeAddLocation()
        return true
    }
    
    // If user taps out, we want the keyboard to go away, but we don't want to start the search
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.urlEntryTextField.isFirstResponder {
            self.urlEntryTextField.resignFirstResponder()
        }
    }

}
