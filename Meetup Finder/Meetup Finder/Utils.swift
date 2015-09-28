//
//  Utils.swift
//  Meetup Finder
//
//  Created by Paula Ivic on 9/24/15.
//  Copyright © 2015 Paula Ivic. All rights reserved.
//

import UIKit

class Utils {

    /**
    * Parses the UTC epoch to NSDate
    *
    * :param: epochTime Epoch in String format
    * :returns: a new String of the equivalent formatted Date
    */
    
    static func convertUTCToDate(epochTime:String)->String{
       
        let date:NSDate = self.getNSDateFromUTC(epochTime)
        let formatter = NSDateFormatter()
        formatter.timeZone = NSTimeZone(name: "UTC")
        formatter.dateStyle = NSDateFormatterStyle.MediumStyle
        formatter.timeStyle = .ShortStyle
        
        return formatter.stringFromDate(date)
    }
    
    /**
    * Parses the UTC epoch to NSDate
    *
    * :param: EpochTime Epoch in String format
    * :returns: a NSDate object.
    */
    static func getNSDateFromUTC(epochTime:String)->NSDate{
        let milliseconds:NSTimeInterval = epochTime.doubleValue
        let date:NSDate = NSDate(timeIntervalSince1970: (milliseconds/1000.0))
        return date
    }
    
    /**
    * Checks if object is nil or not
    * In case of String, it also checks if the String is empty or not. In case of NSData objects, it checks its length
    *
    * :param: object Any kind of object
    * :returns: bool value
    */
    static func isValid(object:AnyObject?)-> Bool{
        var isEmpty:Bool = true
        if let item = object{
            isEmpty = false
            if let str = item as? String{
                let trimmedString:String = str.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                isEmpty = (trimmedString.characters.count == 0)
            }
            if let obj = item as? NSData{
                isEmpty = (obj.length == 0)
            }
        }
        let result:Bool = isEmpty ? false : true
        return result
    }
    
}

extension String {
    var doubleValue: Double {
        return (self as NSString).doubleValue
    }
    
}