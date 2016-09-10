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
    
    @IBOutlet weak var tableHandler: ListingsTableHandler!
    
    // MARK: Private variables
    
    private var loginButton: UIBarButtonItem!
    private var profileButton: UIBarButtonItem!
    private var addListingButton: UIBarButtonItem!
    
    // MARK: Actions
    
    func onLoginAction() {
        
    }
    
    func onProfileAction() {
        
    }
    
    func onAddListingAction() {
        
    }
    
    // MARK: Public methods
    
    override func setup() {
        super.setup()
        
        setupNavigationBar()
        
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
}
