//
//  Annotation.swift
//  Meetup Finder
//
//  Created by Paula Ivic on 9/25/15.
//  Copyright © 2015 Paula Ivic. All rights reserved.
//

import UIKit
import MapKit
import AddressBook

class Annotation: NSObject, MKAnnotation{

    var coordinate: CLLocationCoordinate2D    //Coordinate
    var title: String?                        //Annotation's title  
    var subtitle: String?                     //Annotation's subtitle
    var event:Event?                          //Event object that belongs to this specific location
    
    /**
    * Initializes custom annotation
    *
    * :param: coordinate The location of the event
    * :param: event Event object
    */
    init(coordinate: CLLocationCoordinate2D, event:Event) {
        self.event = event
        self.coordinate = coordinate
        self.title = event.name
        self.subtitle = Utils.isValid(event.venue.address_1) ? (event.venue.address_1 ) : ""
    }
    
    // annotation callout info button opens this mapItem in Maps app
    
    /**
    * Defines the placemark data for the given coordinate and the mapItem information
    * The callout info button
    */
    func mapItem() -> MKMapItem {
        let placemark:MKPlacemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = self.title
        
        return mapItem
    }


}
