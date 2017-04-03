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
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    // MARK: Actions
    
    // This method is called when the user tapps the login button and begins the login process.
    @IBAction func loginButtonTapped(_ sender: Any) {
        
        username = emailTextField.text
        password = passwordTextField.text
        
        if username != "" && password != "" {
            
            OTMClient.sharedInstance().authenticateWithUdacity(self) { (success, errorString) in
                performUIUpdatesOnMain {
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

    }
    
    private func completeLogin() {
        let controller = storyboard!.instantiateViewController(withIdentifier: "OTMNavController") as! UINavigationController
        present(controller, animated: true, completion: nil)
    }
    
    private func displayError(_ error: String) {
        // Stop the animation and let the user try again
        performUIUpdatesOnMain {
            self.loginActivity.stopAnimating()
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
    
    // Creates the alert view
    private func createAlertWithTitle(_ title: String, message: String, actionMessage: String? = nil, completionHandler: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if let actionMessage = actionMessage {
            let action = UIAlertAction(title: actionMessage, style: .default, handler: completionHandler)
            alert.addAction(action)
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    // Creates error to let user know they need to check username / password
    private func showLoginError() {
        createAlertWithTitle("Login Error", message: "Please check your username and password", actionMessage: "OK", completionHandler: nil)
    }
    
    private func showNetworkError() {
        createAlertWithTitle("Network Error", message: "Unable to retrieve your user data.  Check your network connection and try again.", actionMessage: "OK", completionHandler: nil)
    }
    
    // Default error, if no error string is present
    private func showUnknownError() {
        createAlertWithTitle("Unknown Error", message: "Sorry, but an unknown error has occured, please try again.", actionMessage: "OK", completionHandler: nil)
    }

    
    // MARK: - Delegate Functions
    
    // Clear text entry when user clicks into field
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.text = ""
        return true
    }

    

}
