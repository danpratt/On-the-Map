//
//  OTMAuthViewViewController.swift
//  On the Map
//
//  Created by Daniel Pratt on 3/16/17.
//  Copyright © 2017 Daniel Pratt. All rights reserved.
//

import UIKit

class OTMAuthViewViewController: UIViewController {

    // MARK: Properties
    
//    var urlRequest: URLRequest? = nil
//    var requestToken: String? = nil
//    var completionHandlerForView: ((_ success: Bool, _ errorString: String?) -> Void)? = nil
    var session = URLSession.shared
    
    // MARK: Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginActivity: UIActivityIndicatorView!
    
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginActivity.stopAnimating()
    }
    
    // MARK: Actions
    
    // This method is called when the user tapps the login button and begins the login process.
    @IBAction func loginButtonTapped(_ sender: Any) {
        loginActivity.startAnimating()
        loginButton.isEnabled = false
        
        func sendError(_ error: String) {
            print(error)
            let userInfo = [NSLocalizedDescriptionKey : error]
            let _ = NSError(domain: "Login", code: 1, userInfo: userInfo)
        }
        
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            sendError("Unable to get email / password")
            return
        }
        
        // Start a session
        var request = URLRequest(url: URL(string: OTMClient.Constants.Methods.AuthenticateSessionNew)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}".data(using: .utf8)
        
        let task = session.dataTask(with: request) { data, response, error in
         
            if error != nil { // Handle error…
                return
            }
            let range = Range(5 ..< data!.count)
            let newData = data?.subdata(in: range) /* subset response data! */
            print(NSString(data: newData!, encoding: String.Encoding.utf8.rawValue)!)
            performUIUpdatesOnMain({ 
                self.loginActivity.stopAnimating()
            })
            
        }
        
        task.resume()
        
    }
    

}
