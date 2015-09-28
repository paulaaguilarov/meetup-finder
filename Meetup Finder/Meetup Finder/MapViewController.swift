//
//  MapViewController.swift
//  Meetup Finder
//
//  Created by Paula Ivic on 9/23/15.
//  Copyright © 2015 Paula Ivic. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: BaseViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!      //Map view
    
    var locationManager : CLLocationManager!    //Location manager
    var lastSelected:MKAnnotation!              //The last selected annotation
    var currentLocation:CLLocation!             //Current location
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Shows current location in mapview
        showCurrentLocation()
        
        //Add annotations to map
        self.addAnotations()
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        //If there is a selected annotation, deselect it
        if(self.lastSelected != nil){
            self.mapView.deselectAnnotation(self.lastSelected, animated: false)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /**
    * Shows current location in the map
    */
    func showCurrentLocation(){
        let span = MKCoordinateSpanMake(0.080, 0.080)
        
        //Getting current location from Data Manager
        let location = DataManager.sharedInstance.location
        
        //If location is valid, set region into the map
        if(location != nil){
            let region = MKCoordinateRegion(center: DataManager.sharedInstance.location.coordinate, span: span)
            self.mapView.setRegion(region, animated: true)
            
        }else{
            //If there is no location available, show error message
            let alertController = UIAlertController(title: "Error", message:"Your location is not available.", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "Ok", style: .Default, handler: {
                (action) -> Void in
                self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
            })
            alertController.addAction(okAction)
            self.navigationController?.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    /**
    * Adds annotation in the map for each open event
    */
    func addAnotations() {
        let pins = DataManager.sharedInstance.events
        for item in pins {
            if let event:Event = item as? Event{
                if event.venue != nil{
                    let coordinate = CLLocationCoordinate2DMake(event.venue.lat.doubleValue, event.venue.lon.doubleValue)
                    let annotation = Annotation(coordinate: coordinate, event:event)
                    mapView.addAnnotation(annotation)
                }
               
            }
        }
    }
    
    /**
    * Calls to action when user taps on any annotation
    * :param: sender The tap gesture recognizer which in this case is the sender's view
    */
    func calloutTapped(sender:UITapGestureRecognizer){
        let view:MKAnnotationView = sender.view as! MKAnnotationView
        
        //Remove all the gesture recognizers in this view
        if(view.gestureRecognizers?.count > 0){
            view.gestureRecognizers?.removeAll(keepCapacity: false)
        }
        
        //Shows details page for this event
        if let annotation = view.annotation as? Annotation {
            self.showEventDetails(annotation.event!)
        }
    }
    
    /**
    * Shows the Event Details View Controller
    * :param: event Object that contains the information for this event
    */
    func showEventDetails(event: Event) {
        let viewController = Storyboard.create("eventDetailsViewController") as! EventDetailsViewController
        viewController.event = event
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    
    // MARK: - Delegate methods - MKMapViewDelegate
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        //Creating the annotation view
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "Event")
        
        //Setting image for the pin
        annotationView.image =  UIImage(named: "event-pin")
        
        //Setting flag on true to enable the call to action
        annotationView.canShowCallout = true
        
        let img:UIImageView = UIImageView()
        img.frame.size.width = 44
        img.frame.size.height = 44
        img.backgroundColor = UIColor.clearColor()
        img.image = annotationView.image
        
        annotationView.leftCalloutAccessoryView = img
        
        return annotationView
    }
    
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        //Storing the last selected
        self.lastSelected = view.annotation
        
        //Add gesture recognizer to annotation view
        let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "calloutTapped:")
        view.addGestureRecognizer(tapGesture)
    }


}
