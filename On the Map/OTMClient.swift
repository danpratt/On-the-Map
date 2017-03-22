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
    
    // MARK: POST
    
    func taskForPOSTLogin(_ method: String, parameters: [String:String], completionHandlerForLogin: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        // Setup parameters
        let parameters = OTMParametersFromDictionary(parameters)
        
        // Build request for task
        var request = URLRequest(url: URL(string: method)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = parameters
        
        /* 4. Make the request */
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForLogin(nil, NSError(domain: "taskForPOSTLogin", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = ((response as? HTTPURLResponse)?.statusCode), statusCode == 200 else {
                sendError("Your request returned an invalid status code")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            let range = Range(5 ..< data.count)
            let newData = data.subdata(in: range) /* subset response data! */
//            print(NSString(data: newData, encoding: String.Encoding.utf8.rawValue)!)
            var accountJSONParsed: AnyObject! = nil
            do {
                accountJSONParsed = try JSONSerialization.jsonObject(with: newData, options: .allowFragments) as AnyObject
            } catch {
                completionHandlerForLogin(nil, NSError(domain: "JSONSerialization", code: 9, userInfo: [NSLocalizedDescriptionKey : error]))
            }
            print(accountJSONParsed)
            
            let accountDictionary = accountJSONParsed[Constants.JSONResponseKeys.Account] as AnyObject
            print(accountDictionary)
            let ID = accountDictionary[Constants.JSONResponseKeys.UserID]!
            print(ID!)
            completionHandlerForLogin("hello" as AnyObject, nil)
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    // MARK: Private functions
    
    // create a URL from parameters
    private func OTMParametersFromDictionary(_ parameters: [String:String], withPathExtension: String? = nil) -> Data {
        
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
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> OTMClient {
        struct Singleton {
            static var sharedInstance = OTMClient()
        }
        return Singleton.sharedInstance
    }
    
}
