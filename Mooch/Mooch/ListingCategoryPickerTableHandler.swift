//
//  ListingCategoryPickerTableHandler.swift
//  Mooch
//
//  Created by adam on 10/1/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import Foundation

import UIKit

protocol ListingCategoryPickerTableHandlerDelegate: class {
    func getListingCategories() -> [ListingCategory]
    func getSelectedListingCategory() -> ListingCategory?
    func didSelect(_ listingCategory: ListingCategory)
}

class ListingCategoryPickerTableHandler: NSObject {
    
    @IBOutlet weak fileprivate var tableView: UITableView! {
        didSet {
            //Must set these to get cells to use autolayout and self-size themselves in the table
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.estimatedRowHeight = 44
        }
    }
    
    weak var delegate: ListingCategoryPickerTableHandlerDelegate!
    
    fileprivate let CellIdentifier = "ListingCategoryPickerCell"
    
    func updateUI() {
        tableView.reloadData()
    }
}

extension ListingCategoryPickerTableHandler: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return delegate.getListingCategories().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let listingCategory = delegate.getListingCategories()[indexPath.row]
        
        var isListingCategorySelected = false
        if let selectedListingCategory = delegate.getSelectedListingCategory() {
            isListingCategorySelected = listingCategory.id == selectedListingCategory.id
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier, for: indexPath)
        cell.textLabel?.text = listingCategory.name
        cell.accessoryType = isListingCategorySelected ? .checkmark : .none
        
        return cell
    }
}

extension ListingCategoryPickerTableHandler: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        updateUI()
        let selectedListingCategory = delegate!.getListingCategories()[indexPath.row]
        delegate.didSelect(selectedListingCategory)
    }
}
