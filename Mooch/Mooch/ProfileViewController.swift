//
//  ProfileViewController.swift
//  Mooch
//
//  Created by adam on 9/12/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

protocol ProfileViewControllerDelegate: class {
    func profileViewControllerDidLogOutUser()
}

class ProfileViewController: MoochViewController {
    
    // MARK: Public variables
    
    weak var delegate: ProfileViewControllerDelegate?
    
    // MARK: Private variables
    
    static fileprivate let StoryboardName = "Profile"
    static fileprivate let Identifier = "ProfileViewController"
    
    fileprivate var backButton: UIBarButtonItem!
    fileprivate var editButton: UIBarButtonItem!
    
    // MARK: Actions
    
    @IBAction func onLogOutAction() {
        LocalUserManager.sharedInstance.logout()
        delegate?.profileViewControllerDidLogOutUser()
    }
    
    func onEditProfileAction() {
        
    }
    
    // MARK: Public methods
    
    override func setup() {
        super.setup()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        tabBarItem = ProfileViewController.tabBarItem()
        
        updateUI()
    }
    
    override func updateUI() {
        super.updateUI()
        
    }
    
    static func instantiateFromStoryboard() -> ProfileViewController {
        let storyboard = UIStoryboard(name: ProfileViewController.StoryboardName, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: ProfileViewController.Identifier) as! ProfileViewController
    }
    
    static func tabBarItem() -> UITabBarItem {
        return UITabBarItem(title: Strings.TabBar.myProfile.rawValue, image: nil, selectedImage: nil)
    }
    
    // MARK: Private methods
    
}
