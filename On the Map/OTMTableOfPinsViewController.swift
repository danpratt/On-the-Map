//
//  PinLocationsViewController.swift
//  On the Map
//
//  Created by Daniel Pratt on 3/16/17.
//  Copyright © 2017 Daniel Pratt. All rights reserved.
//

import UIKit
import MapKit

class OTMTableOfPinsViewController: UITableViewController {
    
    // MARK: - Properties
    
    // Model
    var tableData = [OTMMapData]()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tableData = OTMClient.sharedInstance().mapPinData!
        self.tableView.reloadData()
    }
    

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tableData.count
    }

    // Load up cell with data from tableData
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Get ready
        let cell = tableView.dequeueReusableCell(withIdentifier: "OTMDataCell", for: indexPath) as! OTMTableofPinsViewCell
        let data = tableData[indexPath.row]
        
        // Function to safely get name
        let name = { () -> String in 
            if let first = data.firstName, let last = data.lastName {
                return ("\(first) \(last)")
            } else {
                return "Unkown Student"
            }
        }
        
        // Function to safely get URL
        let url = { () -> String in
            if let _ = data.mediaURL {
                return data.mediaURL!
            } else {
                return "No URL Provided"
            }
        }
        
        // create location for map
        let location = CLLocationCoordinate2D(latitude: data.latitude, longitude: data.longitude)
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = name()
        
        // setup map in cell
        cell.mapView.addAnnotation(annotation)
        cell.mapView.setRegion(MKCoordinateRegion.init(center: annotation.coordinate, span: .init(latitudeDelta: 2, longitudeDelta: 2)), animated: true)
        
        // setup labels in cell
        cell.nameLabel.text = name()
        cell.webLabel.text = url()

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let data = tableData[indexPath.row]
        
        let app = UIApplication.shared
        if let toOpen = data.mediaURL {
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
