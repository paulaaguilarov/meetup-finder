//
//  PreviewViewController.swift
//  Meetup Finder
//
//  Created by Paula Ivic on 9/28/15.
//  Copyright © 2015 Paula Ivic. All rights reserved.
//

import UIKit

class PreviewViewController: BaseEventDetailsViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.loadEventInfo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Preview actions
    override func previewActionItems() -> [UIPreviewActionItem] {
        let addEventAction:UIPreviewAction = UIPreviewAction(title: "Close Preview", style: UIPreviewActionStyle.Default) { (previewAction, viewController) -> Void in
            print("Closing Preview")
        }
        let actions:[UIPreviewActionItem] = [addEventAction]
        
        return actions
    }

    

    
}
