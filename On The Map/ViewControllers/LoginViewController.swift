//
//  LoginViewController.swift
//  On The Map
//
//  Created by Yan Zverev on 7/19/16.
//  Copyright © 2016 Yan Zverev. All rights reserved.
//

import UIKit
import Foundation
import FBSDKLoginKit


class LoginViewController: UIViewController, FBSDKLoginButtonDelegate
{
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    var activityIndicator: UIActivityIndicatorView? = nil
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        loginButton.setTitle("Login", forState: .Normal)
        loginButton.enabled = true
        if UdacityClientManager.sharedInstance.isLoggedIn() {
            UdacityClientManager.sharedInstance.logoutFromUdacity { (success, error) in
                guard(error == nil) else {
                    print(error?.localizedDescription)
                    return;
                }
                print("Logged out successfully");
            }
            FBSDKAccessToken.setCurrentAccessToken(nil)
            FBSDKLoginManager().logOut()
            
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginButton.alpha = 1.0
        let loginButton = FBSDKLoginButton()
        loginButton.delegate = self
        //login button constraints
        view.addSubview(loginButton)
        let leadingConstraint = NSLayoutConstraint(item: loginButton, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1, constant: 50)
        let trailingConstraint = NSLayoutConstraint(item: loginButton, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1, constant: -50)
        let bottomConstraint = NSLayoutConstraint(item: loginButton, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: -30)
       
        view.addConstraints([leadingConstraint, trailingConstraint,  bottomConstraint])
        loginButton.translatesAutoresizingMaskIntoConstraints=false
        
        view.backgroundColor = UIColor(patternImage: UIImage(named: "LaunchImage.png")!)
        
        
    }

    @IBAction func loginWithUdacity(sender: UIButton)
    {
        let username = usernameTextField.text!
        let password = passwordTextField.text!
        
        if username == "" || password == "" {
            let alertController = UIAlertController(title: "Error", message: "Username or Password cannot be blank.", preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)

        } else {
            loginButton.setTitle("", forState: .Normal)
            sender.enabled = false
            activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
            activityIndicator?.center  = CGPointMake(sender.bounds.width / 2.0, sender.bounds.height / 2.0)
            sender.addSubview(activityIndicator!)
            activityIndicator?.startAnimating()
            
            UdacityClientManager.sharedInstance.authenticateWithUdacity(username, password: password) { (success, error) in
                if success == true {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.activityIndicator?.stopAnimating()
                        self.performSegueWithIdentifier("onTheMapSegue", sender: self)
                    })
                } else {
                    print("\(error?.localizedDescription)")
                    dispatch_async(dispatch_get_main_queue(), {
                        let alertController = UIAlertController(title: "Error", message: error!.localizedDescription, preferredStyle: .Alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                        self.presentViewController(alertController, animated: true, completion: nil)
                        self.activityIndicator?.stopAnimating()
                        self.loginButton.enabled = true
                        self.loginButton.setTitle("Login", forState: .Normal)
                    })
                    
                    
                }
                
            }
        }

    }
    
    
    
    //MARK: Facebook login delegates
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        UdacityClientManager.sharedInstance.authenticateWithUdacityWithFacebook(FBSDKAccessToken.currentAccessToken().tokenString) { (success, error) in
                guard(error == nil) else {
                    print("can't login to udacity with facebook")
                    return
                }
            dispatch_async(dispatch_get_main_queue(), {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let secondViewController = storyboard.instantiateViewControllerWithIdentifier("tabBarController") as! UITabBarController
                self.presentViewController(secondViewController, animated: true, completion: nil)
            })
        }
      
        
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("logged out")
    }
    
}
