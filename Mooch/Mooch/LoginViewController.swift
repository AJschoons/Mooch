//
//  LoginViewController.swift
//  Mooch
//
//  Created by adam on 9/12/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

class LoginViewController: MoochModalViewController {
    
    // MARK: Public variables
    
    // MARK: Private variables
    
    // MARK: Actions
    
    @IBAction func onCancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onLogin() {
        
    }
    
    @IBAction func onCreateAccount() {
        
    }
    
    // MARK: Public methods
    
    override func prefersNavigationBarHidden() -> Bool {
        return true
    }
    
    // MARK: Private methods
}
