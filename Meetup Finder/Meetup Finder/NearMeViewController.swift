//
//  NearMeViewController.swift
//  Meetup Finder
//
//  Created by Paula Ivic on 9/23/15.
//  Copyright © 2015 Paula Ivic. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class NearMeViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, UIViewControllerPreviewingDelegate {

    @IBOutlet weak var tableView: UITableView!     //Table view to display the open events
    
    var locationManager : CLLocationManager!       //Location manager
    var events:NSArray = NSArray()                 //Array to store the events
    var isRefreshingData:Bool = false              //Flag to check if we are refreshing data in the tableview
    var isLocationUpdated:Bool = false             //Flag to avoid multiple request calls when updating the location
    var feedRefreshControl:UIRefreshControl!       //UIRefreshControl
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Utils.isValid(ApplicationConfiguration.sharedInstance.wsAPIKey) == false {
            fatalError("Please add the meetup.com API Key in config.plist -> wsAPIKey")
        }
        
        //Register view for 3D touch if available
        self.registerFor3DTouch()

        //Get user's location
        self.updateLocation()
        
        definesPresentationContext = true
        
        self.tabBarController?.tabBar.userInteractionEnabled = false
        
        //Adding refresh control to update results on table view
        feedRefreshControl = UIRefreshControl()
        feedRefreshControl.backgroundColor = UIColor.clearColor()
        feedRefreshControl.addTarget(self, action: "refreshFeedWithControl:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(feedRefreshControl)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.events = DataManager.sharedInstance.events
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
    }
    
    func refreshFeedWithControl(sender: UIRefreshControl) {
        self.isRefreshingData = true
        self.updateLocation()
    }
    
    func stopFeedRefreshControl(){
        self.isRefreshingData = false;
        self.feedRefreshControl.endRefreshing()
        self.tableView.setContentOffset(CGPointMake(0, 0), animated: true)
    }
    
    func registerFor3DTouch(){
        // register view for 3D Touch (if available)
        if traitCollection.forceTouchCapability == .Available {
            registerForPreviewingWithDelegate(self, sourceView: view)
        } else { print("3D Touch is not available on this device.") }
    }
    
    
    /**
    * Updates user's location
    */
    func updateLocation(){
        
        self.isLocationUpdated = false
        
        if(self.isRefreshingData == false){
            self.showLoading()
        }
        
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter=10.0;
        locationManager.delegate = self
        
        //Check permission to get location from device
        let status = CLLocationManager.authorizationStatus()
        if status == .NotDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if status == CLAuthorizationStatus.AuthorizedWhenInUse
            || status == CLAuthorizationStatus.AuthorizedAlways {
                locationManager.startUpdatingLocation()
        } else {
            showNoPermissionsAlert()
        }
    }
    
    /**
    * Shows error message when there is no permission to get location from device
    */
    func showNoPermissionsAlert() {
        if self.presentedViewController == nil {
            let alertController = UIAlertController(title: "No permission", message: "In order to work, the app needs your location", preferredStyle: .Alert)
            let openSettings = UIAlertAction(title: "Open settings", style: .Default, handler: {
                (action) -> Void in
                let URL = NSURL(string: UIApplicationOpenSettingsURLString)
                UIApplication.sharedApplication().openURL(URL!)
                self.dismissViewControllerAnimated(true, completion: nil)
            })
            alertController.addAction(openSettings)
            
            self.presentViewController(alertController, animated: true, completion: nil)
            
            self.hideLoading()
            
            self.tabBarController?.tabBar.userInteractionEnabled = true
            self.tableView.hidden = false
            self.tableView.reloadData()
            
            if(self.isRefreshingData){
                self.stopFeedRefreshControl()
            }
        }
    }
    
    /**
    * Shows error mesage when there's no network connection or there was an error with the requests
    *
    * :param: error NSError
    */
    func showErrorAlert(error: NSError) {
        if self.presentedViewController == nil {
            let alertController = UIAlertController(title: "Error", message:"Please check your network connection and try again. Make sure your location settings are on.", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "Ok", style: .Default, handler: {
                (action) -> Void in
                self.dismissViewControllerAnimated(true, completion: nil)
            })
            alertController.addAction(okAction)
            
            self.view.window?.rootViewController!.presentViewController(alertController, animated: true, completion: nil)
            
            self.hideLoading()
            self.tabBarController?.tabBar.userInteractionEnabled = true
            self.tableView.hidden = false
            self.tableView.reloadData()
            
            if(self.isRefreshingData){
                self.stopFeedRefreshControl()
            }
        }
        
    }
    
    // MARK: - Delegate methods of CLLocationManager
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .Denied || status == .Restricted {
            showNoPermissionsAlert()
        } else {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        // Process error
        // kCLErrorDomain. Not localized
        showErrorAlert(error)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newfLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        
        if manager.location != nil{
            
            //Checking flag to avoid multiple request calls
            if(self.isLocationUpdated == false){
                DataManager.sharedInstance.exploreOpenEventsAround(manager.location!, completionHandler: { (data, error) -> () in
                    if error != nil {
                        //If there's an error in the request, show error message
                        self.showErrorAlert(error!)
                    }else{
                        //Hide the loading spinner
                        self.hideLoading()
                        
                        //Set events
                        self.events = data
                        if(self.isRefreshingData){
                            self.stopFeedRefreshControl()
                        }
                        
                        //Show top of the tableview
                        let top:NSIndexPath = NSIndexPath(forItem: NSNotFound, inSection: 0)
                        self.tableView.scrollToRowAtIndexPath(top, atScrollPosition: UITableViewScrollPosition.Top, animated: false)
                        self.tabBarController?.tabBar.userInteractionEnabled = true
                        self.tableView.hidden = false
                        self.tableView.reloadData()
                        
                        //If there are no events, show message to the user
                        if self.events.count == 0{
                            if self.presentedViewController == nil {
                                let alertController = UIAlertController(title: "No results", message:"There are no open events near your location.", preferredStyle: .Alert)
                                let okAction = UIAlertAction(title: "Ok", style: .Default, handler: {
                                    (action) -> Void in
                                    self.dismissViewControllerAnimated(true, completion: nil)
                                })
                                alertController.addAction(okAction)
                                
                                self.view.window?.rootViewController!.presentViewController(alertController, animated: true, completion: nil)
                                
                            }
                        }
                    }
                })
            }
            
            self.isLocationUpdated = true
            locationManager.stopUpdatingLocation()
        }
        
    }
    
    // MARK: - Delegate methods UITableViewDelegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.events.count == 0{
            return 1   //To show "No results" cell
        }else{
            return self.events.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if self.events.count == 0 {
            
            //Creating "No results" cell when there are no open events
            
            let noResultsCell = tableView.dequeueReusableCellWithIdentifier("noResultsCell", forIndexPath: indexPath)
            return noResultsCell
            
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier("eventCell", forIndexPath: indexPath) as! EventTableViewCell
            
            //Populate cell with the information of the event
            if let event = self.events[indexPath.row] as? Event{
                //Event Name
                cell.nameLabel.text = event.name
                
                //Name of the group that is hosting the event
                if event.group != nil{
                    cell.descriptionLabel.text = Utils.isValid(event.group.name) ? ("Group: "+event.group.name) : ""
                }else{
                    cell.descriptionLabel.text = ""
                }
                
                //Event's date
                cell.dateLabel.text = Utils.convertUTCToDate(event.time.stringValue)
            }
            
            return cell
        }
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if self.events.count > 0{
            //When event is tapped, go to Event Details View
            let event = self.events[indexPath.row] as! Event
            let viewController = Storyboard.create("eventDetailsViewController") as! EventDetailsViewController
            viewController.event = event
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        
    }
    
    
    // MARK: UIViewControllerPreviewingDelegate delegate methods
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if self.events.count > 0{
            guard let indexPath = tableView.indexPathForRowAtPoint(location),
                _ = tableView.cellForRowAtIndexPath(indexPath) else { return nil }
    
            //Show preview view controller on 3D Touch
            let event = self.events[indexPath.row] as! Event
            let previewViewController = Storyboard.create("previewViewController") as! PreviewViewController
            previewViewController.event = event
            
            return previewViewController
        }
        return nil
    }
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        showViewController(viewControllerToCommit, sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
