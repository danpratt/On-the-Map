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
        
        let parameters = [OTMClient.Constants.ParameterKeys.Username: email, OTMClient.Constants.ParameterKeys.Password: password]
        
        let headerFields = [OTMClient.Constants.JSONParameterKeys.JSONApplication:OTMClient.Constants.JSONParameterKeys.Accept]
        
        _ = OTMClient.sharedInstance().taskForPOSTMethod(OTMClient.Constants.Methods.AuthenticateSessionNew, parameters: parameters, httpHeaderFields: headerFields) { (userID, error) in
            performUIUpdatesOnMain {
                if (userID != nil) {
                    print("Hello, World!")
                    self.loginActivity.stopAnimating()
                    self.loginButton.isEnabled = true
                }
                
                let httpHeaderFields = [OTMClient.Constants.ParameterKeys.ApplicationID:OTMClient.Constants.JSONParameterKeys.IDHeaderField, OTMClient.Constants.ParameterKeys.API_Key:OTMClient.Constants.JSONParameterKeys.APIHeaderField]
                
                OTMClient.sharedInstance().taskForGETMethod(OTMClient.Constants.Methods.StudentLocations, httpHeaderFields: httpHeaderFields, completionHandlerForGET: { (data, error) in
                    if (data != nil) {
                        print(NSString(data: data as! Data, encoding: String.Encoding.utf8.rawValue)!)
                    }
                    
                })

            }
            
        }
        
        
    }
    

}
