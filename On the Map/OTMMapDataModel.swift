//
//  OTMMapDataModel.swift
//  On the Map
//
//  Created by Daniel Pratt on 4/6/17.
//  Copyright © 2017 Daniel Pratt. All rights reserved.
//

import Foundation

// MARK: - OTMMapDataModel Class
class OTMMapDataModel {
    
    // MARK: - Properties
    
    // Map Data
    var mapData: [OTMMapData]? = nil
    
    // Update info
    var mapPinDataUpdated: Bool = false
    var listDataUpdated: Bool = false
    
    // MARK: Shared Instance
    
    class func mapModel() -> OTMMapDataModel {
        struct Singleton {
            static var sharedInstance = OTMMapDataModel()
        }
        return Singleton.sharedInstance
    }
    
}



