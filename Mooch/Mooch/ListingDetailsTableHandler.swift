//
//  ListingDetailsTableHandler.swift
//  Mooch
//
//  Created by adam on 9/21/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

protocol ListingDetailsTableHandlerDelegate: class, ListingDetailsActionCellDelegate {
    func getConfiguration() -> ListingDetailsViewController.Configuration
    func getListing() -> Listing
}

class ListingDetailsTableHandler: NSObject {
    
    typealias FieldType = ListingDetailsViewController.Configuration.FieldType
    
    enum CellType {
        case listing
        case listingDescription
        case aboutSeller
        case action
    }
    
    // MARK: Public variables
    
    // MARK: Private variables
    
    @IBOutlet weak fileprivate var tableView: UITableView! {
        didSet {
            //Must set these to get cells to use autolayout and self-size themselves in the table
            tableView.rowHeight = UITableViewAutomaticDimension
            
            //Make the table view inset for the nav bar
            tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
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
            
        case .listingDescription:
            return ListingDetailsListingDescriptionCell.Identifier
            
        case .aboutSeller:
            return ListingDetailsSellerCell.Identifier
            
        case .action:
            return ListingDetailsActionCell.Identifier
        }
    }
    
    //Returns the cell type to be used based on the field type
    fileprivate func cellType(forFieldType fieldType: FieldType) -> CellType {
        switch fieldType {
            
        case .listing:
            return .listing
            
        case .listingDescription:
            return .listingDescription
            
        case .aboutSeller:
            return .aboutSeller
            
        default:
            return .action
        }
    }
    
    fileprivate func numberOfRows() -> Int {
        return delegate.getConfiguration().fields.count
    }
    
    fileprivate func configure(listingCell: ListingDetailsListingCell, atIndexPath indexPath: IndexPath) {
        let currentMode = delegate.getConfiguration().mode
        let listing = delegate.getListing()
        
        listingCell.titleLabel.text = listing.title
        listingCell.postedLabel.text = listing.daysSincePostedString
        listingCell.quantityLabel.text = String(listing.quantity)
        listingCell.priceLabel.text = listing.priceString
        
        let showAlertBanner = currentMode == .viewingOtherUsersCompletedListing || currentMode == .viewingThisUsersCompletedListing
        listingCell.alertBannerView.isHidden = !showAlertBanner
        if showAlertBanner {
            if currentMode == .viewingThisUsersCompletedListing {
                listingCell.alertBannerLabel.text = Strings.ListingDetails.alertBannerLabelListingSold.rawValue
            } else if currentMode == .viewingOtherUsersCompletedListing {
                listingCell.alertBannerLabel.text = Strings.ListingDetails.alertBannerLabelListingEnded.rawValue
            }
        }
        
        listingCell.tag = indexPath.row
        ImageManager.sharedInstance.downloadImage(url: listing.pictureURL) { image in
            //Make sure the cell hasn't been reused by the time the image is downloaded
            guard listingCell.tag == indexPath.row else { return }
            
            guard let image = image else { return }
            listingCell.photoImageView.image = image
        }
    }
    
    fileprivate func configure(actionCell: ListingDetailsActionCell, forFieldType fieldType: FieldType) {
        actionCell.fieldType = fieldType
        actionCell.delegate = delegate
        
        let title = actionString(forFieldType: fieldType)
        actionCell.actionButton.setTitle(title, for: .normal)
        
        let backgroundColor = ThemeColors.listingDetailsActionBackground.color()
        let textColor = ThemeColors.listingDetailsActionText.color()
        
        if fieldType == delegate.getConfiguration().firstActionFieldType() {
            actionCell.actionButton.backgroundColor = backgroundColor
            actionCell.actionButton.setTitleColor(textColor, for: UIControlState.normal)
        } else {
            //The buttons that aren't the first button get styled with the a background of the first button text color,
            //and a border/text color of the first button's background color
            actionCell.actionButton.backgroundColor = textColor
            actionCell.actionButton.setTitleColor(backgroundColor, for: UIControlState.normal)
            actionCell.actionButton.borderWidth = 2.0
            actionCell.actionButton.borderColor = backgroundColor
        }
    }
    
    fileprivate func configure(listingDetailsListingDescriptionCell: ListingDetailsListingDescriptionCell) {
        let listing = delegate.getListing()
        
        let descriptionText = (listing.description != nil) ? listing.description! : Strings.ListingDetails.listingDesriptionNoDescription.rawValue
        listingDetailsListingDescriptionCell.descriptionLabel.text = descriptionText
        
        listingDetailsListingDescriptionCell.bottomSeperator.isHidden = delegate.getConfiguration().isListingDescriptionLastField()
    }
    
    fileprivate func configure(listingDetailsSellerCell: ListingDetailsSellerCell, atIndexPath indexPath: IndexPath) {
        let listing = delegate.getListing()
        
        listingDetailsSellerCell.sellerNameLabel.text = listing.owner.name
        listingDetailsSellerCell.sellerImageView.image = UIImage(named: "defaultProfilePhoto")
        
        if let ownerThumbnailPictureURL = listing.owner.thumbnailPictureURL {
            listingDetailsSellerCell.tag = indexPath.row
            ImageManager.sharedInstance.downloadImage(url: ownerThumbnailPictureURL) { image in
                //Make sure the cell hasn't been reused by the time the image is downloaded
                guard listingDetailsSellerCell.tag == indexPath.row else { return }
                
                guard let image = image else { return }
                listingDetailsSellerCell.sellerImageView.image = image
            }
        }
    }
    
    //Returns a string for a button's text corresponding to the field type
    fileprivate func actionString(forFieldType fieldType: FieldType) -> String {
        
        switch fieldType {
        case .contactSeller:
            return Strings.ListingDetails.fieldTypeContactSellerActionString.rawValue
            
        case .viewSellerProfile:
            return Strings.ListingDetails.fieldTypeViewSellerProfileActionString.rawValue
            
        case .endListing:
            return Strings.ListingDetails.fieldTypeEndListingActionString.rawValue
            
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
        
        if let listingCell = cell as? ListingDetailsListingCell {
            configure(listingCell: listingCell, atIndexPath: indexPath)
        } else if let actionCell = cell as? ListingDetailsActionCell {
            configure(actionCell: actionCell, forFieldType: fieldTypeForRow)
        } else if let listingDescriptionCell = cell as? ListingDetailsListingDescriptionCell {
            configure(listingDetailsListingDescriptionCell: listingDescriptionCell)
        } else if let listingSellerCell = cell as? ListingDetailsSellerCell {
            configure(listingDetailsSellerCell: listingSellerCell, atIndexPath: indexPath)
        }
        
        return cell
    }
}

extension ListingDetailsTableHandler: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let fieldType = self.fieldType(forIndexPath: indexPath)
        let cellType = self.cellType(forFieldType: fieldType)
        
        switch cellType {
            
        case .listing:
            return ListingDetailsListingCell.EstimatedHeight
        
        case .listingDescription:
            return ListingDetailsListingDescriptionCell.EstimatedHeight
            
        case .action:
            return ListingDetailsActionCell.EstimatedHeight
            
        case .aboutSeller:
            return ListingDetailsSellerCell.EstimatedHeight
        }
    }
}
