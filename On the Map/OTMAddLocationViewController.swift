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
        print("adding location, woot!")
        OTMClient.sharedInstance().addUserLocation(withUserMapPinData: userMapPinData) { (success, error) in
            if success {
                print("Success")
                self.dismiss(animated: true, completion: nil)
            } else {
                print(error ?? "No error given")
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
        // Textfield must have something in it to get this far, so no check for empty string is necessary
        let url = self.urlEntryTextField.text
        
        // Make sure that the user has entered http:// or https:// at the start of the URL
        if (url?.characters.count)! > 8 {
            let http = url?.substring(to: (url?.index((url?.startIndex)!, offsetBy: 7))!).lowercased()
            let https = url?.substring(to: (url?.index((url?.startIndex)!, offsetBy: 8))!).lowercased()
            if (http == "http://") || (https == "https://") {
                if (userMapPinData.addURL(url!)) {
                    addLocation()
                } else {
                    print("URL already exists")
                }
                
            }
        } else {
            print("You must enter a valid url")
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
