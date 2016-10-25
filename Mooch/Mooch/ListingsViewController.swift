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
    
    enum Mode {
        case independent    //When its being shown by itself; has to get its own listings
        case nestedInSearch //When its being used by another view controller; given its listings
    }
    
    
    // MARK: Public variables
    
    @IBOutlet var collectionHandler: ListingsCollectionHandler! {
        didSet {
            collectionHandler.delegate = self
        }
    }
    
    //The context the view controller is being used in
    var mode: Mode = .independent
    
    var listings: [Listing] {
        get {
            switch mode {
            case .independent:
                return CommunityListingsManager.sharedInstance.listingsInCurrentCommunity
            case .nestedInSearch:
                return _givenListings
            }
        }
        set {
            //Listings can't be set when not in .nestedInSearch mode
            guard mode == .nestedInSearch else { return }
            _givenListings = newValue
            
            if let collectionHandler = collectionHandler, collectionHandler.isCollectionViewSet {
                collectionHandler.reloadData()
            }
        }
    }
    
    
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
    
    //Used for the listings variable when in .nested mode
    private var _givenListings = [Listing]()

    
    // MARK: Actions
    

    
    // MARK: Public methods
    
    static func instantiateFromStoryboard() -> ListingsViewController {
        let storyboard = UIStoryboard(name: ListingsViewController.StoryboardName, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: ListingsViewController.Identifier) as! ListingsViewController
    }
    
    static func tabBarItem() -> UITabBarItem {
        return UITabBarItem(title: Strings.TabBar.home.rawValue, image: nil, selectedImage: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //The data needs to be reloaded when in .nestedInSearch mode because _givenListings is initially mil
        if mode == .nestedInSearch {
            collectionHandler.reloadData()
        }
    }
    
    override func setup() {
        super.setup()
        
        if mode == .independent {
            loadListings(isRefreshing: false)
            tabBarItem = ListingsViewController.tabBarItem()
            setupNavigationBar()
        }
        
        updateUI()
    }
    
    override func updateUI() {
        super.updateUI()
    
    }
    
    // MARK: Private methods
    
    fileprivate func setupNavigationBar() {
        guard mode == .independent else { return }
        guard let nav = navigationController else { return }
        
        nav.navigationBar.isHidden = false
        
        nav.navigationBar.topItem?.title = Strings.Listings.navigationItemTitle.rawValue
        
        //Remove the text from the nav bar back button so that is doesn't show in view controllers pushed from this view controller
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    fileprivate func loadListings(isRefreshing: Bool) {
        guard mode == .independent else { return }
        
        //This allows the view controller to disable buttons/actions while loading
        state = .loading
        
        if !isRefreshing {
            showLoadingOverlayView(withInformationText: Strings.Listings.loadingListingsOverlay.rawValue, overEntireWindow: false, withUserInteractionEnabled: false, showingProgress: false)
        }
        
        CommunityListingsManager.sharedInstance.loadListingsForCurrentCommunityAndUser() { success, error in
            guard success else {
                //If refreshing and the overlay isn't shown, this method does nothing
                self.hideLoadingOverlayView(animated: true)
                
                self.presentSingleActionAlert(title: Strings.Listings.loadingListingsErrorAlertTitle.rawValue, message: Strings.Listings.loadingListingsErrorAlertMessage.rawValue, actionTitle: Strings.Alert.defaultSingleActionTitle.rawValue)
                self.state = .loaded
                return
            }
            
            //
            //Note: The new listings can be referenced by: CommunityListingsManager.sharedInstance.listingsInCurrentCommunity
            //
            
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
        vc.configuration = ListingDetailsConfiguration.defaultConfiguration(for: .viewingOtherUsersListing, with: listing)

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
    
    //Completely resets the UI and state of the view controller
    fileprivate func resetForStateChange() {
        guard mode == .independent else { return }
        guard let navC = navigationController else { return }
        navC.popToRootViewController(animated: false)
        filterApplied = nil
        loadListings(isRefreshing: false)
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
    
    func shouldAllowPullToRefresh() -> Bool {
        //Only allowed when not nested in search. This is to simplify
        return mode == .independent
    }
    
    func areListingsFromSearch() -> Bool {
        return mode == .nestedInSearch
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
        resetForStateChange()
    }
}

extension ListingsViewController: CommunityChangeListener {
    
    func communityDidChange() {
        resetForStateChange()
    }
}
