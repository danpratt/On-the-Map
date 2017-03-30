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

class OTMLocatoinInputViewController: UIViewController {

    // MARK: - Properties
    lazy var geoCoder = CLGeocoder()
    
    // IBOutlets
    @IBOutlet weak var locationEntry: UITextField!
    @IBOutlet weak var findLocationButton: UIButton!
    @IBOutlet weak var findLocationActivityMonitor: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func findLocationButtonPressed(_ sender: Any) {
        if let searchString = locationEntry.text {
            performUIUpdatesOnMain {
                self.findLocationActivityMonitor.isHidden = false
                self.findLocationActivityMonitor.startAnimating()
                self.findLocationButton.isEnabled = false
            }
            geoCoder.geocodeAddressString(searchString, completionHandler: { (placemarks, error) in
                self.processResponse(withPlacemarks: placemarks, error: error)
            })
        } else {
            print("Must enter something")
        }
        
        
    }
    
    // MARK: - Private Helper Functions
    
    // Process the response
    private func processResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) {
        // Update View
        findLocationActivityMonitor.stopAnimating()
        findLocationButton.isEnabled = true
        
        if let error = error {
            print("Unable to Forward Geocode Address (\(error))")
            
        } else {
            var location: CLLocation?
            
            if let placemarks = placemarks, placemarks.count > 0 {
                location = placemarks.first?.location
            }
            
            print(location ?? "location was nil")
        }
    }

}
