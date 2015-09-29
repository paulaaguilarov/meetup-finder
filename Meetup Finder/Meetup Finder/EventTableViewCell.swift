//
//  EventTableViewCell.swift
//  Meetup Finder
//
//  Created by Paula Ivic on 9/23/15.
//  Copyright © 2015 Paula Ivic. All rights reserved.
//

import UIKit

class EventTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!              //Label to display the title of the event
    @IBOutlet weak var descriptionLabel: UILabel!       //Label to display the description / Name of the group that is hosting
    @IBOutlet weak var dateLabel: UILabel!              //Label to display the date of the event
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
   
    
   

}
