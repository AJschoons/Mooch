//
//  ProfileViewController.swift
//  Mooch
//
//  Created by adam on 9/12/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

protocol ProfileViewControllerDelegate: class {
    func didLogOut()
}

class ProfileViewController: MoochModalViewController {
    
    // MARK: Public variables
    
    weak var delegate: ProfileViewControllerDelegate!
    
    
    // MARK: Private variables
    
    static fileprivate let StoryboardName = "Profile"
    static fileprivate let Identifier = "ProfileViewController"
    
    fileprivate var backButton: UIBarButtonItem!
    fileprivate var editButton: UIBarButtonItem!
    
    // MARK: Actions
    
    func onBackAction() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onLogOutAction() {
        LocalUserManager.sharedInstance.logout()
        delegate.didLogOut()
        dismiss(animated: true, completion: nil)
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
        return storyboard.instantiateViewController(withIdentifier: ProfileViewController.Identifier) as! ProfileViewController
    }
    
    
    // MARK: Private methods
    
    fileprivate func setupNavigationBar() {
        backButton = UIBarButtonItem(title: Strings.Profile.buttonTitleBack.rawValue, style: UIBarButtonItemStyle.plain, target: self, action: #selector(onBackAction))
        editButton = UIBarButtonItem(title: Strings.Profile.buttonTitleEdit.rawValue, style: UIBarButtonItemStyle.plain, target: self, action: #selector(onEditProfileAction))
        
        title = Strings.Profile.title.rawValue
        
        navigationItem.leftBarButtonItem = backButton
        navigationItem.rightBarButtonItem = editButton
    }
}
