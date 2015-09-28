//
//  BaseEventDetailsViewController.swift
//  Meetup Finder
//
//  Created by Paula Ivic on 9/28/15.
//  Copyright © 2015 Paula Ivic. All rights reserved.
//

import UIKit

class BaseEventDetailsViewController: BaseViewController {
    
    
    @IBOutlet weak var scrollView: UIScrollView!        //Scroll view
    @IBOutlet weak var backButton:UIBarButtonItem!      //Back button in navigation bar
    @IBOutlet weak var groupLabel:UILabel!              //Label to display the name of the group that is hosting the event
    @IBOutlet weak var eventTitleLabel:UILabel!         //Label to display the the title of the event
    @IBOutlet weak var timeLabel:UILabel!               //Label to display the date of the event
    @IBOutlet weak var addressLabel:UILabel!            //Label to display the address of the venue
    @IBOutlet weak var descriptionTextView:UITextView!  //Text view to display the description of the event
    
    var event:Event!                                    //Event object
    
    //Constant
    let defaultText:String = "Not Available"            //Default copy to use when there is no data available

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    /**
    * Displays the event's information in the corresponding views
    */
    func loadEventInfo(){
        if self.event.group != nil{
            self.groupLabel.text = Utils.isValid(self.event.group.name) ? self.event.group.name : self.defaultText
        }else{
            self.groupLabel.text = self.defaultText
        }
        if self.event.venue != nil{
            self.addressLabel.text = Utils.isValid(self.event.venue.address_1) ? self.event.venue.address_1 : self.defaultText
        }else{
            self.addressLabel.text = "Address not available. Please check the map"
        }
        self.timeLabel.text = Utils.isValid(self.event.time) ? Utils.convertUTCToDate(self.event.time.stringValue) : self.defaultText
        
        self.eventTitleLabel.text = Utils.isValid(self.event.name) ? self.event.name : self.defaultText
        
        //Setting font-name and font-size for the textview
        let attrs = [NSFontAttributeName :UIFont(name: "Avenir-Book", size: 13)!]
        var aboutText:NSMutableAttributedString = NSMutableAttributedString(string: self.defaultText, attributes: attrs)
        
        if(self.event.about != nil){
            aboutText = NSMutableAttributedString(string: self.event.about)
        }
        
        do {
            //Creating attributed string to display text in HTML format
            aboutText = try NSMutableAttributedString(data: self.event.about.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: true)!, options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)
            aboutText.addAttributes(attrs, range: NSRange(location: 0,length: aboutText.length-1))
        } catch {
            print(error)
        }
        
        self.descriptionTextView.attributedText = aboutText
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
