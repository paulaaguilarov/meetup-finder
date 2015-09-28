//
//  NavigationController.swift
//  Meetup Finder
//
//  Created by Paula Ivic on 9/23/15.
//  Copyright (c) 2015 Paula Ivic. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewWillAppear(animated: Bool) {
        if(self.viewControllers.count > 1){
            self.popToRootViewControllerAnimated(false)
        }
    }

}
