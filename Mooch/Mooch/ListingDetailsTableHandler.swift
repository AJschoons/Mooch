//
//  ListingDetailsTableHandler.swift
//  Mooch
//
//  Created by adam on 9/21/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

protocol ListingDetailsTableHandlerDelegate: class, ListingDetailsActionCellDelegate, ListingDetailsInterestedBuyerCellDelegate, ListingDetailsUserCellDelegate {
    typealias Configuration = ListingDetailsConfiguration
    
    func getConfiguration() -> Configuration
    func tabBarHeight() -> CGFloat
    func didGet(listingImage: UIImage)
}

class ListingDetailsTableHandler: NSObject {
    
    typealias FieldType = ListingDetailsViewController.Configuration.FieldType
    
    enum CellType {
        case listing
        case action
        case listingDescription
        case aboutOtherUser
        case interestedBuyersHeader
        case interestedBuyer
    }
    
    // MARK: Public variables
    
    // MARK: Private variables
    
    @IBOutlet weak fileprivate var tableView: UITableView! {
        didSet {
            //Must set these to get cells to use autolayout and self-size themselves in the table
            tableView.rowHeight = UITableViewAutomaticDimension
            
            //Make the table view inset for the nav bar and tab bar
            let navBarHeight: CGFloat = 64.0
            tableView.contentInset = UIEdgeInsets(top: navBarHeight, left: 0, bottom: delegate.tabBarHeight(), right: 0)
            tableView.scrollIndicatorInsets = UIEdgeInsets(top: navBarHeight, left: 0, bottom: delegate.tabBarHeight(), right: 0)
        }
    }
    
    weak var delegate: ListingDetailsTableHandlerDelegate!
    
    // MARK: Actions
    
    // MARK: Public methods
    
    func reloadRow(at indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
    }
    
    func reloadData() {
        tableView.reloadData()
    }
    
    
    // MARK: Private methods
    
    //Returns the field type that a row is displaying
    fileprivate func fieldType(forIndexPath indexPath: IndexPath) -> FieldType {
        return delegate!.getConfiguration().fieldType(forRow: indexPath.row)
    }
    
    //Returns the identifier string for
    fileprivate func cellIdentifer(forCellType cellType: CellType) -> String {
        
        switch cellType {
            
        case .listing:
            return ListingDetailsListingCell.Identifier
            
        case .action:
            return ListingDetailsActionCell.Identifier
            
        case .listingDescription:
            return ListingDetailsListingDescriptionCell.Identifier
            
        case .aboutOtherUser:
            return ListingDetailsUserCell.Identifier
            
        case .interestedBuyersHeader:
            return ListingDetailsInterestedBuyersHeaderCell.Identifier
            
        case .interestedBuyer:
            return ListingDetailsInterestedBuyerCell.Identifier
        }
    }
    
    //Returns the cell type to be used based on the field type
    fileprivate func cellType(forFieldType fieldType: FieldType) -> CellType {
        switch fieldType {
            
        case .listing:
            return .listing
            
        case .listingDescription:
            return .listingDescription
            
        case .aboutOtherUser:
            return .aboutOtherUser
            
        case .interestedBuyersHeader:
            return .interestedBuyersHeader
            
        case .interestedBuyer:
            return .interestedBuyer
            
        default:
            return .action
        }
    }
    
    fileprivate func numberOfRows() -> Int {
        return delegate.getConfiguration().fields.count
    }
    
    fileprivate func configure(listingCell: ListingDetailsListingCell, atIndexPath indexPath: IndexPath) {
        let configuration = delegate.getConfiguration()
        let currentMode = configuration.mode
        let listing = configuration.listing
        
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
        
        if let localPhoto = listing.photo {
            listingCell.photoImageView.image = localPhoto
            delegate.didGet(listingImage: localPhoto)
        } else {
            listingCell.tag = indexPath.row
            ImageManager.sharedInstance.downloadImage(url: listing.pictureURL) { [weak self] image in
                //Make sure the cell hasn't been reused by the time the image is downloaded
                guard listingCell.tag == indexPath.row else { return }
                
                guard let image = image else { return }
                self?.delegate.didGet(listingImage: image)
                listingCell.photoImageView.image = image
            }
        }
    }
    
    fileprivate func configure(actionCell: ListingDetailsActionCell, forFieldType fieldType: FieldType) {
        let listing = delegate.getConfiguration().listing
        
        actionCell.fieldType = fieldType
        actionCell.delegate = delegate
        
        let title = actionString(forFieldType: fieldType, andListing: listing)
        actionCell.actionButton.setTitle(title, for: .normal)
        
        var backgroundColor = ThemeColors.moochYellow.color()
        let textColor = ThemeColors.moochBlack.color()
        
        //Set the action button to be disabled for the contact seller button when the user already contacted them
        if fieldType == .contactSeller && LocalUserManager.sharedInstance.localUser != nil && listing.isOwnerContactedBy(by: LocalUserManager.sharedInstance.localUser!.user) {
            backgroundColor = ThemeColors.moochYellowDisabled.color()
            actionCell.actionButton.isUserInteractionEnabled = false
        }
        
        if fieldType == delegate.getConfiguration().firstActionFieldType() {
            actionCell.actionButton.backgroundColor = backgroundColor
            actionCell.actionButton.setTitleColor(textColor, for: UIControlState.normal)
        } else {
            //The buttons that aren't the first button get styled with the a white background and a gray border
            styleBorderedRoundedButton(actionCell.actionButton, borderWidth: 1.5, borderColor: ThemeColors.moochGray.color(), textColor: textColor, backgroundColor: ThemeColors.moochWhite.color())
        }
    }
    
    fileprivate func configure(listingDetailsListingDescriptionCell: ListingDetailsListingDescriptionCell) {
        let listing = delegate.getConfiguration().listing
        
        let descriptionText = (listing.description != nil) ? listing.description! : Strings.ListingDetails.listingDesriptionNoDescription.rawValue
        listingDetailsListingDescriptionCell.descriptionLabel.text = descriptionText
        
        listingDetailsListingDescriptionCell.bottomSeperator.isHidden = delegate.getConfiguration().isListingDescriptionLastField()
    }
    
    fileprivate func configure(listingDetailsUserCell: ListingDetailsUserCell, atIndexPath indexPath: IndexPath) {
        let listing = delegate.getConfiguration().listing
        
        listingDetailsUserCell.delegate = delegate
        listingDetailsUserCell.setIconsAndButtons(with: ThemeColors.moochBlack.color())
        
        var isShowingSeller: Bool
        switch delegate.getConfiguration().mode {
        case .viewingOtherUsersListing, .viewingOtherUsersCompletedListing:
            isShowingSeller = true
        case .viewingThisUsersListing, .viewingThisUsersCompletedListing:
            isShowingSeller = false
        }
        
        var user: User!
        if isShowingSeller {
            user = listing.owner
        } else {
            user = listing.acceptedUser
        }
        
        guard let listingUserToShow = user else { return }
        
        listingDetailsUserCell.userNameLabel.text = listingUserToShow.name
        listingDetailsUserCell.userImageView.image = UIImage(named: "defaultProfilePhoto")
        listingDetailsUserCell.userImageView.borderWidth = 1.0
        listingDetailsUserCell.userImageView.borderColor = ThemeColors.moochGray.color()
        
        let type: ListingDetailsUserCell.UserType = isShowingSeller ? .seller : .buyer
        
        var isUserContactInformationVisible: Bool
        switch type {
        case .buyer:
            //The only times the buyer would be sowen would be when a user is viewing their completed listing,
            //and in that case we always want to show the buyer
            isUserContactInformationVisible = true
        case .seller:
            if let localUser = LocalUserManager.sharedInstance.localUser?.user {
                isUserContactInformationVisible = listing.isUserContactInformationVisible(to: localUser)
            } else {
                //Guests can never see seller information
                isUserContactInformationVisible = false
            }
        }
        
        listingDetailsUserCell.setup(with: user, andType: type, isUserContactInformationVisible: isUserContactInformationVisible)
        
        if let thumbnailPictureURL = listingUserToShow.thumbnailPictureURL {
            listingDetailsUserCell.tag = indexPath.row
            ImageManager.sharedInstance.downloadImage(url: thumbnailPictureURL) { image in
                //Make sure the cell hasn't been reused by the time the image is downloaded
                guard listingDetailsUserCell.tag == indexPath.row else { return }
                
                guard let image = image else { return }
                listingDetailsUserCell.userImageView.image = image
            }
        }
    }
    
    fileprivate func configure(listingDetailsInterestedBuyerCell: ListingDetailsInterestedBuyerCell, atIndexPath indexPath: IndexPath) {
        let exchange = delegate.getConfiguration().exchange(forRow: indexPath.row)!
        let interestedBuyer = exchange.buyer
        
        listingDetailsInterestedBuyerCell.delegate = delegate
        listingDetailsInterestedBuyerCell.exchange = exchange
        listingDetailsInterestedBuyerCell.buyerNameLabel.text = interestedBuyer.name
        listingDetailsInterestedBuyerCell.buyerImageView.image = UIImage(named: "defaultProfilePhoto")
        listingDetailsInterestedBuyerCell.buyerImageView.borderWidth = 1.0
        listingDetailsInterestedBuyerCell.buyerImageView.borderColor = ThemeColors.moochGray.color()
        
        let buttonBackgroundColor = ThemeColors.moochWhite.color()
        let buttonTextColor = ThemeColors.moochBlack.color()
        let buttonBorderColor = ThemeColors.moochGray.color()
        styleBorderedRoundedButton(listingDetailsInterestedBuyerCell.acceptBuyerButton, borderWidth: 1.0, borderColor: buttonBorderColor, textColor: buttonTextColor, backgroundColor: buttonBackgroundColor)
        
        if let ownerThumbnailPictureURL = interestedBuyer.thumbnailPictureURL {
            listingDetailsInterestedBuyerCell.tag = indexPath.row
            ImageManager.sharedInstance.downloadImage(url: ownerThumbnailPictureURL) { image in
                //Make sure the cell hasn't been reused by the time the image is downloaded
                guard listingDetailsInterestedBuyerCell.tag == indexPath.row else { return }
                
                guard let image = image else { return }
                listingDetailsInterestedBuyerCell.buyerImageView.image = image
            }
        }
    }
    
    fileprivate func configure(listingDetailsInterestedBuyersHeaderCell: ListingDetailsInterestedBuyersHeaderCell) {
        let text = delegate.getConfiguration().noInterestedBuyersForInterestedBuyersHeader ? "Currently No Interested Buyers" : "Interested Buyers"
        listingDetailsInterestedBuyersHeaderCell.headerLabel.text = text
    }
    
    //Returns a string for a button's text corresponding to the field type
    fileprivate func actionString(forFieldType fieldType: FieldType, andListing listing: Listing) -> String {
        
        switch fieldType {
        case .contactSeller:
            var actionString = Strings.ListingDetails.fieldTypeContactSellerNoContactYetActionString.rawValue
            if LocalUserManager.sharedInstance.localUser != nil && listing.isOwnerContactedBy(by: LocalUserManager.sharedInstance.localUser!.user) {
                actionString = Strings.ListingDetails.fieldTypeContactSellerAlreadyContactedActionString.rawValue
            }
            return actionString
            
        case .viewSellerProfile:
            return Strings.ListingDetails.fieldTypeViewSellerProfileActionString.rawValue
            
        case .endListing:
            return Strings.ListingDetails.fieldTypeEndListingActionString.rawValue
            
        default:
            return ""
        }
    }
    
    private func styleBorderedRoundedButton(_ button: RoundedButton, borderWidth: CGFloat, borderColor: UIColor, textColor: UIColor, backgroundColor: UIColor) {
        button.backgroundColor = backgroundColor
        button.setTitleColor(textColor, for: UIControlState.normal)
        button.borderWidth = borderWidth
        button.borderColor = borderColor
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
        } else if let listingUserCell = cell as? ListingDetailsUserCell {
            configure(listingDetailsUserCell: listingUserCell, atIndexPath: indexPath)
        } else if let interestedBuyerCell = cell as? ListingDetailsInterestedBuyerCell {
            configure(listingDetailsInterestedBuyerCell: interestedBuyerCell, atIndexPath: indexPath)
        } else if let interestedBuyersHeaderCell = cell as? ListingDetailsInterestedBuyersHeaderCell {
            configure(listingDetailsInterestedBuyersHeaderCell: interestedBuyersHeaderCell)
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
            
        case .aboutOtherUser:
            return ListingDetailsUserCell.EstimatedHeight
            
        case .interestedBuyersHeader:
            return ListingDetailsInterestedBuyersHeaderCell.EstimatedHeight
            
        case .interestedBuyer:
            return ListingDetailsInterestedBuyerCell.EstimatedHeight
        }
    }
}
