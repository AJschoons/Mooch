//
//  ListingsViewController.swift
//  Mooch
//
//  Created by adam on 9/10/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

class ListingsViewController: MoochViewController {
    
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
    
    // MARK: Actions
    
    func onLoginAction() {
        presentLoginViewController()
    }
    
    func onProfileAction() {
        presentProfileViewController()
    }
    
    func onAddListingAction() {
        presentEditListingViewController()
    }
    
    // MARK: Public methods
    
    static func instantiateFromStoryboard() -> ListingsViewController {
        let storyboard = UIStoryboard(name: ListingsViewController.StoryboardName, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: ListingsViewController.Identifier) as! ListingsViewController
    }
    
    override func setup() {
        super.setup()
        
        setupNavigationBar()
        setupDummyData()
        
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
        
        title = "Listings"
        
        loginButton = UIBarButtonItem(title: "Login", style: UIBarButtonItemStyle.plain, target: self, action: #selector(onLoginAction))
        profileButton = UIBarButtonItem(title: "Profile", style: UIBarButtonItemStyle.plain, target: self, action: #selector(onProfileAction))
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
    
    fileprivate func setupDummyData() {
        var dummyListings = [Listing]()
        for i in 1...5 {
            dummyListings.append(Listing.createDummy(fromNumber: i))
        }
        listings = dummyListings
    }
    
    fileprivate func pushListingDetailsViewController(withListing listing: Listing) {
        let vc = ListingDetailsViewController.instantiateFromStoryboard()
        vc.listing = listing
        vc.configuration = ListingDetailsViewController.DefaultViewingOtherUsersListingConfiguration

        navigationController!.pushViewController(vc, animated: true)
    }
    
    fileprivate func presentLoginViewController() {
        guard let navC = navigationController else { return }

        let vc = LoginViewController()
        vc.delegate = self
        vc.modalTransitionStyle = .crossDissolve
        
        navC.present(vc, animated: true, completion: nil)
    }
    
    fileprivate func presentProfileViewController() {
        guard let navC = navigationController else { return }
        
        let vc = ProfileViewController.instantiateFromStoryboard()
        let profileNavC = UINavigationController(rootViewController: vc)
        vc.modalTransitionStyle = .crossDissolve
        
        //Needed for blurring over current view
//        vc.modalPresentationStyle = .overFullScreen
//        profileNavC.modalPresentationStyle = .overFullScreen
        
        navC.present(profileNavC, animated: true, completion: nil)
    }
    
    fileprivate func presentEditListingViewController() {
        let vc = EditListingViewController.instantiateFromStoryboard()
        vc.configuration = EditListingViewController.DefaultCreatingConfiguration
        vc.delegate = self
        let navC = UINavigationController(rootViewController: vc)
        present(navC, animated: true, completion: nil)
    }
    
    fileprivate func presentListingCreatedAlert(forListing listing: Listing) {
        let alert = UIAlertController(title: "Listing Created", message: "Your listing with the title \"\(listing.title)\" is now visible to all users in your community!", preferredStyle: .alert)
        let action = UIAlertAction(title: "Keep Mooching", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func add(listing: Listing) {
        listings.insert(listing, at: 0)
    }
    
    fileprivate func createListing(fromEditedListingInformation eli: EditedListingInformation) -> Listing {
        return Listing(id: -1, photo: eli.photo!, title: eli.title!, description: eli.description, price: eli.price!, isFree: false, quantity: eli.quantity!, categoryId: eli.categoryId!, isAvailable: true, createdAt: Date(), modifiedAt: Date(), owner: LocalUserManager.sharedInstance.localUser!.user, pictureURL: "", thumbnailPictureURL: "", communityId: 1)
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
}

extension ListingsViewController: LoginViewControllerDelegate {
    
    func loginViewControllerDidLogin(withUser loggedInUser: User) {
        updateUI()
        navigationController!.dismiss(animated: true, completion: nil)
    }
}

extension ListingsViewController: EditListingViewControllerDelegate {
    
    func editListingViewControllerDidFinishEditing(withListingInformation editedListingInformation: EditedListingInformation) {
        let newListing = createListing(fromEditedListingInformation: editedListingInformation)
        add(listing: newListing)
        presentListingCreatedAlert(forListing: newListing)
    }
}
