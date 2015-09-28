//
//  DataManager.swift
//  Meetup Finder
//
//  Created by Paula Ivic on 9/24/15.
//  Copyright © 2015 Paula Ivic. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class DataManager{
    
    var location:CLLocation!            // Current Location
    var topics:NSArray = NSArray()      // List of "Tech" topics
    var events:NSArray = NSArray()      // List of open events
    
    //RestKit Config
    var baseURL:NSURL!                  // Webservice host
    var client:AFHTTPClient!
    var objectManager:RKObjectManager!
    
    //Shared Instance
    static let sharedInstance = DataManager()
    
    //Forces callers to use the Singleton
    private init() {
        print(__FUNCTION__, terminator: "")
        self.baseURL = NSURL(string: ApplicationConfiguration.sharedInstance.wsMeetupURL)!
        self.client = AFHTTPClient(baseURL: baseURL)
        self.objectManager = RKObjectManager.init(HTTPClient: client)
    }
    
    
    /**
    * Requests the open events for an specific location and topics (Tech) (Using Meetup.com Web Services)
    *
    * :param: targetLocation The user's location
    * :param: completionHandler It receives the array of results and an optional error
    */
    func exploreOpenEventsAround(targetLocation: CLLocation, completionHandler: (data: NSArray, error:NSError?) -> ()) {
  
        self.location = targetLocation
        
        //If we don't have the urlkeys for "Tech" yet
        if self.topics.count == 0{
            
            //Request the array of urlkeys for "Tech" using WS
            self.requestTopics({ () -> () in
                
                //Once we got the topics, request the open events related with "Tech"
                self.requestOpenEvents({ (data, error) -> () in
                    completionHandler(data: data, error: error)
                })
                
            })
        }else{
            //Request the open events for Tech topics
            self.requestOpenEvents({ (data, error) -> () in
                completionHandler(data: data, error: error)
            })
        }
    }
    
    /**
    * Requests the urlkeys for Tech. (Using Meetup.com Web Service)
    *
    * :param: completionHandler
    */
    func requestTopics(completionHandler:() -> ()) {
        //Defining topics object mapping
        let topicsMapping:RKObjectMapping = RKObjectMapping(forClass: Topic.self)
        topicsMapping.addAttributeMappingsFromArray(["name", "id", "urlkey"])
        
        //Register mappings using response descriptor
        let responseDescriptor:RKResponseDescriptor = RKResponseDescriptor(mapping: topicsMapping, method: RKRequestMethod.GET, pathPattern: ApplicationConfiguration.sharedInstance.wsTopics, keyPath: "results", statusCodes: NSIndexSet(index: 200))
        
        objectManager.addResponseDescriptor(responseDescriptor)
        
        //Set query parameters to be sent in the request
        let queryParams = ["key": ApplicationConfiguration.sharedInstance.wsAPIKey, "search": ApplicationConfiguration.sharedInstance.wsTopicsSearch]
        
        //Request
        RKObjectManager.sharedManager().getObjectsAtPath(ApplicationConfiguration.sharedInstance.wsTopics, parameters: queryParams, success: { (operation, result) -> Void in
            
            //If there's any result
            if let topics:NSArray = result.array(){
                
                //Assign the topics
                self.topics = topics
    
                //Call completion handler
                completionHandler()
            }
            }) { (operation, error) -> Void in
                completionHandler()
        }
    }
    
    /**
    * Requests the opens events (Using Meetup.com Web Service)
    *
    * :param: completionHandler It receives the array of results and an optional error
    */
    func requestOpenEvents(completionHandler: (data: NSArray, error:NSError?) -> ()) {
       
        //Defining event object mapping
        let eventMapping:RKObjectMapping = RKObjectMapping(forClass:Event.self)
        eventMapping.addAttributeMappingsFromDictionary([
            "description":"about",
            "event_url": "event_url",
            "name": "name",
            "photo_url" : "photo_url",
            "time":"time"
            ])
        
        //Defining venue objectg mapping
        let venueMapping:RKObjectMapping = RKObjectMapping(forClass:Venue.self)
        venueMapping.addAttributeMappingsFromArray(["zip", "country", "city", "address_1","name", "lon", "lat"])
        
        //Defining group objectg mapping
        let groupMapping:RKObjectMapping = RKObjectMapping(forClass:Group.self)
        groupMapping.addAttributeMappingsFromArray(["id","join_mode", "name"])
        
        //Defining photo objectg mapping
        let photoMapping:RKObjectMapping = RKObjectMapping(forClass:Photo.self)
        photoMapping.addAttributeMappingsFromArray(["highres_link","photo_link", "thumb_link"])
        
        //Defining relationship mapping
        groupMapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "group_photo", toKeyPath: "group_photo", withMapping: photoMapping))
        
        //Defining relationship mapping
        eventMapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "venue", toKeyPath: "venue", withMapping: venueMapping))
        eventMapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "group", toKeyPath: "group", withMapping: groupMapping))
        
        
        //Register mappings using response descriptor
        let responseDescriptor:RKResponseDescriptor = RKResponseDescriptor(mapping: eventMapping, method: RKRequestMethod.GET, pathPattern: ApplicationConfiguration.sharedInstance.wsOpenEvents, keyPath: "results", statusCodes: NSIndexSet(index: 200))
        
        objectManager.addResponseDescriptor(responseDescriptor)
        
        //Set query parameters to be sent in the request
        let paramsDic:NSMutableDictionary = [
            "key": ApplicationConfiguration.sharedInstance.wsAPIKey,
            "sign": "true",
            "lat": "\(self.location.coordinate.latitude)",
            "lon": "\(self.location.coordinate.longitude)"
        ]
        
        //If we got the urlkeys for Tech topics, add them as a parameter. Values must go separated by commas
        if self.topics.count > 0{
            var urlkeys:String =  ""
            
            for var index = 0; index < self.topics.count; index++ {
                if let topic:Topic = self.topics.objectAtIndex(index) as? Topic{
                    urlkeys += topic.urlkey
                    if index != (self.topics.count-1){
                        urlkeys += ","
                    }
                }
            }
            
            
            paramsDic.setValue(urlkeys, forKey: "topic")
            
        }
        
        let queryParams = NSDictionary(dictionary: paramsDic) as! Dictionary<String, AnyObject>
        
        //Request
        RKObjectManager.sharedManager().getObjectsAtPath(ApplicationConfiguration.sharedInstance.wsOpenEvents, parameters: queryParams, success: { (operation, result) -> Void in
            
            //Assign results
            self.events = result.array()
            
            //Call completion handler
            completionHandler(data: self.events, error: nil)
            }) { (operation, error) -> Void in
                completionHandler(data: self.events, error: error)
        }

    }
    
    /**
    * Requests photo url of an specific Meetup.com group
    *
    * :param: groupID The id of the group
    * :param: completionHandler It receives the Photo object and an optional error
    */
    func requestPhotoOfGroup(groupID:String, completionHandler: (photo: Photo, error:NSError?) -> ()) {
        
        //Defining groupphoto object mapping
        let groupPhotoMapping:RKObjectMapping = RKObjectMapping(forClass:Group.self)
        
        //Defining photo objectg mapping
        let photoMapping:RKObjectMapping = RKObjectMapping(forClass:Photo.self)
        photoMapping.addAttributeMappingsFromArray(["highres_link","photo_link", "thumb_link"])
        
        
        //Defining relationship mapping
        groupPhotoMapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "group_photo", toKeyPath: "group_photo", withMapping: photoMapping))
        
        
        //Register mappings using response descriptor
        let responseDescriptor:RKResponseDescriptor = RKResponseDescriptor(mapping: groupPhotoMapping, method: RKRequestMethod.GET, pathPattern: ApplicationConfiguration.sharedInstance.wsGroups, keyPath: "results", statusCodes: NSIndexSet(index: 200))
        
        objectManager.addResponseDescriptor(responseDescriptor)
        
        //Set query parameters to be sent in the request
        let queryParams = [
            "key": ApplicationConfiguration.sharedInstance.wsAPIKey,
            "sign": "true",
            "group_id": groupID
        ]
        
        //Request
        RKObjectManager.sharedManager().getObjectsAtPath(ApplicationConfiguration.sharedInstance.wsGroups, parameters: queryParams, success: { (operation, result) -> Void in
            
            var photo:Photo = Photo()
            
            //If we receive any result/group
            if let groups:NSArray = result.array(){
                if groups.count > 0{
                    if let group:Group = groups[0] as? Group{
                        if let item:Photo = group.group_photo{
                            //Assign the photo to variable
                            photo = item
                        }
                    }
                }
            }
            
            //Call completion handler, sending the photo object as parameter
            completionHandler(photo: photo, error: nil)
            }) { (operation, error) -> Void in
                completionHandler(photo: Photo(), error: error)
        }
    
    }
    
}