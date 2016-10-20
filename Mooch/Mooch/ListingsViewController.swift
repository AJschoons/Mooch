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
    
    @IBOutlet var collectionHandler: ListingsCollectionHandler! {
        didSet {
            collectionHandler.delegate = self
        }
    }
    
    var listings = [Listing]()
    
    
    // MARK: Private variables
    
    static fileprivate let StoryboardName = "Listings"
    static fileprivate let Identifier = "ListingsViewController"
    
    fileprivate var state: State = .loading
    
    fileprivate var filterApplied: ListingFilter?
    
    
    fileprivate var filteredListings: [Listing] {
        guard let filter = filterApplied else {
            return [Listing]()
        }
        
        return ListingProcessingHandler.filter(listings: listings, with: filter)
    }

    
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
            
            //Must be set before reloading data
            self.listings = listingsNotPostedByThisUser
            
            if self.collectionHandler.isRefreshing {
                self.collectionHandler.endRefreshingAndReloadData()
            } else {
                self.collectionHandler.reloadData()
            }
            
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
    
    fileprivate func presentListingsFilterViewController() {
        let vc = ListingsFilterViewController.instantiateFromStoryboard()
        vc.delegate = self
        let navC = UINavigationController(rootViewController: vc)
        
        //http://stackoverflow.com/questions/21760698/ios-modalview-with-background-transparent
        vc.providesPresentationContextTransitionStyle = true
        vc.definesPresentationContext = true
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        navC.providesPresentationContextTransitionStyle = true
        navC.definesPresentationContext = true
        navC.modalPresentationStyle = .overFullScreen
        navC.modalTransitionStyle = .crossDissolve
        
        if let filterApplied = filterApplied {
            vc.filterApplied = filterApplied
        }
        
        present(navC, animated: true, completion: nil)
    }
}

extension ListingsViewController: ListingsCollectionHandlerDelegate {
    
    //Returns the listings when a filter isn't applied, or returns the filtered listings when a filter is applied
    func getListings() -> [Listing] {
        if filterApplied != nil {
            return filteredListings
        } else {
            return listings
        }
    }
    
    func didSelect(_ listing: Listing) {
        pushListingDetailsViewController(withListing: listing)
    }
    
    func refresh() {
        loadListings(isRefreshing: true)
    }
    
    func hasListingsButNoneMatchFilter() -> Bool {
        guard filterApplied != nil else {
            //We need to have a filter for this to be true
            return false
        }
        
        return filteredListings.count == 0 && listings.count > 0
    }
}

extension ListingsViewController: ListingsCollectionHeaderViewDelegate {
    
    func onFilterAction() {
        presentListingsFilterViewController()
    }
}

extension ListingsViewController: ListingsFilterViewControllerDelegate {
    
    func didApply(listingFilter: ListingFilter) {
        filterApplied = listingFilter
        collectionHandler.reloadData()
    }
    
    func didClearFilters() {
        filterApplied = nil
        collectionHandler.reloadData()
    }
}

extension ListingsViewController: LocalUserStateChangeListener {
    
    func localUserStateDidChange(to: LocalUserManager.LocalUserState) {
        guard let navC = navigationController else { return }
        navC.popToRootViewController(animated: false)
        filterApplied = nil
        loadListings(isRefreshing: false)
    }
}

extension ListingsViewController: CommunityChangeListener {
    
    func communityDidChange() {
        guard let navC = navigationController else { return }
        navC.popToRootViewController(animated: false)
        filterApplied = nil
        loadListings(isRefreshing: false)
    }
}
