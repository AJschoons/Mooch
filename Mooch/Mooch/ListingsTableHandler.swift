//
//  ListingsTableHandler.swift
//  Mooch
//
//  Created by adam on 9/10/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

protocol ListingsTableHandlerDelegate: class {
    func getListings() -> [Listing]
    func didSelect(_ listing: Listing)
}

class ListingsTableHandler: NSObject {
    
    @IBOutlet weak fileprivate var tableView: UITableView! {
        didSet {
            let nib = UINib(nibName: ListingTableViewCell.Identifier, bundle: nil)
            tableView.register(nib, forCellReuseIdentifier: ListingTableViewCell.Identifier)
            
            //Must set these to get cells to use autolayout and self-size themselves in the table
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.estimatedRowHeight = ListingTableViewCell.EstimatedHeight
        }
    }
    
    weak var delegate: ListingsTableHandlerDelegate!
    
    func updateUI() {
        tableView.reloadData()
    }
}

extension ListingsTableHandler: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return delegate.getListings().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let listing = delegate.getListings()[(indexPath as NSIndexPath).row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ListingTableViewCell.Identifier, for: indexPath) as! ListingTableViewCell
        cell.titleLabel.text = listing.title
        cell.tagLabel.text = listing.tag.name
        cell.priceLabel.text = listing.priceString
        cell.userLabel.text = "by \(listing.owner.name)"
        
        return cell
    }
}

extension ListingsTableHandler: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedListing = delegate!.getListings()[(indexPath as NSIndexPath).row]
        delegate!.didSelect(selectedListing)
    }
}
