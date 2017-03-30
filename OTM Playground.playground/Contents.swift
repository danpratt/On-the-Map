//: Playground - noun: a place where people can play

import UIKit
import MapKit
import CoreLocation
import PlaygroundSupport

// this line tells the Playground to execute indefinitely
PlaygroundPage.current.needsIndefiniteExecution = true

//var str = "Hello, playground"
//
//print("{\"udacity\": {\"username\": \"account@domain.com\", \"password\": \"********\"}}")
//
//let url = "https://parse.udacity.com/parse/classes/StudentLocation?where={\"uniqueKey\":\"1234\"}"
//let escapedURL:String! = url.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
//
//print(escapedURL)

let request = MKLocalSearchRequest()
request.naturalLanguageQuery = "Berlin, Germany"

let search = MKLocalSearch(request: request)

search.start { (response, error) in

    
    if error != nil {
        print("Error \(error.debugDescription)")
    } else {
        for item in response!.mapItems {
            print(item.name ?? "No Item")
            print(item.placemark.coordinate)
        }
    }
}

CLGeocoder().geocodeAddressString("Seattle, WA") { (placemark, error) in
    print(placemark ?? "Can't find it")
}

