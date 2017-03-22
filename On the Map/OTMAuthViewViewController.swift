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
        
        _ = OTMClient.sharedInstance().taskForPOSTMethod(OTMClient.Constants.Methods.AuthenticateSessionNew, parameters: parameters) { (success, error) in
            performUIUpdatesOnMain {
                print("Hello, World!")
                self.loginActivity.stopAnimating()
                self.loginButton.isEnabled = true
            }
            
        }
        
        
    }
    

}
