//
//  Event.swift
//  Meetup Finder
//
//  Created by Paula Ivic on 9/23/15.
//  Copyright © 2015 Paula Ivic. All rights reserved.
//

import UIKit

class Event: NSObject {
    var venue:Venue!        //Venue
    var about:String!       //Description of the event
    var event_url:String!   //URL of the event's page on meetup.com
    var name:String!        //The name of the event
    var time:NSNumber!      //UTC start time of the event in milliseconds
    var photo_url:String!   //URL of the event photo
    var group:Group!        //Group that is hosting the event
}
