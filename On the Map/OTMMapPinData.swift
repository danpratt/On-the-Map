//
//  MapPinData.swift
//  On the Map
//
//  Created by Daniel Pratt on 3/23/17.
//  Copyright © 2017 Daniel Pratt. All rights reserved.
//

// MARK: MapPinData Struct

import Foundation
import MapKit

struct OTMMapData {
    
    // MARK: Properties
    
    var objectID: String?
    let uniqueKey: String?
    let firstName: String?
    let lastName: String?
    let mapString: String? // The location string used for geocoding the student location
    var mediaURL: String? // URL Provided by student
    let latitude: Double
    let longitude: Double
    var hasNilCoord: Bool = false
    var updatedAt: String?
    
    // MARK: Init
    
    init(dictionary: [String:AnyObject]) {
        objectID = dictionary[OTMClient.Constants.JSONMapResponseKeys.ObjectID] as? String
        uniqueKey = dictionary[OTMClient.Constants.JSONMapResponseKeys.Key] as? String
        firstName = dictionary[OTMClient.Constants.JSONMapResponseKeys.NameFirst] as? String
        lastName = dictionary[OTMClient.Constants.JSONMapResponseKeys.NameLast] as? String
        mapString = dictionary[OTMClient.Constants.JSONMapResponseKeys.MapString] as? String
        mediaURL = dictionary[OTMClient.Constants.JSONMapResponseKeys.MediaURL] as? String
        updatedAt = dictionary[OTMClient.Constants.JSONMapResponseKeys.UpdatedDate] as? String
        if let lat = dictionary[OTMClient.Constants.JSONMapResponseKeys.Latitude] as? Double {
            
            latitude = lat
        } else {
            hasNilCoord = true
            latitude = 0.0
        }
        if let long = dictionary[OTMClient.Constants.JSONMapResponseKeys.Longitude] as? Double {
            longitude = long
        } else {
            
            hasNilCoord = true
            longitude = 0.0
        }
    }
    
    // Add a URL if none exists yet
    // May remove the condition and allow it to always be overwritten
    mutating func addURL(_ url: String) -> Bool {
        if self.mediaURL == nil {
            self.mediaURL = url
            return true
        } else {
            return false
        }
    }
    
    // Static function to create an array of all map data dictionaries
    static func mapDataFromDictionaries(_ dictionaries:[[String:AnyObject]]) -> [OTMMapData] {
        var mapData = [OTMMapData]()
        // Iterate through the data and create map data objects
        for dictionary in dictionaries {
            var append = true
            
            // check to make sure there is data
            // while I was writing this, somehow a student named Michael Stram managed to upload nil longitude coordinates which caused a crash
            // This makes sure we don't crash and just ignores these
            if let latitude = dictionary[OTMClient.Constants.JSONMapResponseKeys.Latitude] as? Double, let longitude = dictionary[OTMClient.Constants.JSONMapResponseKeys.Longitude] as? Double {
                // to reduce code, we can just check here
                if dictionary[OTMClient.Constants.JSONMapResponseKeys.Key] as? String == OTMClient.sharedInstance().userID {
                    OTMClient.sharedInstance().usersExistingObjectID = dictionary[OTMClient.Constants.JSONMapResponseKeys.ObjectID] as? String
                    OTMClient.sharedInstance().userLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                }
            } else {
                append = false
            }
            
            if append {
                mapData.append(OTMMapData(dictionary: dictionary))
            }
            
        }
        
        return mapData
    }
    
    
}
