//
//  ListingsViewController.swift
//  Mooch
//
//  Created by adam on 9/10/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

class ListingsViewController: MoochViewController {
    
    enum State {
        case loading
        case loaded
    }
    
    
    // MARK: Public variables
    
    @IBOutlet var tableHandler: ListingsTableHandler! {
        didSet {
            tableHandler.delegate = self
        }
    }
    
    var listings = [Listing]() {
        didSet {
            guard let tableHandler = tableHandler else { return }
            tableHandler.updateUI()
        }
    }
    
    
    // MARK: Private variables
    
    static fileprivate let StoryboardName = "Listings"
    static fileprivate let Identifier = "ListingsViewController"
    
    fileprivate var state: State = .loading

    
    // MARK: Actions
    

    
    // MARK: Public methods
    
    static func instantiateFromStoryboard() -> ListingsViewController {
        let storyboard = UIStoryboard(name: ListingsViewController.StoryboardName, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: ListingsViewController.Identifier) as! ListingsViewController
    }
    
    static func tabBarItem() -> UITabBarItem {
        return UITabBarItem(title: Strings.TabBar.home.rawValue, image: nil, selectedImage: nil)
    }
    
    override func setup() {
        super.setup()
        
        loadListings(isRefreshing: false)
        
        tabBarItem = ListingsViewController.tabBarItem()
        setupNavigationBar()
        
        updateUI()
    }
    
    override func updateUI() {
        super.updateUI()
    
    }
    
    // MARK: Private methods
    
    fileprivate func setupNavigationBar() {
        guard let nav = navigationController else { return }
        
        nav.navigationBar.isHidden = false
        
        nav.navigationBar.topItem?.title = Strings.Listings.navigationItemTitle.rawValue
    }
    
    fileprivate func loadListings(isRefreshing: Bool) {
        guard let userCommunityId = LocalUserManager.sharedInstance.userCommunityId else { return }
        
        //This allows the view controller to disable buttons/actions while loading
        state = .loading
        
        if !isRefreshing {
            showLoadingOverlayView(withInformationText: Strings.Listings.loadingListingsOverlay.rawValue, overEntireWindow: false, withUserInteractionEnabled: false, showingProgress: false)
        }
        
        MoochAPI.GETListings(communityId: userCommunityId) { listings, error in
            guard let newListings = listings else {
                //If refreshing and the overlay isn't shown, this method does nothing
                self.hideLoadingOverlayView(animated: true)
                
                self.presentSingleActionAlert(title: Strings.Listings.loadingListingsErrorAlertTitle.rawValue, message: Strings.Listings.loadingListingsErrorAlertMessage.rawValue, actionTitle: Strings.Alert.defaultSingleActionTitle.rawValue)
                self.state = .loaded
                return
            }
            
            //Filter to only show listings this user hasn't posted
            var listingsNotPostedByThisUser = newListings
            if let localUser = LocalUserManager.sharedInstance.localUser {
                listingsNotPostedByThisUser = listingsNotPostedByThisUser.filter({$0.owner.id != localUser.user.id})
            }
            
            self.tableHandler.endRefreshing()
            
            //Setting this causes the table to reload
            self.listings = listingsNotPostedByThisUser
            
            //If refreshing and the overlay isn't shown, this method does nothing
            self.hideLoadingOverlayView(animated: true)
            
            self.state = .loaded
        }
    }
    
    fileprivate func pushListingDetailsViewController(withListing listing: Listing) {
        let vc = ListingDetailsViewController.instantiateFromStoryboard()
        vc.listing = listing
        vc.configuration = ListingDetailsViewController.DefaultViewingOtherUsersListingConfiguration

        navigationController!.pushViewController(vc, animated: true)
    }
}

extension ListingsViewController: ListingsTableHandlerDelegate {
    // MARK: ListingsTableHandlerDelegate
    
    func getListings() -> [Listing] {
        return listings
    }
    
    func didSelect(_ listing: Listing) {
        pushListingDetailsViewController(withListing: listing)
    }
    
    func refresh() {
        loadListings(isRefreshing: true)
    }
}
