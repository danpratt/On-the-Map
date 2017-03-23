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
    var username: String? = nil
    var password: String? = nil
    var session: URLSession!
    
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
        
        username = emailTextField.text
        password = passwordTextField.text
        
        print("Username: \(username)")
        print("Password: \(password)")
        
        if username != "" && password != "" {
            
            OTMClient.sharedInstance().authenticateWithUdacity(self) { (success, errorString) in
                performUIUpdatesOnMain {
                    if success {
                        self.completeLogin()
                    } else {
                        self.displayError(errorString ?? "No error string found")
                    }
                }
            }
        } else {
            displayError("Username and password fields cannot be blank")
        }

    }
    
    private func completeLogin() {
        print("Hello, World!")
    }
    
    private func displayError(_ error: String) {
        print(error)
    }
    

}
