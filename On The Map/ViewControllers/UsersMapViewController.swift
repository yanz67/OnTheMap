//
//  UsersMapViewController.swift
//  On The Map
//
//  Created by Yan Zverev on 7/20/16.
//  Copyright © 2016 Yan Zverev. All rights reserved.
//

import UIKit
import Foundation
import MapKit

class UsersMapViewController: UIViewController, MKMapViewDelegate, AddUserToParseDelegate
{

    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    var annotations = [MKPointAnnotation]()
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        refreshData()
    }
    


    
    @IBAction func refreshButtonPressed(sender: UIBarButtonItem)
    {
        refreshData()
    }
    
    func refreshData()
    {
        UdacityUsersModel.sharedInstance.loadUsersData { (success, error) in
            guard (error == nil) else {
                print("\(error)")
                dispatch_async(dispatch_get_main_queue(), {
                    let alertController = UIAlertController(title: "Error", message: error!.localizedDescription, preferredStyle: .Alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(alertController, animated: true, completion: nil)
                })
                return
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.removeAnnotations()
                self.reloadData()
            })
        }  
    }
    private func removeAnnotations()
    {
        mapView.removeAnnotations(annotations)
        annotations.removeAll()
    }
    
    func reloadData()
    {
        
        let udacityUsers = UdacityUsersModel.sharedInstance.udacityUsers
        for user in udacityUsers {
            let lat = CLLocationDegrees(user.latitude)
            let long = CLLocationDegrees(user.longitude)
            
            // The lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let first = user.firstName
            let last = user.lastName
            let mediaURL = user.mediaURL
            
            // Here we create the annotation and set its coordiate, title, and subtitle properties
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL
            
            // Finally we place the annotation in an array of annotations.
            annotations.append(annotation)
        }
        self.mapView.addAnnotations(annotations)
    }
    
    @IBAction func addUserToParse(sender: UIBarButtonItem)
    {
        performSegueWithIdentifier("AddUserToParse", sender: self)

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "AddUserToParse" {
            if let addUserToParseVC = segue.destinationViewController as? AddUserToParseViewController {
                addUserToParseVC.delegate = self
            }
        }
    }
    
    func userAddedToParse()
    {
        refreshData()
    }
    func userCancel()
    {
        
    }

    @IBAction func logOut(sender: UIBarButtonItem)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    // MARK: - MKMapViewDelegate
    
    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.redColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func showErrorURLAlert()
    {
        let alertController = UIAlertController(title: "Error", message: "User didn't provide a Valid URL", preferredStyle: .Alert);
        alertController.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            if let toOpen = view.annotation?.subtitle! {
                if let userURL = NSURL(string: toOpen) {
                    if app.canOpenURL(userURL) {
                        app.openURL(NSURL(string: toOpen)!)
                    } else {
                        showErrorURLAlert()
                    }
                } else {
                   showErrorURLAlert()
                }
            }
        }
    }

}
