//
//  ApplicationConfiguration.swift
//  Meetup Finder
//
//  Created by Paula Ivic on 9/24/15.
//  Copyright © 2015 Paula Ivic. All rights reserved.
//

import UIKit

class ApplicationConfiguration {
    
    var wsAPIKey:String = ""            //API Key, You'll need to provide this key with every request you make to the Meetup API
    var wsMeetupURL:String = ""         //Host
    var wsOpenEvents:String = ""        //API method to get the open events
    var wsTopics:String = ""            //API method to get topics
    var wsTopicsSearch:String = ""      //Meetup topic, to look only for "Tech" related open events
    var wsGroups:String  = ""           //API method to get Meetup groups

    //Share instance
    static let sharedInstance = ApplicationConfiguration()
    
    //Forces callers to use the Singleton
    private init() {
        
        //Get the values from the config.list
        if let path = NSBundle.mainBundle().pathForResource("config", ofType: "plist"){
            if let root = NSDictionary.init(contentsOfFile: path){
                self.wsMeetupURL = root.objectForKey("wsMeetupURL") as! String
                self.wsAPIKey = root.objectForKey("wsAPIKey") as! String
                self.wsOpenEvents = root.objectForKey("wsOpenEvents") as! String
                self.wsTopics = root.objectForKey("wsTopics") as! String
                self.wsTopicsSearch = root.objectForKey("wsTopicsSearch") as! String
                self.wsGroups = root.objectForKey("wsGroups") as! String
            }
            
        }
    }
    
}

