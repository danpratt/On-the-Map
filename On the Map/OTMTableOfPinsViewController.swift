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
    
    // Setup the view during first load
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.reloadData()
        OTMMapDataModel.mapModel().listDataUpdated = false
    }
    
    // Reload if user has updated the view
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // Reload the table if we have updated data to use
        if OTMMapDataModel.mapModel().listDataUpdated {
            self.tableView.reloadData()
            OTMMapDataModel.mapModel().listDataUpdated = false
        }
        
    }
    
    

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return (OTMMapDataModel.mapModel().mapData?.count)!
    }

    // Load up cell with data from tableData
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Get ready
        let cell = tableView.dequeueReusableCell(withIdentifier: "OTMDataCell", for: indexPath) as! OTMTableofPinsViewCell
        let data = OTMMapDataModel.mapModel().mapData?[indexPath.row]
        
        let name = { () -> String in
            if let first = data?.firstName, let last = data?.lastName {
                return ("\(first) \(last)")
            } else {
                return "Unkown Student"
            }
        }
        
        // Function to safely get URL
        let url = { () -> String in
            if let _ = data?.mediaURL {
                return data!.mediaURL!
            } else {
                return "No URL Provided"
            }
        }
        
        performUIUpdatesOnMain {
            
            // setup labels in cell
            cell.nameLabel.text = name()
            cell.webLabel.text = url()
        }
        
        return cell
    }

    // Launch URL when user taps on table row
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let data = OTMMapDataModel.mapModel().mapData?[indexPath.row]
        
        let app = UIApplication.shared
        if let toOpen = data?.mediaURL {
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
