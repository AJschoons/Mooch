//
//  ListingDetailsViewController.swift
//  Mooch
//
//  Created by adam on 9/11/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

class ListingDetailsViewController: MoochViewController {
    
    //A configuration to setup the class with
    struct Configuration {
        var mode: Mode
        
        var title: String
        var leftBarButtons: [BarButtonType]?
        var rightBarButtons: [BarButtonType]?
        
        //The fields that should be shown
        var fields: [FieldType]
        
        enum Mode {
            case viewingOtherUsersListing
            case viewingThisUsersListing
            case viewingOtherUsersCompletedListing
            case viewingThisUsersCompletedListing
        }
        
        //The bar buttons that can be added
        enum BarButtonType {
            case edit
        }
        
        enum FieldType {
            //Information
            case listing
            case listingDescription
            case aboutSeller
            
            //Actions: Make sure to update isAction() when adding an action
            case contactSeller
            case viewSellerProfile
            case endListing
            
            
            func isAction() -> Bool {
                return self == .contactSeller || self == .viewSellerProfile || self == .endListing
            }
        }
        
        func isListingDescriptionLastField() -> Bool {
            return fields.last == .listingDescription
        }
        
        func firstActionFieldType() -> FieldType? {
            for field in fields {
                if field.isAction() {
                    return field
                }
            }
            return nil
        }
    }
    
    // MARK: Public variables
    
    static let DefaultViewingOtherUsersListingConfiguration = Configuration(mode: .viewingOtherUsersListing, title: Strings.ListingDetails.title.rawValue, leftBarButtons: nil, rightBarButtons: nil, fields: [.listing, .contactSeller, .viewSellerProfile, .listingDescription, .aboutSeller])
    static let DefaultViewingThisUsersListingConfiguration = Configuration(mode: .viewingThisUsersListing, title: Strings.ListingDetails.title.rawValue, leftBarButtons: nil, rightBarButtons: [.edit], fields: [.listing, .endListing, .listingDescription])
    static let DefaultViewingOtherUsersCompletedListingConfiguration = Configuration(mode: .viewingOtherUsersCompletedListing, title: Strings.ListingDetails.title.rawValue, leftBarButtons: nil, rightBarButtons: nil, fields: [.listing, .viewSellerProfile, .listingDescription, .aboutSeller])
    static let DefaultViewingThisUsersCompletedListingConfiguration = Configuration(mode: .viewingOtherUsersCompletedListing, title: Strings.ListingDetails.title.rawValue, leftBarButtons: nil, rightBarButtons: nil, fields: [.listing, .listingDescription])
    
    @IBOutlet var tableHandler: ListingDetailsTableHandler! {
        didSet {
            tableHandler.delegate = self
        }
    }
    
    //The configuration used to setup the class
    var configuration: Configuration!
    
    var listing: Listing!

    
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
}

extension ListingDetailsViewController: ListingDetailsTableHandlerDelegate {
    
    func getConfiguration() -> ListingDetailsViewController.Configuration {
        return configuration
    }
    
    func getListing() -> Listing {
        return listing
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
