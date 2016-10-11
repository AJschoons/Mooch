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
    
    fileprivate var loginButton: UIBarButtonItem!
    fileprivate var profileButton: UIBarButtonItem!
    fileprivate var addListingButton: UIBarButtonItem!
    
    fileprivate var state: State = .loading
    
    // MARK: Actions
    
    func onLoginAction() {
        guard state == .loaded else { return }
        presentLoginViewController()
    }
    
    func onProfileAction() {
        guard state == .loaded else { return }
        presentProfileViewController()
    }
    
    func onAddListingAction() {
        guard state == .loaded else { return }
        presentEditListingViewController()
    }
    
    // MARK: Public methods
    
    static func instantiateFromStoryboard() -> ListingsViewController {
        let storyboard = UIStoryboard(name: ListingsViewController.StoryboardName, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: ListingsViewController.Identifier) as! ListingsViewController
    }
    
    override func setup() {
        super.setup()
        
        loadListings(isRefreshing: false)
        
        setupNavigationBar()
        
        updateUI()
    }
    
    override func updateUI() {
        super.updateUI()
        
        updateNavigationBar()
    }
    
    // MARK: Private methods
    
    fileprivate func setupNavigationBar() {
        guard let nav = navigationController else { return }
        
        nav.navigationBar.isHidden = false
        
        title = Strings.Listings.title.rawValue
        
        loginButton = UIBarButtonItem(title: Strings.Listings.buttonTitleLogin.rawValue, style: UIBarButtonItemStyle.plain, target: self, action: #selector(onLoginAction))
        profileButton = UIBarButtonItem(title: Strings.Listings.buttonTitleProfile.rawValue, style: UIBarButtonItemStyle.plain, target: self, action: #selector(onProfileAction))
        addListingButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(onAddListingAction))
    }
    
    fileprivate func updateNavigationBar() {
        switch LocalUserManager.sharedInstance.state {
        case .guest:
            navigationItem.leftBarButtonItems = [loginButton]
            navigationItem.rightBarButtonItems = nil
        case .loggedIn:
            navigationItem.leftBarButtonItems = [profileButton]
            navigationItem.rightBarButtonItems = [addListingButton]
        }
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
    
    fileprivate func presentLoginViewController() {
        guard let navC = navigationController else { return }

        let vc = LoginViewController.instantiateFromStoryboard()
        vc.delegate = self
        
        navC.present(vc, animated: true, completion: nil)
    }
    
    fileprivate func presentProfileViewController() {
        guard let navC = navigationController else { return }
        
        let vc = ProfileViewController.instantiateFromStoryboard()
        vc.delegate = self
        let profileNavC = UINavigationController(rootViewController: vc)
        
        navC.present(profileNavC, animated: true, completion: nil)
    }
    
    fileprivate func presentEditListingViewController() {
        let vc = EditListingViewController.instantiateFromStoryboard()
        vc.configuration = EditListingViewController.DefaultCreatingConfiguration
        vc.delegate = self
        let navC = UINavigationController(rootViewController: vc)
        present(navC, animated: true, completion: nil)
    }
    
    fileprivate func presentListingCreatedAlert(forListingWithTitle listingTitle: String) {
        let title = Strings.Listings.listingCreatedAlertTitle.rawValue
        let message = "\(Strings.Listings.listingCreatedAlertMessageFirstPart.rawValue)\(listingTitle)\(Strings.Listings.listingCreatedAlertMessageSecondPart.rawValue)"
        let actionTitle = Strings.Alert.defaultSingleActionTitle.rawValue
        presentSingleActionAlert(title: title, message: message, actionTitle: actionTitle)
    }
    
    fileprivate func add(listing: Listing) {
        listings.insert(listing, at: 0)
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

extension ListingsViewController: LoginViewControllerDelegate {
    
    func loginViewControllerDidLogin(localUser: LocalUser) {
        updateUI()
        loadListings(isRefreshing: false)
    }
}

extension ListingsViewController: EditListingViewControllerDelegate {
    
    func editListingViewControllerDidFinishEditing(withListingInformation editedListingInformation: EditedListingInformation) {
        presentListingCreatedAlert(forListingWithTitle: editedListingInformation.title!)
    }
}

extension ListingsViewController: ProfileViewControllerDelegate {
    
    func didLogOut() {
        updateUI()
        loadListings(isRefreshing: false)
    }
}
