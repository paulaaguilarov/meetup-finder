//
//  EventCalendarService.swift
//  Meetup Finder
//
//  Created by Paula Ivic on 9/28/15.
//  Copyright © 2015 Paula Ivic. All rights reserved.
//

import UIKit
import EventKit

enum EventCalendarErrorType: ErrorType {
    case NoPermission
    case Fail
}

class EventCalendarService {
    
    var event:Event!    //Event object
    
    /**
    * Initializes the service with the event to be added to the calendar
    * 
    * :param: event Event object
    */
    init(event:Event){
        self.event = event
    }
    
    /**
    * Requests permission to access user's iCloud calendar
    * If permission is granted it proceeds to add the event into the calendar
    */
    func addEventToCalendar(completionHandler: (alertTitle:String, alertMessage:String, error:EventCalendarErrorType?) -> ()) {
        
        //Creating the event store object
        let eventStore = EKEventStore()
        
        let alertTitle = "No permission"
        let alertMessage = "You have not granted permission for this app to access your Calendar"
        
        //Checking authorization to access the calendar and add the event
        switch EKEventStore.authorizationStatusForEntityType(EKEntityType.Event) {
        case .Authorized:
            //Insert the event in user's calendar
            self.insertEvent(eventStore, completionHandler: { (alertTitle, alertMessage, error) -> () in
                completionHandler(alertTitle: alertTitle, alertMessage: alertMessage, error: error)
            })
        case .Denied:
            //Showing error message indicating the app is not allowed to add the event
            completionHandler(alertTitle: alertTitle, alertMessage: alertMessage, error: EventCalendarErrorType.NoPermission)
        case .NotDetermined:
            eventStore.requestAccessToEntityType(EKEntityType.Event, completion: { [weak self](granted, error) -> Void in
                if granted {
                    //Insert event in user's calendar
                    self!.insertEvent(eventStore, completionHandler: { (alertTitle, alertMessage, error) -> () in
                        completionHandler(alertTitle: alertTitle, alertMessage: alertMessage, error: error)
                    })
                } else {
                    //Showing error message indicating the app is not allowed to add the event
                   completionHandler(alertTitle: alertTitle, alertMessage: alertMessage, error: EventCalendarErrorType.NoPermission)
                }
                
                })
        default:
            //Showing error message indicating there is no authorization to access user's calendar
            completionHandler(alertTitle: alertTitle, alertMessage: alertMessage, error: EventCalendarErrorType.NoPermission)
        }
    }
    
    /**
    * Inserts event into user's calendar
    *
    * :param: store Event store object
    */
    func insertEvent(store: EKEventStore, completionHandler: (alertTitle:String, alertMessage:String, error:EventCalendarErrorType?) -> ()) {
        
        //Creating event object to be added
        let event:EKEvent = EKEvent(eventStore: store)
        
        //Setting event's information
        event.title = self.event.name
        event.startDate = Utils.getNSDateFromUTC(self.event.time.stringValue)
        event.endDate = Utils.getNSDateFromUTC(self.event.time.stringValue)
        
        event.notes = (Utils.isValid(self.event.event_url)) ? ("Event's page: "+self.event.event_url) : ""
        event.calendar = store.defaultCalendarForNewEvents
        
        var alertTitle:String = "Event Added"
        var alertMessage:String = "This event was sucessfully added to your calendar"
        
        do{
            try store.saveEvent(event, span: EKSpan.ThisEvent)
            completionHandler(alertTitle: alertTitle, alertMessage: alertMessage, error: nil)
        }catch{
            alertTitle = "Error"
            alertMessage = "There was an error when trying to add the event to your calendar. Please check your settings and try again."
            completionHandler(alertTitle: alertTitle, alertMessage: alertMessage, error: EventCalendarErrorType.Fail)
        }
    }

}
