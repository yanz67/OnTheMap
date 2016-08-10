//
//  AddUserToParseViewController.swift
//  On The Map
//
//  Created by Yan Zverev on 7/21/16.
//  Copyright © 2016 Yan Zverev. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation
import MapKit

class AddUserToParseViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate
{

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var myURLTextField: UITextField!
    
    @IBOutlet weak var updateLocationButton: UIButton!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    var isNewUser: Bool? = false
    var udacityUser: UdacityUser?
    let locationManager: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocation? = nil
    var delegate: AddUserToParseDelegate? = nil
    var currentAnnotation: MKPointAnnotation? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        myURLTextField.delegate = self
        locationTextField.delegate = self
        
        UdacityClientManager.sharedInstance.getStudentLocationFromParse { (studentInfo, studentFound, error) in
            guard (error == nil) else {
                print("\(error?.localizedDescription)")
                dispatch_async(dispatch_get_main_queue(), {
                    let alertController = UIAlertController(title: "Error", message: error!.localizedDescription, preferredStyle: .Alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(alertController, animated: true, completion: {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    })
                    
                })
                return
            }
            
            if studentFound {
                dispatch_async(dispatch_get_main_queue(), {
                    self.udacityUser = UdacityUser(userInformation: studentInfo!)
                    self.loadStudentInfo()
                })
            } else {
                self.isNewUser = true;
                self.locationManager.delegate = self
                self.locationManager.requestWhenInUseAuthorization()
                if CLLocationManager.locationServicesEnabled() {
                    self.locationManager.startUpdatingLocation();
                }

            }
            
        }
    }
    
    private func setAnnotationOnMap(latitude: Double, longitude: Double) -> Void
    {
        let coord = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.1,longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: coord, span: span)
        if let currentAnnotation = currentAnnotation {
            mapView.removeAnnotation(currentAnnotation)
        }
        currentAnnotation = MKPointAnnotation()
        if let currentAnnotation = currentAnnotation {
            currentAnnotation.coordinate = coord
            mapView.setRegion(region, animated: true)
            mapView.addAnnotation(currentAnnotation)
        }
       
    }
    
    private func loadStudentInfo()
    {
        firstNameTextField.text = udacityUser!.firstName
        lastNameTextField.text = udacityUser!.lastName
        myURLTextField.text = udacityUser!.mediaURL
        locationTextField.text = udacityUser!.mapString
        currentLocation = CLLocation(latitude: udacityUser!.latitude, longitude: udacityUser!.longitude)
        setAnnotationOnMap(udacityUser!.latitude, longitude: udacityUser!.longitude);
       
    }
    
    @IBAction func updateLocation(sender: UIButton)
    {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .White);
        let buttonBounds = updateLocationButton.bounds
        activityIndicator.center = CGPointMake(buttonBounds.width/2.0, buttonBounds.height/2.0)
        updateLocationButton.setTitle("", forState: .Normal)
        updateLocationButton.addSubview(activityIndicator)
        updateLocationButton.enabled = false
        activityIndicator.startAnimating()
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(locationTextField.text!) { (placeMarks, error) in
            if error == nil {
                let placeMark = placeMarks!.first
                dispatch_async(dispatch_get_main_queue(), {
                    if let placeMark = placeMark {
                        self.currentLocation = placeMark.location
                        self.setAnnotationOnMap(self.currentLocation!.coordinate.latitude, longitude: self.currentLocation!.coordinate.longitude)
                    }
                    activityIndicator.stopAnimating()
                    self.updateLocationButton.enabled = true
                    self.updateLocationButton.setTitle("Update Location", forState: .Normal)
                });
                
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    activityIndicator.stopAnimating()
                    self.updateLocationButton.enabled = true
                    self.updateLocationButton.setTitle("Update Location", forState: .Normal)
                    let alertController = UIAlertController(title: "Error", message: "Location not found.", preferredStyle: .Alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(alertController, animated: true, completion: nil)
                })
            }
        }
    }
    
    @IBAction func submitInfo(sender: UIBarButtonItem)
    {
        if firstNameTextField.text == "" || lastNameTextField == "" {
            let alertController = UIAlertController(title: "Error", message: "Fill in all the fields", preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        } else {
            var userDictionary = [ParseUserInfoKeys.FirstName : firstNameTextField.text!,
                                  ParseUserInfoKeys.LastName : lastNameTextField.text!,
                                  ParseUserInfoKeys.Latitude : currentLocation!.coordinate.latitude,
                                  ParseUserInfoKeys.Longitude : currentLocation!.coordinate.longitude,
                                  ParseUserInfoKeys.MapString : locationTextField.text!,
                                  ParseUserInfoKeys.MediaURL : myURLTextField.text!,
                                  ParseUserInfoKeys.UniqueKey : UdacityClientManager.sharedInstance.udacityUserID!
            ] as [String:AnyObject]
            
            if (self.isNewUser == true) {
                UdacityClientManager.sharedInstance.postSudentLocationToParse(userDictionary, completionHandlerForPostStudentLocationToParse: { (success, error) in
                    if success {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.showSubmissionStatus( "User Info Added.", message: "Thank You!", dismissMainViewController: true)
                        })
                    } else {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.showSubmissionStatus("Error.", message: "Couldn't update info", dismissMainViewController: false)
                        })
                    }
                })
            

            } else {
                userDictionary[ParseUserInfoKeys.ObjectID] = udacityUser!.objectID
                UdacityClientManager.sharedInstance.updateStudentLocationToParse(userDictionary, completionHandlerForUpdateSudentLocationToParse: { (success, error) in
                    if success {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.showSubmissionStatus( "User Info Updated.", message: "Thank You!", dismissMainViewController: true)
                        })
                    } else {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.showSubmissionStatus("Error.", message: "Couldn't update info", dismissMainViewController: false)
                        })
                    }
                })
            }
        }
    }
    @IBAction func cancel(sender: UIBarButtonItem)
    {
        
        self.dismissViewControllerAnimated(true, completion: nil)

    }
    
    //MARK: Alertview after submissin
    
    func showSubmissionStatus(title: String, message: String, dismissMainViewController: Bool)
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: {(UIAlertAction) in
            if dismissMainViewController {
                self.dismissViewControllerAnimated(true, completion: nil)
                if let delegate = self.delegate {
                    delegate.userAddedToParse()
                }
            }
        }))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool // called when 'return' key pressed. return false to ignore.
    {
        textField.resignFirstResponder()
        return true
    }
    
}
