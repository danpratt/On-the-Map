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
    
    // MARK: GET
    func taskForGETMethod(_ method: String, parameters: String? = nil, httpHeaderFields: [String:String]? = nil, completionHandlerForGET: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
    
        // Create method var to use in case there are params
        var method = method
        // Setup parameters
        if parameters != nil {
            method.append("/\(parameters)")
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
                sendError("There was an error with your request: \(error)")
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
            
            completionHandlerForGET(newData as AnyObject?, nil)
        }
        task.resume()
        return task
    }
    
    // MARK: POST
    
    func taskForPOSTMethod(_ method: String, parameters: [String:String], httpHeaderFields: [String:String],completionHandlerForPOST: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        // Setup parameters
        let parameters = OTMPOSTParametersFromDictionary(parameters)
        
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
                sendError("There was an error with your request: \(error)")
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
//            print(NSString(data: newData, encoding: String.Encoding.utf8.rawValue)!)
            var accountJSONParsed: AnyObject! = nil
            do {
                accountJSONParsed = try JSONSerialization.jsonObject(with: newData, options: .allowFragments) as AnyObject
            } catch {
                completionHandlerForPOST(nil, NSError(domain: "JSONSerialization", code: 9, userInfo: [NSLocalizedDescriptionKey : error]))
            }
            print(accountJSONParsed)
            
            let accountDictionary = accountJSONParsed[Constants.JSONResponseKeys.Account] as AnyObject
            print(accountDictionary)
            let ID = accountDictionary[Constants.JSONResponseKeys.UserID]!
            print(ID!)
            completionHandlerForPOST(ID! as AnyObject, nil)
        }
        
        // Start the request
        task.resume()
        
        return task
    }
    
    // MARK: Private functions
    
    // create a URL from parameters
    private func OTMPOSTParametersFromDictionary(_ parameters: [String:String], withPathExtension: String? = nil) -> Data {
        
        var paramsToReturn: String = "{\"\(OTMClient.Constants.ParameterKeys.Udacity)\": {"
        
        for (key, value) in parameters {
            paramsToReturn.append("\"\(key)\": \"\(value)\", ")
        }
        
        // Get rid of the extra comma and space
        paramsToReturn.characters.removeLast()
        paramsToReturn.characters.removeLast()
        // Add closing brackets
        paramsToReturn.append("}}")
        print(paramsToReturn)
        return paramsToReturn.data(using: String.Encoding.utf8)!
    }
    
    // Shave first five characters from response
    private func removeFirstFiveCharactersFrom(data: Data) -> Data {
        let range = Range(5 ..< data.count)
        let newData = data.subdata(in: range) /* subset response data! */
        return newData
    }
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> OTMClient {
        struct Singleton {
            static var sharedInstance = OTMClient()
        }
        return Singleton.sharedInstance
    }
    
}
