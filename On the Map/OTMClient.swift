//
//  OTMClient.swift
//  On the Map
//
//  Created by Daniel Pratt on 3/16/17.
//  Copyright © 2017 Daniel Pratt. All rights reserved.
//

import UIKit

// MARK: = OTMClient: NSObject

class OTMClient: NSObject {
    
    // MARK: Properties
    
    var session = URLSession.shared
    var sessionID: String? = nil
    var userID: String? = nil
    var firstName: String? = nil
    var lastName: String? = nil
    
    var mapPinData: [OTMMapData]? = nil
    
    // Stored hostVieController to get UN/ PW
    var hostViewController: OTMAuthViewViewController!
    
    // MARK: GET
    func taskForGETMethod(_ method: String, parameters: String? = nil, httpHeaderFields: [String:String]? = nil, completionHandlerForGET: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
    
        // Create method var to use in case there are params
        var method = method
        // Setup parameters
        if parameters != nil {
            method.append("/\(String(describing: parameters))")
        }
        
        // Build request for task
        var request = URLRequest(url: URL(string: method)!)
        if httpHeaderFields != nil {
            for (key, value) in httpHeaderFields! {
                request.addValue(key, forHTTPHeaderField: value)
            }
        }
        
        // Create task
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
            // error method
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGET(nil, NSError(domain: "taskForGETMethod: \(method)", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(String(describing: error))")
                return
            }
            
            /* GUARD: Did we get a successful 200 response? */
            guard let statusCode = ((response as? HTTPURLResponse)?.statusCode) else {
                sendError("Your request returned an invalid status code")
                return
            }
            
            print("GET status code: \(statusCode)")
            
            // Check statusCode for other failures
            // check username/password
            // check invalid url
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            // Put data into a var, we might need to shave some characters in some cases
            var newData = data
            
            // The only method that requires us to change data has httpHeaderFields, so check to see if that is nil
            if httpHeaderFields == nil {
                newData = self.removeFirstFiveCharactersFrom(data: data)
            }
            
            self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForGET)
            
        }
        task.resume()
        return task
    }
    
    // MARK: POST
    
    func taskForPOSTMethod(_ method: String, parameters: [String:String], httpHeaderFields: [String:String],completionHandlerForPOST: @escaping (_ result: NSDictionary?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        // Setup parameters
        let parentParameters = "{\"\(OTMClient.Constants.ParameterKeys.Udacity)\": {"
        let parameters = OTMParametersFromDictionary(parameters, withParent: parentParameters)
        
        // Build request for task
        var request = URLRequest(url: URL(string: method)!)
        request.httpMethod = Constants.HTTPMethods.Post
        request.addValue(OTMClient.Constants.JSONParameterKeys.JSONApplication, forHTTPHeaderField: OTMClient.Constants.JSONParameterKeys.Content)
        for (key, value) in httpHeaderFields {
            request.addValue(key, forHTTPHeaderField: value)
        }
        request.httpBody = parameters
        
        // Create task
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForPOST(nil, NSError(domain: "taskForPOSTMethod: \(method)", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(String(describing: error))")
                return
            }
            
            /* GUARD: Did we get a successful 200 response? */
            guard let statusCode = ((response as? HTTPURLResponse)?.statusCode), statusCode == 200 else {
                sendError("Your request returned an invalid status code")
                return
            }
            
            // Check statusCode for other failures
            // check username/password
            // check invalid url
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            let newData = self.removeFirstFiveCharactersFrom(data: data)
            self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForPOST)
        }
        
        // Start the request
        task.resume()
        
        return task
    }
    
    // MARK: PUT
    func taskForPUTMethod(_ method: String, withObjectID objectID: String, parameters: [String:String], httpHeaderFields: [String:String], completionHandlerForPUT: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        // Create a URL using the objectID
        let urlString = method + "/" + objectID
        
        // Setup parameters
        let parameters = OTMParametersFromDictionary(parameters)
        
        // Create the request
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = Constants.HTTPMethods.Put
        request.addValue(OTMClient.Constants.JSONParameterKeys.JSONApplication, forHTTPHeaderField: OTMClient.Constants.JSONParameterKeys.Content)
        for (key, value) in httpHeaderFields {
            request.addValue(key, forHTTPHeaderField: value)
        }
        request.httpBody = parameters
        
        // Create the task
        let task = session.dataTask(with: request) { data, response, error in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForPUT(nil, NSError(domain: "taskForPOSTMethod: \(method)", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(String(describing: error))")
                return
            }
            
            /* GUARD: Did we get a successful 200 response? */
            guard let statusCode = ((response as? HTTPURLResponse)?.statusCode), statusCode == 200 else {
                sendError("Your request returned an invalid status code")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            completionHandlerForPUT(data as AnyObject, nil)
        }
        
        
        task.resume()
        return task
    }
    
    // MARK: Delete
    
    func taskForDELETEMethod(_ method: String, completionHandlerForDELETE: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        let request = NSMutableURLRequest(url: URL(string: method)!)
        request.httpMethod = Constants.HTTPMethods.Delete
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            // Error handler function
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForDELETE(nil, NSError(domain: "taskForPOSTMethod: \(method)", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(String(describing: error))")
                return
            }
            
            /* GUARD: Did we get a successful 200 response? */
            guard let statusCode = ((response as? HTTPURLResponse)?.statusCode), statusCode == 200 else {
                sendError("Your request returned an invalid status code")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            completionHandlerForDELETE(self.removeFirstFiveCharactersFrom(data: data) as AnyObject, nil)
        }
        task.resume()
        
        return task
    }
    
    // MARK: Private helper functions
    
    // create a URL from parameters
    private func OTMParametersFromDictionary(_ parameters: [String:String], withParent parent: String? = nil) -> Data {
        
        var paramsToReturn: String!
        
        if parent == nil {
            paramsToReturn = ""
        } else {
            paramsToReturn = parent
        }
        
        
        for (key, value) in parameters {
            paramsToReturn.append("\"\(key)\": \"\(value)\", ")
        }
        
        // Get rid of the extra comma and space
        paramsToReturn.characters.removeLast()
        paramsToReturn.characters.removeLast()
        // Add closing brackets
        if parent == nil {
            paramsToReturn.append("}")
        } else {
            paramsToReturn.append("}}")
        }
        
        return paramsToReturn.data(using: String.Encoding.utf8)!
    }
    
    // Shave first five characters from response
    private func removeFirstFiveCharactersFrom(data: Data) -> Data {
        let range = Range(5 ..< data.count)
        let newData = data.subdata(in: range) /* subset response data! */
        return newData
    }
    
    // given raw JSON, return a usable Foundation object
    private func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: NSDictionary?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSDictionary
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(parsedResult as! NSDictionary?, nil)
    }
    
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> OTMClient {
        struct Singleton {
            static var sharedInstance = OTMClient()
        }
        return Singleton.sharedInstance
    }
    
}
