//
//  OTMAuthViewViewController.swift
//  On the Map
//
//  Created by Daniel Pratt on 3/16/17.
//  Copyright © 2017 Daniel Pratt. All rights reserved.
//

import UIKit

class OTMAuthViewViewController: UIViewController, UITextFieldDelegate {

    // MARK: Properties
    
    var username: String? = nil
    var password: String? = nil
    var session: URLSession!
    let Indicator = OTMActivityIndicator()
    var activity = UIActivityIndicatorView()
    var firstLoad = true
    
    // MARK: Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    // After logout, reset this view
    // We could do it in completeLogin(), but I prefer to do it here
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !firstLoad {
            viewDidLoad()
            loginButton.isEnabled = true
            emailTextField.text = ""
            passwordTextField.text = ""
        }
    }
    
    // MARK: Actions
    
    // This method is called when the user tapps the login button and begins the login process.
    @IBAction func loginButtonTapped(_ sender: Any) {
        
        username = emailTextField.text
        password = passwordTextField.text
        
        if Reachability.isConnectedToNetwork() {
            if username != "" && password != "" {
                activity = Indicator.StartActivityIndicator(obj: self, color: .white)
                OTMClient.sharedInstance().authenticateWithUdacity(self) { (success, errorString) in
                    performUIUpdatesOnMain {
                        self.Indicator.StopActivityIndicator(obj: self, indicator: self.activity)
                        if success {
                            self.completeLogin()
                        } else {
                            self.displayError(errorString ?? "NOERRORSTRING")
                        }
                    }
                }
            } else {
                displayError("BLANKFIELDS")
            }
        } else {
            showNetworkError()
        }
        
        

    }
    
    // MARK: - Private helper functions
    
    // Loads up the Nav Controller after the login is successful
    private func completeLogin() {
        self.firstLoad = false
        let controller = storyboard!.instantiateViewController(withIdentifier: "OTMNavController") as! UINavigationController
        present(controller, animated: true, completion: nil)
    }
    
    // Display an error depending on what the OTMConvenience methods throw back as us 
    // The login has failed for some reason
    private func displayError(_ error: String) {
        // let the user try again
        performUIUpdatesOnMain {
            self.loginButton.isEnabled = true
        }

        switch error {
        case "LOGIN":
            showLoginError()
        case "USERDATA":
            fallthrough
        case "MAPDATA":
            showNetworkError()
        default:
            showUnknownError()
        }
    }
    
    // ALERT: - Alert Creator Function
    
    // Creates error to let user know they need to check username / password
    private func showLoginError() {
        createAlertWithTitle("Login Error", message: "Please check your username and password", actionMessage: "OK", completionHandler: nil)
    }
    
    // Getting an error that is likely caused by network / udacity issue
    private func showNetworkError() {
        createAlertWithTitle("Network Error", message: "Unable to retrieve your user data.  Check your network connection and try again.", actionMessage: "OK", completionHandler: nil)
    }
    
    // Default error, if no error string is present
    private func showUnknownError() {
        createAlertWithTitle("Unknown Error", message: "Sorry, but an unknown error has occured, please try again.", actionMessage: "OK", completionHandler: nil)
    }

    
    // MARK: - Delegate Functions
    
    // Resign first responder and switch to password if on e-mail, start login if on password entry
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if emailTextField.isFirstResponder {
            passwordTextField.becomeFirstResponder()
        } else if passwordTextField.isFirstResponder {
            passwordTextField.resignFirstResponder()
            loginButtonTapped(self) // pretend we tapped the button to start the login process
        }
        
        return false
    }
    
    // If user taps out, we want the keyboard to go away, but we don't want to start the login
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.emailTextField.isFirstResponder {
            self.emailTextField.resignFirstResponder()
        } else if self.passwordTextField.isFirstResponder {
            self.passwordTextField.resignFirstResponder()
        }
    }

    

}
