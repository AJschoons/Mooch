//
//  ProfileViewController.swift
//  Mooch
//
//  Created by adam on 9/12/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

protocol ProfileViewControllerDelegate: class {
    func profileViewControllerDidLogOutUser(_ profileViewController: ProfileViewController)
    func profileViewControllerDidChangeCommunity(_ profileViewController: ProfileViewController)
}

class ProfileViewController: MoochViewController {
    
    
    typealias Configuration = ProfileConfiguration
    
    // MARK: Public variables
    
    
    @IBOutlet var collectionHandler: ProfileCollectionHandler! {
        didSet {
            collectionHandler.delegate = self
        }
    }
    
    //The user whose profile is being displayed
    private(set) var user: User?
    
    //The configuration used to setup the class
    var configuration: Configuration!
    
    weak var delegate: ProfileViewControllerDelegate?
    
    
    // MARK: Private variables
    
    static fileprivate let StoryboardName = "Profile"
    static fileprivate let Identifier = "ProfileViewController"
    
    fileprivate var settingsButton: UIBarButtonItem!
    
    // MARK: Actions
    
    @IBAction func onLogOutAction() {
        LocalUserManager.sharedInstance.logout()
        delegate?.profileViewControllerDidLogOutUser(self)
    }
    
    @IBAction func onChangeCommunityAction() {
        presentCommunityPicker()
    }
    
    func onSettingsAction() {
        
    }
    
    // MARK: Public methods
    
    func updateWith(user: User?) {
        self.user = user
    }
    
    override func setup() {
        super.setup()
        
        setupNavigationBar()
        
        if configuration.mode == .localUser {
            tabBarItem = ProfileViewController.tabBarItem()
        }
        
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
    
    fileprivate func setupNavigationBar() {
        settingsButton = UIBarButtonItem(image: UIImage(named: "settings"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(onSettingsAction))
        
        title = configuration.title
        
        if let leftButtons = configuration.leftBarButtons {
            navigationItem.leftBarButtonItems = barButtons(fromTypeList: leftButtons)
        } else {
            navigationItem.leftBarButtonItems = nil
        }
        
        if let rightButtons = configuration.rightBarButtons {
            navigationItem.rightBarButtonItems = barButtons(fromTypeList: rightButtons)
        } else {
            navigationItem.rightBarButtonItems = nil
        }
    }
    
    fileprivate func barButtons(fromTypeList typeList: [Configuration.BarButtonType]) -> [UIBarButtonItem] {
        return typeList.map({barButton(forType: $0)})
    }
    
    fileprivate func barButton(forType type: Configuration.BarButtonType) -> UIBarButtonItem {
        switch type {
        case .settings:
            return settingsButton
        }
    }
    
    fileprivate func presentCommunityPicker() {
        let vc = CommunityPickerViewController.instantiateFromStoryboard()
        vc.delegate = self
        let navC = UINavigationController(rootViewController: vc)
        present(navC, animated: true, completion: nil)
    }
}

extension ProfileViewController: ProfileCollectionHandlerDelegate {
    
    func getUser() -> User? {
        return user
    }
    
    func getListings() -> [Listing] {
        return CommunityListingsManager.sharedInstance.listingsInCurrentCommunity
    }
    
    func getConfiguration() -> Configuration {
        return configuration
    }
    
    func didSelect(_ listing: Listing) {
        print(listing)
    }
    
    func getInsetForTabBar() -> CGFloat {
        return (tabBarController != nil) ? tabBarController!.tabBar.frame.height : CGFloat(0.0)
    }
}

extension ProfileViewController: BottomBarDoubleSegmentedControlDelegate {
    //Part of ProfileCollectionHandlerDelegate
    
    func didSelect(_ selectedControl: BottomBarDoubleSegmentedControl.Control) {
        print(selectedControl)
    }
}

extension ProfileViewController: CommunityPickerViewControllerDelegate {
    
    func didPick(community: Community) {
        guard var localUser = LocalUserManager.sharedInstance.localUser?.user else { return }
        
        //Update the user's community id
        localUser.communityId = community.id
        LocalUserManager.sharedInstance.updateLocalUserWithInformation(from: localUser)
        
        delegate?.profileViewControllerDidChangeCommunity(self)
        dismiss(animated: true, completion: nil)
    }
}
