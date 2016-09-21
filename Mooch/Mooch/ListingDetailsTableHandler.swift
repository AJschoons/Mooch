//
//  ListingDetailsTableHandler.swift
//  Mooch
//
//  Created by adam on 9/21/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

protocol ListingDetailsTableHandlerDelegate: class {
    func getConfiguration() -> ListingDetailsViewController.Configuration
}

class ListingDetailsTableHandler: NSObject {
    
    typealias FieldType = ListingDetailsViewController.Configuration.FieldType
    
    enum CellType {
        case listing
        case action
        case ratingAction
    }
    
    // MARK: Public variables
    
    // MARK: Private variables
    
    @IBOutlet weak fileprivate var tableView: UITableView! {
        didSet {
            //Must set these to get cells to use autolayout and self-size themselves in the table
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.estimatedRowHeight = 44
        }
    }
    
    weak var delegate: ListingDetailsTableHandlerDelegate!
    
    
    // MARK: Actions
    
    // MARK: Public methods
    
    // MARK: Private methods
    
    //Returns the field type that a row is displaying
    fileprivate func fieldType(forIndexPath indexPath: IndexPath) -> FieldType {
        return delegate!.getConfiguration().fields[indexPath.row]
    }
    
    //Returns the identifier string for
    fileprivate func cellIdentifer(forCellType cellType: CellType) -> String {
        
        switch cellType {
        case .listing:
            return ListingDetailsListingCell.Identifier
        case .ratingAction:
            return ListingDetailsRatingActionCell.Identifier
        default:
            return ListingDetailsActionCell.Identifier
        }
    }
    
    //Returns the cell type to be used based on the field type
    fileprivate func cellType(forFieldType fieldType: FieldType) -> CellType {
        switch fieldType {
        case .listing:
            return .listing
        case .rateSeller:
            return .ratingAction
        default:
            return .action
        }
    }
    
    fileprivate func numberOfRows() -> Int {
        return delegate.getConfiguration().fields.count
    }
    
    //Returns a string for a button's text corresponding to the field type
    fileprivate func actionString(forFieldType fieldType: FieldType) -> String {
        switch fieldType {
        case .addAnotherListing:
            return "Add New Listing"
        case .contactSeller:
            return "Claim"
        case .deleteListing:
            return "Delete Listing"
        case .editListing:
            return "Edit Listing"
        case .viewSellerProfile:
            return "View Seller Profile"
        default:
            return ""
        }
    }
}

extension ListingDetailsTableHandler: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let fieldTypeForRow = fieldType(forIndexPath: indexPath)
        let cellTypeForRow = cellType(forFieldType: fieldTypeForRow)
        let identifier = cellIdentifer(forCellType: cellTypeForRow)
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        
        if let actionCell = cell as? ListingDetailsActionCell {
            actionCell.textLabel?.text = actionString(forFieldType: fieldTypeForRow)
        }
        
        return cell
    }
}

extension ListingDetailsTableHandler: UITableViewDelegate {
    
}
