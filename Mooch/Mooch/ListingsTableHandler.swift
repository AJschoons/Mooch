//
//  ListingsTableHandler.swift
//  Mooch
//
//  Created by adam on 9/10/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

class ListingsTableHandler: NSObject {
    @IBOutlet weak var tableView: UITableView!
}

extension ListingsTableHandler: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}

extension ListingsTableHandler: UITableViewDelegate {
    
}