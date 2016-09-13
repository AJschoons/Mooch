//
//  ProfileViewController.swift
//  Mooch
//
//  Created by adam on 9/12/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

class ProfileViewController: MoochModalViewController {
    
    // MARK: Public variables
    
    // MARK: Private variables
    
    static private let StoryboardName = "Profile"
    static private let Identifier = "ProfileViewController"
    
    private var backButton: UIBarButtonItem!
    private var editButton: UIBarButtonItem!
    
    // MARK: Actions
    
    func onBackAction() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func onEditProfileAction() {
        
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
    
    static func instantiateFromStoryboard() -> ProfileViewController {
        let storyboard = UIStoryboard(name: ProfileViewController.StoryboardName, bundle: nil)
        return storyboard.instantiateViewControllerWithIdentifier(ProfileViewController.Identifier) as! ProfileViewController
    }
    
    
    // MARK: Private methods
    
    private func setupNavigationBar() {
        backButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(onBackAction))
        editButton = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(onEditProfileAction))
        
        
        title = "Profile"
        
        navigationItem.leftBarButtonItem = backButton
        navigationItem.rightBarButtonItem = editButton
    }
}
