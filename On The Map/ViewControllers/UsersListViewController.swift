//
//  UsersListViewController.swift
//  On The Map
//
//  Created by Yan Zverev on 7/20/16.
//  Copyright © 2016 Yan Zverev. All rights reserved.
//

import UIKit

class UsersListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AddUserToParseDelegate
{
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        refreshData()
    }
    
   private func refreshData()
    {
        UdacityUsersModel.sharedInstance.loadUsersData { (success, error) in
            guard (error == nil) else {
                dispatch_async(dispatch_get_main_queue(), {
                    let alertController = UIAlertController(title: "Error", message: error!.localizedDescription, preferredStyle: .Alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(alertController, animated: true, completion: nil)
                })
                return
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
        }
    }
    
    
    //MARK: Perform segue methods
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

    //MARK: Add User To Parse Delegate Methods
    func userAddedToParse()
    {
        refreshData()
    }
    func userCancel()
    {
        
    }
    
    
    @IBAction func logout(sender: UIBarButtonItem)
    {
       self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func refreshButtonPressed(sender: UIBarButtonItem)
    {
        refreshData()
    }
    
    
    //MARK UITableView Datasource and Delegates
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UdacityUsersModel.sharedInstance.getUsersCount()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCellWithIdentifier("userInfoCell", forIndexPath: indexPath)
        let udacityUser = UdacityUsersModel.sharedInstance.getUserForIndex(indexPath.row)
        cell.textLabel?.text = "\(udacityUser!.firstName) \(udacityUser!.lastName)"
        cell.imageView?.image = UIImage(imageLiteral: "pin.png")
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let udacityUser = UdacityUsersModel.sharedInstance.getUserForIndex(indexPath.row)
        print( "\(udacityUser!.firstName) \(udacityUser!.lastName) \(udacityUser!.objectID) \(udacityUser!.longitude)")
        if UIApplication.sharedApplication().canOpenURL(NSURL(string: udacityUser!.mediaURL)!) {
            UIApplication.sharedApplication().openURL(NSURL(string: udacityUser!.mediaURL)!)
        } else {
            let alertController = UIAlertController(title: "Error", message: "User didn't provide a Valid URL", preferredStyle: .Alert);
            alertController.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        
        
    }
}
