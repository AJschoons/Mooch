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
    
    // MARK: Actions
    
    func onEditAction() {
        print("edit action")
    }
    
    func onContactSellerAction() {
        print("contact seller action")
    }
    
    func onViewSellerProfileAction() {
        print("view seller action")
    }
    
    func onEndListingAction() {
        print("end listing action")
    }
    
    func onDidAcceptBuyer(_ buyer: User) {
        print("did accept buyer ", buyer)
    }
    
    // MARK: Public methods
    
    override func setup() {
        super.setup()
        
        setupNavigationBar()
        
        updateUI()
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
}

extension ListingDetailsViewController: ListingDetailsTableHandlerDelegate {
    
    func getConfiguration() -> Configuration {
        return configuration
    }
    
    func tabBarHeight() -> CGFloat {
        return (tabBarController != nil) ? tabBarController!.tabBar.frame.height : CGFloat(0.0)
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
    
    func didAccept(buyer: User) {
        onDidAcceptBuyer(buyer)
    }
}

extension ListingDetailsViewController: ListingDetailsSellerCellDelegate {
    
    func onPhone() {
        presentPhoneNumberOptionsActionSheet()
    }
    
    func onEmail() {
        openMailApp(withEmail: configuration.listing.owner.contactInformation.email)
    }
}
