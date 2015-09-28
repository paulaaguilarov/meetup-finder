//
//  EventDetailsViewController.swift
//  Meetup Finder
//
//  Created by Paula Ivic on 9/25/15.
//  Copyright © 2015 Paula Ivic. All rights reserved.
//

import UIKit
import EventKit

class EventDetailsViewController: BaseEventDetailsViewController, UITextViewDelegate {

    var gestureRecognizer:UISwipeGestureRecognizer!     //Gesture recognizer to swipe back
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setting action for the back button in the navigation bar
        self.backButton.target = self
        self.backButton.action = "goBack:"
        
        self.descriptionTextView.delegate = self
        
        //Add swipe gesture to go back to the previous screen
        self.addGoBackGesture()
        
        //Display event information in the view
        self.loadEventInfo()
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        //Setting the size that fits the content of the text for the event's description view
        let contentSize = self.descriptionTextView.sizeThatFits(self.descriptionTextView.bounds.size)
        var frame = self.descriptionTextView.frame
        frame.size.height = contentSize.height
        self.descriptionTextView.frame = frame
    }
    
    // MARK: - Delegate methods UITextViewDelegate
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        return true
    }
    
    /**
    * Adds swipe gesture to view to go back to the previous screen
    */
    func addGoBackGesture(){
        gestureRecognizer = UISwipeGestureRecognizer(target: self, action: "goBack:")
        gestureRecognizer.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(gestureRecognizer)
    }
    
    /**
    * Pops view controller to go back to the previous one
    * :param: sender AnyObject gesture recognizer
    */
    func goBack(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    /**
    * Requests permission to add the event in the iCloud calendar when users taps on the right nav bar button
    * :param: sender UIBarButtonItem in the navigation bar
    */
    @IBAction func addEventToCalendar(sender: UIBarButtonItem) {
        self.requestToAddEventToCalendar()
    }
    
    /**
    * Requests the EventCalendarService to add this event to the calendar
    */
    func requestToAddEventToCalendar(){
        
        //Create the EventCalendarService instance, which it's in charge to request the permission to access the user's calendar and add the event
        let eventCalendarService:EventCalendarService = EventCalendarService(event: self.event)
        
        eventCalendarService.addEventToCalendar { (alertTitle, alertMessage, error) -> () in
            
            dispatch_async(dispatch_get_main_queue(), {
                //Display informative message to let the users know if the event was added or not
                let alertController = UIAlertController(title: alertTitle, message:alertMessage, preferredStyle: .Alert)
                
                if (error != nil) && (error == EventCalendarErrorType.NoPermission){
                    //Showing error message indicating there is no authorization to access user's calendar
                    let openSettings = UIAlertAction(title: "Open settings", style: .Default, handler: {
                        (action) -> Void in
                        let URL = NSURL(string: UIApplicationOpenSettingsURLString)
                        UIApplication.sharedApplication().openURL(URL!)
                        self.dismissViewControllerAnimated(true, completion: nil)
                    })
                    alertController.addAction(openSettings)
                    
                }else{
                    let okAction = UIAlertAction(title: "Ok", style: .Default, handler: {
                        (action) -> Void in
                        self.dismissViewControllerAnimated(true, completion: nil)
                    })
                    alertController.addAction(okAction)
                    
                }
                self.presentViewController(alertController, animated: true, completion: nil)

            })
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
