//
//  NetworkReachabilityVerificationViewController.swift
//  Mooch
//
//  Created by adam on 9/5/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

//View controller that notifies the user there is no network connection
class NetworkReachabilityVerificationViewController: MoochViewController {

    // MARK: Public variables
    
    // MARK: Private variables
    
    // MARK: Actions
    
    // MARK: Public methods
    
    override func viewDidLoad() {
        requiresNetworkReachability = false
        super.viewDidLoad()
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: Private methods
}
