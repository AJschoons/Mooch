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
    
    private var loginButton: UIBarButtonItem!
    private var profileButton: UIBarButtonItem!
    private var addListingButton: UIBarButtonItem!
    
    // MARK: Actions
    
    func onLoginAction() {
        presentLoginViewController()
    }
    
    func onProfileAction() {
        
    }
    
    func onAddListingAction() {
        
    }
    
    // MARK: Public methods
    
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
    
    private func setupNavigationBar() {
        guard let nav = navigationController else { return }
        
        nav.navigationBar.hidden = false
        
        title = "Listings"
        
        loginButton = UIBarButtonItem(title: "Login", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(onLoginAction))
        profileButton = UIBarButtonItem(title: "Profile", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(onProfileAction))
        addListingButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(onAddListingAction))
    }
    
    private func updateNavigationBar() {
        switch LocalUserManager.sharedInstance.state {
        case .Guest:
            navigationItem.leftBarButtonItems = [loginButton]
            navigationItem.rightBarButtonItems = nil
        case .LoggedIn:
            navigationItem.leftBarButtonItems = [profileButton]
            navigationItem.rightBarButtonItems = [addListingButton]
        }
    }
    
    private func setupDummyData() {
        var dummyListings = [Listing]()
        for i in 1...5 {
            dummyListings.append(Listing.createDummy(fromNumber: i))
        }
        listings = dummyListings
    }
    
    private func pushListingDetailsViewController(withListing listing: Listing) {
        let vc = ListingDetailsViewController.instantiateFromStoryboard()
        vc.listing = listing
        
        navigationController!.pushViewController(vc, animated: true)
    }
    
    private func presentLoginViewController() {
        guard let navC = navigationController else { return }

        let vc = LoginViewController()
        
        vc.modalTransitionStyle = .CrossDissolve
        
        //Needed for blurring over current view
        vc.modalPresentationStyle = .OverFullScreen
        
        navC.presentViewController(vc, animated: true, completion: nil)
    }
}

extension ListingsViewController: ListingsTableHandlerDelegate {
    // MARK: ListingsTableHandlerDelegate
    
    func getListings() -> [Listing] {
        return listings
    }
    
    func didSelect(listing: Listing) {
        pushListingDetailsViewController(withListing: listing)
    }
}