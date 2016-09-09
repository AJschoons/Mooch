//
//  ViewController.swift
//  Mooch
//
//  Created by adam on 9/2/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

class ViewController: MoochViewController {
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        MoochAPI.GETUsers() { users in
            guard let users = users else {
                print("no users??")
                return
            }
            
            for user in users {
                print(user)
            }
        }
    }
}

