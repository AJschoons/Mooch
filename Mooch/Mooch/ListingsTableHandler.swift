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
        cell.photo.image = ImageManager.PlaceholderImage
        cell.titleLabel.text = listing.title
        cell.priceLabel.text = listing.priceString
        
        var categoryLabelText: String
        if let listingCategory = ListingCategoryManager.sharedInstance.getListingCategory(withId: listing.categoryId) {
            categoryLabelText = listingCategory.name
        } else {
            categoryLabelText = Strings.InvalidCategoryId.rawValue
        }
        cell.categoryLabel.text = categoryLabelText
        
        cell.tag = indexPath.row
        cell.photo.image = ImageManager.PlaceholderImage
        ImageManager.sharedInstance.downloadImage(url: listing.thumbnailPictureURL) { image in
            //Make sure the cell hasn't been reused by the time the image is downloaded
            guard cell.tag == indexPath.row else { return }
            
            guard let image = image else { return }
            cell.photo.image = image
        }
        
        return cell
    }
}

extension ListingsTableHandler: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedListing = delegate!.getListings()[(indexPath as NSIndexPath).row]
        delegate!.didSelect(selectedListing)
    }
}
