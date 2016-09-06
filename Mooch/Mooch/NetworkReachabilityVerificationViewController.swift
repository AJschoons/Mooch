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

    override func viewDidLoad() {
        requiresNetworkReachability = false
        super.viewDidLoad()
    }
}
