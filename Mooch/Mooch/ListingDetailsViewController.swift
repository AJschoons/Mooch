//
//  ListingDetailsViewController.swift
//  Mooch
//
//  Created by adam on 9/11/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

class ListingDetailsViewController: MoochViewController {
    
    typealias Configuration = ListingDetailsConfiguration
    
    // MARK: Public variables
    
    
    @IBOutlet var tableHandler: ListingDetailsTableHandler! {
        didSet {
            tableHandler.delegate = self
        }
    }
    
    //The configuration used to setup the class
    var configuration: Configuration!

    
    // MARK: Private variables
    
    static fileprivate let StoryboardName = "ListingDetails"
    static fileprivate let Identifier = "ListingDetailsViewController"
    
    fileprivate var editButton: UIBarButtonItem!
    
    //This variable is needed so we can pass the listing image to the EditListingVC for editing
    fileprivate var listingImage: UIImage?
    
    // MARK: Actions
    
    func onEditAction() {
        editListing()
    }
    
    func onContactSellerAction() {
        contactSeller()
    }
    
    func onViewSellerProfileAction() {
        showSellerProfile()
    }
    
    func onEndListingAction() {
        deleteListing()
    }
    
    func onDidAccept(exchange: Exchange) {
        accept(exchange: exchange)
    }
    
    // MARK: Public methods
    
    override func setup() {
        super.setup()
        
        setupNavigationBar()
        
        updateUI()
        
        sendListingVisitToAPI()
    }
    
    override func updateUI() {
        super.updateUI()
        
    }
    
    static func instantiateFromStoryboard() -> ListingDetailsViewController {
        let storyboard = UIStoryboard(name: ListingDetailsViewController.StoryboardName, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: ListingDetailsViewController.Identifier) as! ListingDetailsViewController
    }
    
    // MARK: Private methods
    
    fileprivate func setupNavigationBar() {
        editButton = UIBarButtonItem(image: UIImage(named: "settings"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(onEditAction))
        
        title = configuration.title
        
        if let leftButtons = configuration.leftBarButtons {
            navigationItem.leftBarButtonItems = barButtons(fromTypeList: leftButtons)
        } else {
            navigationItem.leftBarButtonItems = nil
        }
        
        if let rightButtons = configuration.rightBarButtons {
            navigationItem.rightBarButtonItems = barButtons(fromTypeList: rightButtons)
        } else {
            navigationItem.rightBarButtonItems = nil
        }
        
        //Remove the text from the nav bar back button so that is doesn't show in view controllers pushed from this view controller
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    fileprivate func barButtons(fromTypeList typeList: [Configuration.BarButtonType]) -> [UIBarButtonItem] {
        return typeList.map({barButton(forType: $0)})
    }
    
    fileprivate func barButton(forType type: Configuration.BarButtonType) -> UIBarButtonItem {
        switch type {
        case .edit:
            return editButton
        }
    }
    
    fileprivate func editListing() {
        guard let listingImage = listingImage else {
            presentSingleActionAlert(title: "Cannot Edit Listing", message: "Please wait for the listing's image to download, then try again", actionTitle: Strings.Alert.defaultSingleActionTitle.rawValue)
            return
        }
        
        presentEditListingViewController(for: configuration.listing, withImage: listingImage)
    }
    
    fileprivate func contactSeller() {
        guard let localUser = LocalUserManager.sharedInstance.localUser else {
            presentSingleActionAlert(title: "Guests cannot contact sellers", message: "Please login or create an account, and then try again", actionTitle: Strings.Alert.defaultSingleActionTitle.rawValue)
            return
        }
        
        MoochAPI.POSTExchange(listingOwnerId: configuration.listing.owner.id, listingId: configuration.listing.id) { success, error in
            guard success else {
                self.presentSingleActionAlert(title: "Problem Contacting Seller", message: "Please try again", actionTitle: Strings.Alert.defaultSingleActionTitle.rawValue)
                return
            }
            
            //Update the listing for this view controller, AND make sure it's updated
            //with the CommunityListingsManager so the change persists after leaving this view controller
            self.configuration.listing.addInterestedBuyer(localUser.user)
            CommunityListingsManager.sharedInstance.updateInformation(for: self.configuration.listing)
            
            guard let contactSellerRow = self.configuration.firstIndex(of: .contactSeller) else {
                return
            }
            self.tableHandler.reloadRow(at: IndexPath(row: contactSellerRow, section: 0))
        }
    }
    
    fileprivate func deleteListing() {
        guard let localUser = LocalUserManager.sharedInstance.localUser else { return }
        
        MoochAPI.DELETEListing(ownerId: localUser.user.id, listingId: configuration.listing.id) { success, error in
            guard success else {
                self.presentSingleActionAlert(title: "Problem Ending Listing", message: "Please try again", actionTitle: Strings.Alert.defaultSingleActionTitle.rawValue)
                return
            }
            
            //Make sure the change is updated locally in the CommunityListingsManager so the change persists after leaving this view controller
            CommunityListingsManager.sharedInstance.delete(self.configuration.listing)
            
            if let navigationController = self.navigationController {
                navigationController.popViewController(animated: true)
            }
        }
    }
    
    fileprivate func accept(exchange: Exchange) {
        
        MoochAPI.GETExchangeAccept(listingOwnerId: exchange.sellerUserId, listingId: exchange.listingId, exchangeId: exchange.id) { success, error in
            guard success else {
                self.presentSingleActionAlert(title: "Problem Accepting Exchange", message: "Please try again", actionTitle: Strings.Alert.defaultSingleActionTitle.rawValue)
                return
            }
            
            //Update the listing for this view controller, AND make sure it's updated locally
            //with the CommunityListingsManager so the change persists after leaving this view controller
            self.configuration.listing.accept(exchange: exchange)
            CommunityListingsManager.sharedInstance.updateInformation(for: self.configuration.listing)
            
            self.configuration = ListingDetailsConfiguration.defaultConfiguration(for: .viewingThisUsersCompletedListing, with: self.configuration.listing, isViewingSellerProfileNotAllowed: true)
            self.tableHandler.reloadData()
        }
    }
    
    fileprivate func showSellerProfile() {
        let profileViewController = ProfileViewController.instantiateFromStoryboard()
        profileViewController.configuration = ProfileConfiguration.defaultConfiguration(for: .seller)
        profileViewController.updateWith(user: configuration.listing.owner)
        
        navigationController?.pushViewController(profileViewController, animated: true)
    }
    
    fileprivate func presentEditListingViewController(for listing: Listing, withImage image: UIImage) {
        let vc = EditListingViewController.instantiateFromStoryboard()
        vc.configuration = EditListingConfiguration.defaultConfiguration(for: .editing)
        vc.setListing(listing, withPhoto: image)
        vc.delegate = self
        
        let navC = UINavigationController(rootViewController: vc)
        present(navC, animated: true, completion: nil)
    }
    
    fileprivate func presentPhoneNumberOptionsActionSheet() {
        guard let phoneNumber = configuration.listing.owner.contactInformation.phone else {
            return
        }
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let textAction = UIAlertAction(title: "Text", style: .default) { _ in
            self.openMessagesApp(withNumber: phoneNumber)
        }
        let callAction = UIAlertAction(title: "Call", style: .default) { _ in
            self.openPhoneApp(withNumber: phoneNumber)
        }
        let cancelAction = UIAlertAction(title: Strings.TabBar.loggedOutMyProfileTabActionSheetActionTitleCancel.rawValue, style: .cancel, handler: nil)
        
        actionSheet.addAction(textAction)
        actionSheet.addAction(callAction)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    fileprivate func openMailApp(withEmail email: String) {
        let cleanedEmail = cleanURLFormatting(forEmail: email)
        if let emailUrl =  URL(string: "mailto:\(cleanedEmail)") {
            UIApplication.shared.openURL(emailUrl)
        }
    }
    
    fileprivate func openPhoneApp(withNumber number: String) {
        let cleanedNumber = cleanURLFormatting(forNumber: number)
        if let textUrl =  URL(string: "tel:\(cleanedNumber)") {
            UIApplication.shared.openURL(textUrl)
        }
    }
    
    fileprivate func openMessagesApp(withNumber number: String) {
        let cleanedNumber = cleanURLFormatting(forNumber: number)
        if let textUrl =  URL(string: "sms:\(cleanedNumber)") {
            UIApplication.shared.openURL(textUrl)
        }
    }
    
    fileprivate func cleanURLFormatting(forNumber number: String) -> String {
        //http://stackoverflow.com/questions/6323171/making-a-phone-call-in-an-ios-application
        return number.components(separatedBy: CharacterSet(charactersIn: "0123456789-+()").inverted).joined(separator: "")
    }
    
    fileprivate func cleanURLFormatting(forEmail email: String) -> String {
        return email.components(separatedBy: CharacterSet.whitespacesAndNewlines).joined(separator: "")
    }
    
    fileprivate func sendListingVisitToAPI() {
        guard configuration.mode == Configuration.Mode.viewingOtherUsersListing else { return }
        
        MoochAPI.GETListingVisit(listingId: configuration.listing.id) { success, error in
            //Do nothing, we don't care if it suceeds or fails (once we know it initially works, of course)
        }
    }
}

extension ListingDetailsViewController: ListingDetailsTableHandlerDelegate {
    
    func getConfiguration() -> Configuration {
        return configuration
    }
    
    func tabBarHeight() -> CGFloat {
        return (tabBarController != nil) ? tabBarController!.tabBar.frame.height : CGFloat(0.0)
    }
    
    func didGet(listingImage: UIImage) {
        self.listingImage = listingImage
    }
}

extension ListingDetailsViewController: ListingDetailsActionCellDelegate {
    
    func onActionButton(forFieldType fieldType: ListingDetailsViewController.Configuration.FieldType) {
        guard fieldType.isAction() else { return }
        switch fieldType {
        
        case .contactSeller:
            onContactSellerAction()
            
        case .viewSellerProfile:
            onViewSellerProfileAction()
            
        case .endListing:
            onEndListingAction()
            
        default:
            return
        }
    }
}

extension ListingDetailsViewController: ListingDetailsInterestedBuyerCellDelegate {
    
    func didAccept(exchange: Exchange) {
        onDidAccept(exchange: exchange)
    }
}

extension ListingDetailsViewController: ListingDetailsUserCellDelegate {
    
    func onPhone() {
        presentPhoneNumberOptionsActionSheet()
    }
    
    func onEmail() {
        openMailApp(withEmail: configuration.listing.owner.contactInformation.email)
    }
}

extension ListingDetailsViewController: EditListingViewControllerDelegate {
    
    func editListingViewControllerDidFinishEditing(with editedListing: Listing, isNew: Bool) {
        //Creating a new listing from the listing details view controller is not allowed; they should only be edited
        guard !isNew else { return }
        
        CommunityListingsManager.sharedInstance.updateInformation(for: editedListing)
        configuration.listing = editedListing
        tableHandler.reloadData()
        
        dismiss(animated: true, completion: nil)
    }
    
    func editListingViewControllerDidCancel() {
        dismiss(animated: true, completion: nil)
    }
}
