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
        
        //The fields that should be shown
        var fields: [FieldType]
        
        enum Mode {
            case viewingOtherUsersListing
            case viewingThisUsersListing
            case viewingOtherUsersCompletedListing
        }
        
        enum FieldType {
            //Information
            case listing
            
            //Actions
            case contactSeller
            case viewSellerProfile
            case rateSeller
            case editListing
            case deleteListing
            case addAnotherListing
        }
    }
    
    // MARK: Public variables
    
    static let DefaultViewingOtherUsersListingConfiguration = Configuration(mode: .viewingOtherUsersListing, title: "Listing Details", fields: [.listing, .viewSellerProfile, .contactSeller])
    static let DefaultViewingThisUsersListingConfiguration = Configuration(mode: .viewingThisUsersListing, title: "Listing Details", fields: [.listing, .editListing, .deleteListing, .addAnotherListing])
    static let DefaultViewingOtherUsersCompletedListingConfiguration = Configuration(mode: .viewingThisUsersListing, title: "Listing Details", fields: [.listing, .viewSellerProfile, .rateSeller])
    
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
    
    // MARK: Actions
    
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
        title = configuration.title
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
