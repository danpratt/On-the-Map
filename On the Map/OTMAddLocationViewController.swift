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

class OTMAddLocationViewController: UIViewController {

    // MARK: - Properties
    
    // User Entry
    var userMapPinData: OTMMapData!
    
    // IBOutlets
    @IBOutlet weak var addPointMapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(userMapPinData)
        centerMap()
    }
    
    // MARK: - Private Functions
    
    // Center the map at a specific point
    private func centerMap() {
        let coordinate = CLLocationCoordinate2D(latitude: userMapPinData.latitude, longitude: userMapPinData.longitude)
        print(userMapPinData)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = userMapPinData.mapString
        addPointMapView.addAnnotation(annotation)
        addPointMapView.setRegion(MKCoordinateRegion.init(center: annotation.coordinate, span: .init(latitudeDelta: 1, longitudeDelta: 1)), animated: true)
    }
}
