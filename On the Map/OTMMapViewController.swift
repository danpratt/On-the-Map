//
//  MapViewController.swift
//  On the Map
//
//  Created by Daniel Pratt on 3/16/17.
//  Copyright © 2017 Daniel Pratt. All rights reserved.
//

import UIKit
import MapKit

class OTMMapViewController: UIViewController, MKMapViewDelegate {
    
    // MARK: Properties
    var annotations = [MKPointAnnotation]()

    // Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMapPins()
        
        // If an existing entry from previous session is found from the user, center the map there
        if let userLocation = OTMMapDataModel.mapModel().userLocation {
            mapView.setRegion(MKCoordinateRegion.init(center: userLocation, span: .init(latitudeDelta: 1, longitudeDelta: 1)), animated: true)
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Reload if the map was updated
        if OTMMapDataModel.mapModel().mapPinDataUpdated {
            loadMapPins()
            if let userLocation = OTMMapDataModel.mapModel().userLocation {
                mapView.setRegion(MKCoordinateRegion.init(center: userLocation, span: .init(latitudeDelta: 1, longitudeDelta: 1)), animated: true)
            }
            
            OTMMapDataModel.mapModel().mapPinDataUpdated = false
        }
    }
    
    
    
    // MARK: - Private Helper Functions
    
    private func loadMapPins() {
        createAnnotations()
        mapView.addAnnotations(annotations)
    }

    private func createAnnotations() {
        // While writing this, somehow a student named Michael Stram managed to upload nil coordinates
        // This makes sure we don't crash and just ignores these
        
        // Make sure that there is mapModel data
        if OTMMapDataModel.mapModel().mapData != nil {
            for map in OTMMapDataModel.mapModel().mapData! {
                
                let latitude = CLLocationDegrees(map.latitude)
                let longitude = CLLocationDegrees(map.longitude)
                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                
                if let first = map.firstName, let last = map.lastName {
                    annotation.title = "\(first) \(last)"
                } else {
                    annotation.title = "No Name"
                }
                
                if let url = map.mediaURL {
                    annotation.subtitle = url
                }
                annotations.append(annotation)
                
            }
        }
    }
    
    // MARK: - MKMapViewDelegate
    
    // Add Pin view to make pins clickable
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.blue
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
                if !toOpen.contains("http") && !toOpen.contains(" ") {
                    let url = "http://" + toOpen
                    app.open(URL(string: url)!)

                } else if !toOpen.contains(" ") {
                    app.open(URL(string: toOpen)!)
                }
            } else {
                print("Invalid URL")
                createAlertWithTitle("Error", message: "Unable to open URL because it is not valid.", actionMessage: "OK", completionHandler: nil)
            }
        }
    }

    
}
