//
//  OTMLocatoinInputViewController.swift
//  On the Map
//
//  Created by Daniel Pratt on 3/29/17.
//  Copyright © 2017 Daniel Pratt. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class OTMLocatoinInputViewController: UIViewController, UITextFieldDelegate {

    // MARK: - Properties
    lazy var geoCoder = CLGeocoder()
    var userMapPinData: OTMMapData?
    var placeName: String!
    
    var doneAdding: Bool?
    
    // Indicator View
    let Indicator = OTMActivityIndicator()
    var activity: UIActivityIndicatorView!
    
    // IBOutlets
    @IBOutlet weak var locationEntry: UITextField!
    @IBOutlet weak var findLocationButton: UIButton!
    
    // MARK: - View Loads
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationEntry.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if (self.doneAdding) != nil {
            self.dismiss(animated: false, completion: nil)
        }
    }

    // MARK: - IBActions
    
    @IBAction func findLocationButtonPressed(_ sender: Any) {
        guard let searchString = locationEntry.text, searchString != "", searchString != "Enter Your Location Here" else {
            createAlertWithTitle("Empty Search", message: "Please enter a location to search for.", actionMessage: "Ok", completionHandler: nil)
            return
            }
        
        placeName = searchString
        performUIUpdatesOnMain {
            self.activity = self.Indicator.StartActivityIndicator(obj: self, color: .white)
        }
        print("Searching for: \(String(describing: searchString))")
        geoCoder.geocodeAddressString(searchString, completionHandler: { (placemarks, error) in
            if error != nil {
                print("Error finding map data: \(String(describing: error))")
                self.createAlertWithTitle("Error", message: "Unable to find location.  Please try again", actionMessage: "Ok", completionHandler: nil)
            }
            self.processResponse(withPlacemarks: placemarks, error: error)
        })
    }
    
    // Go back from where we came
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Private Helper Functions
    
    // Process the response
    private func processResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) {
        // Update View
        self.Indicator.StopActivityIndicator(obj: self, indicator: activity)
        findLocationButton.isEnabled = true
        
        if let error = error {
            print("Unable to Forward Geocode Address (\(error))")
            
        } else {
            var location: CLLocation?
            
            if let placemarks = placemarks, placemarks.count > 0 {
                location = placemarks.first?.location
            }

            var userDataDictionary: [String : AnyObject] = [OTMClient.Constants.JSONMapResponseKeys.Key:OTMClient.sharedInstance().userID as AnyObject,
                                                            OTMClient.Constants.JSONMapResponseKeys.NameFirst:OTMClient.sharedInstance().firstName as AnyObject,
                                                            OTMClient.Constants.JSONMapResponseKeys.NameLast:OTMClient.sharedInstance().lastName as AnyObject,
                                                            OTMClient.Constants.JSONMapResponseKeys.MapString: placeName as AnyObject,
                                      OTMClient.Constants.JSONMapResponseKeys.Latitude:location?.coordinate.latitude as AnyObject,
                                      OTMClient.Constants.JSONMapResponseKeys.Longitude:location?.coordinate.longitude as AnyObject,
                                      ]
            
            if OTMClient.sharedInstance().usersExistingObjectID != nil {
                userDataDictionary[OTMClient.Constants.JSONMapResponseKeys.ObjectID] = OTMClient.sharedInstance().usersExistingObjectID as AnyObject
            }
            
            userMapPinData = OTMMapData(dictionary: userDataDictionary as [String : AnyObject])
            let addLocationVC = storyboard?.instantiateViewController(withIdentifier: "AddLocationView") as! OTMAddLocationViewController
            addLocationVC.userMapPinData = userMapPinData
            addLocationVC.previousVC = self
            
            // Set doneAdding to true so that when the AddLocatoinVC finishes up adding the URL, this VC will go away as well
            self.navigationController?.pushViewController(addLocationVC, animated: true)
        }
    }
    
    // MARK: - Delegate Functions
    
    // Clear text entry when user clicks into field
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.text = ""
        return true
    }
    
    // When Go Button is Pressed, begin search
    // Go button will only work if user has typed something, so checking
    // that something is in the textField will be redundant
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        findLocationButtonPressed(self)
        return true
    }
    
    // If user taps out, we want the keyboard to go away, but we don't want to start the search
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.locationEntry.isFirstResponder {
            self.locationEntry.resignFirstResponder()
        }
    }

}
