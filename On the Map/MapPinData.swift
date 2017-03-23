//
//  MapPinData.swift
//  On the Map
//
//  Created by Daniel Pratt on 3/23/17.
//  Copyright © 2017 Daniel Pratt. All rights reserved.
//

// MARK: MapPinData Struct

struct OTMMapData {
    
    // MARK: Properties
    
    let objectID: String?
    let uniqueKey: String?
    let firstName: String?
    let lastName: String?
    let mapString: String? // The location string used for geocoding the student location
    let mediaURL: String? // URL Provided by student
    let latitude: Double
    let longitude: Double
    
    // MARK: Init
    
    init(dictionary: [String:AnyObject]) {
        objectID = dictionary[OTMClient.Constants.JSONMapResponseKeys.ObjectID] as? String
        uniqueKey = dictionary[OTMClient.Constants.JSONMapResponseKeys.Key] as? String
        firstName = dictionary[OTMClient.Constants.JSONMapResponseKeys.NameFirst] as? String
        lastName = dictionary[OTMClient.Constants.JSONMapResponseKeys.NameLast] as? String
        mapString = dictionary[OTMClient.Constants.JSONMapResponseKeys.MapString] as? String
        mediaURL = dictionary[OTMClient.Constants.JSONMapResponseKeys.MediaURL] as? String
        latitude = dictionary[OTMClient.Constants.JSONMapResponseKeys.Latitude] as! Double
        longitude = dictionary[OTMClient.Constants.JSONMapResponseKeys.Longitude] as! Double
    }
    
    static func mapDataFromDictionaries(_ dictionaries:[[String:AnyObject]]) -> [OTMMapData] {
        var mapData = [OTMMapData]()
        
        // Iterate through the data and create map data objects
        for dictionary in dictionaries {
            mapData.append(OTMMapData(dictionary: dictionary))
        }
        
        return mapData
    }
    
}
