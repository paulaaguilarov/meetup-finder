//
//  BaseViewController.swift
//  Meetup Finder
//
//  Created by Paula Ivic on 9/23/15.
//  Copyright © 2015 Paula Ivic. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    @IBOutlet weak var loadingOverlay:UIView!               //View with the activity indicator
    @IBOutlet weak var loadingIcon:UIActivityIndicatorView! //Activity indicator
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
    * Shows the loading spinner while doing WS requests
    */
    func showLoading(){
        self.loadingOverlay.hidden = false
        self.loadingOverlay.superview?.bringSubviewToFront(self.loadingOverlay)
        self.loadingIcon.startAnimating()
    }
    
    /**
    * Hides the loading spinner
    */
    func hideLoading(){
        self.loadingOverlay.hidden = true
        self.loadingIcon.stopAnimating()
    }
    

}

class Storyboard: UIStoryboard {
    class func create(name: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(name)
    }
}
