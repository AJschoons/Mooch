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
    
    fileprivate var selectedControl: BottomBarDoubleSegmentedControl.Control = .first
    
    //This variable is needed so we can pass the profile image to the EditProfileVC for editing
    fileprivate var profileImage: UIImage?
    
    
    // MARK: Actions
    
    func onSettingsAction() {
        presentSettingsActionSheet()
    }
    
    
    // MARK: Public methods
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        collectionHandler.reloadData()
    }
    
    func updateWith(user: User?) {
        resetFor(newUser: user)
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
        
        collectionHandler.reloadData()
    }
    
    static func instantiateFromStoryboard() -> ProfileViewController {
        let storyboard = UIStoryboard(name: ProfileViewController.StoryboardName, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: ProfileViewController.Identifier) as! ProfileViewController
    }
    
    static func tabBarItem() -> UITabBarItem {
        return UITabBarItem(title: "", image: #imageLiteral(resourceName: "tabBarProfileUnselected"), selectedImage: #imageLiteral(resourceName: "tabBarProfileSelected"))
    }
    
    
    // MARK: Private methods
    
    fileprivate func setupNavigationBar() {
        settingsButton = UIBarButtonItem(image: UIImage(named: "settings"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(onSettingsAction))
        
        if configuration.mode == .localUser {
            //We need to set the navigation controller's title because we don't want the tab for this view controller to have a title
            navigationController?.navigationBar.topItem?.title = configuration.title
        } else {
            //Otherwise we can just normally set the title
            title = configuration.title
        }
        
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
        
        //Remove the text from the nav bar back button so that is doesn't show in view controllers pushed from this view controller
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
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
    
    fileprivate func presentSettingsActionSheet() {
        guard let user = user else { return }

        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let editProfileAction = UIAlertAction(title: "Edit Profile", style: .default) { _ in
            self.presentEditProfileViewController(for: user, with: self.profileImage)
        }
        let changeCommunityAction = UIAlertAction(title: "Change Community", style: .default) { _ in
            self.presentCommunityPicker()
        }
        let logoutAction = UIAlertAction(title: "Log Out", style: .destructive) { _ in
            self.logout()
        }
        let cancelAction = UIAlertAction(title: Strings.TabBar.loggedOutMyProfileTabActionSheetActionTitleCancel.rawValue, style: .cancel, handler: nil)
        
        actionSheet.addAction(editProfileAction)
        actionSheet.addAction(changeCommunityAction)
        actionSheet.addAction(logoutAction)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    fileprivate func logout() {
        LocalUserManager.sharedInstance.logout()
        delegate?.profileViewControllerDidLogOutUser(self)
    }
    
    fileprivate func presentCommunityPicker() {
        let vc = CommunityPickerViewController.instantiateFromStoryboard()
        vc.configuration = CommunityPickerViewController.Configuration(pickingMode: .optional, shouldUploadToAPIForLocalUser: true)
        vc.delegate = self
        let navC = UINavigationController(rootViewController: vc)
        present(navC, animated: true, completion: nil)
    }
    
    private func presentEditProfileViewController(for user: User, with photo: UIImage?) {
        let vc = EditProfileViewController.instantiateFromStoryboard()
        vc.configuration = EditProfileConfiguration.defaultConfiguration(for: .editing)
        vc.delegate = self
        vc.set(user: user, with: profileImage)
        
        let navC = UINavigationController(rootViewController: vc)
        present(navC, animated: true, completion: nil)
    }
    
    fileprivate func pushListingDetailsViewController(with listing: Listing, in mode: ListingDetailsConfiguration.Mode, isViewingSellerProfileNotAllowed: Bool) {
        let vc = ListingDetailsViewController.instantiateFromStoryboard()
        vc.configuration = ListingDetailsConfiguration.defaultConfiguration(for: mode, with: listing, isViewingSellerProfileNotAllowed: isViewingSellerProfileNotAllowed)
        navigationController!.pushViewController(vc, animated: true)
    }
    
    fileprivate func resetFor(newUser: User?) {
        user = newUser
        
        selectedControl = .first
        profileImage = nil
        collectionHandler.resetScrollPosition()
        updateUI()
    }
    
    fileprivate func resetFor(editedUser: User, profileImage: UIImage?) {
        user = editedUser
        
        self.profileImage = profileImage
        updateUI()
    }
    
    //Completely resets the UI and state of the view controller
    fileprivate func resetForStateChange() {
        guard configuration.mode == .localUser else { return }
        guard let navC = navigationController else { return }
        navC.popToRootViewController(animated: false)
        collectionHandler.resetScrollPosition()
    }
}

extension ProfileViewController: ProfileCollectionHandlerDelegate {
    
    func getUser() -> User? {
        return user
    }
    
    func getListings() -> [Listing] {
        switch configuration.mode {
            
        case .localUser:
            switch selectedControl {
            case .first:
                //My Listings
                return CommunityListingsManager.sharedInstance.listingsOwnedByCurrentUser
            case .second:
                //Contact History
                return CommunityListingsManager.sharedInstance.listingsCurrentUserHasContacted
            }
            
        case .seller:
            guard let user = user else {
                return [Listing]()
            }
            return CommunityListingsManager.sharedInstance.allListingsOwned(by: user)
        }
    }
    
    func getConfiguration() -> Configuration {
        return configuration
    }
    
    func getSelectedControl() -> BottomBarDoubleSegmentedControl.Control {
        return selectedControl
    }
    
    func getProfileImage() -> UIImage? {
        return profileImage
    }
    
    func didGet(profileImage: UIImage) {
        self.profileImage = profileImage
    }
    
    func didSelect(_ listing: Listing) {
        let isListingCompleted = listing.isCompleted()
        
        switch configuration.mode {
        case .localUser:
            switch selectedControl {
            case .first:
                //My Listings
                let mode: ListingDetailsConfiguration.Mode = isListingCompleted ? .viewingThisUsersCompletedListing : .viewingThisUsersListing
                pushListingDetailsViewController(with: listing, in: mode, isViewingSellerProfileNotAllowed: false)
                
            case .second:
                //Contact History
                let mode: ListingDetailsConfiguration.Mode = isListingCompleted ? .viewingOtherUsersCompletedListing : .viewingOtherUsersListing
                pushListingDetailsViewController(with: listing, in: mode, isViewingSellerProfileNotAllowed: false)
            }
            
        case .seller:
            let mode: ListingDetailsConfiguration.Mode = isListingCompleted ? .viewingOtherUsersCompletedListing : .viewingOtherUsersListing
            pushListingDetailsViewController(with: listing, in: mode, isViewingSellerProfileNotAllowed: true)
        }
    }
    
    func getInsetForTabBar() -> CGFloat {
        return (tabBarController != nil) ? tabBarController!.tabBar.frame.height : CGFloat(0.0)
    }
}

extension ProfileViewController: BottomBarDoubleSegmentedControlDelegate {
    //Part of ProfileCollectionHandlerDelegate
    
    func didSelect(_ selectedControl: BottomBarDoubleSegmentedControl.Control) {
        self.selectedControl = selectedControl
        updateUI()
    }
}

extension ProfileViewController: EditProfileViewControllerDelegate {
    
    func editProfileViewControllerDidFinishEditing(localUser: LocalUser, withProfileImage profileImage: UIImage?, isNewProfile: Bool) {
        guard !isNewProfile else { return }
        
        if let pictureURL = localUser.user.pictureURL {
            ImageManager.sharedInstance.removeFromCache(imageURLString: pictureURL)
        }
        
        if let thumbnailPictureURL = localUser.user.thumbnailPictureURL {
            ImageManager.sharedInstance.removeFromCache(imageURLString: thumbnailPictureURL)
        }
        
        LocalUserManager.sharedInstance.updateLocalUserWithInformation(from: localUser.user)
        
        resetFor(editedUser: localUser.user, profileImage: profileImage)
        
        dismiss(animated: true, completion: nil)
    }
}

extension ProfileViewController: CommunityPickerViewControllerDelegate {
    
    func communityPickerViewController(_ : CommunityPickerViewController, didPick community: Community) {
        guard let localUser = LocalUserManager.sharedInstance.localUser else { return }
        
        var updatedUser = localUser.user
        updatedUser.changeCommunityId(to: community.id)
        
        LocalUserManager.sharedInstance.updateLocalUserWithInformation(from: updatedUser)
        
        resetFor(newUser: updatedUser)
        
        delegate?.profileViewControllerDidChangeCommunity(self)
        
        dismiss(animated: true, completion: nil)
    }
    
    func communityPickerViewControllerDidCancel(_ : CommunityPickerViewController) {
        dismiss(animated: true, completion: nil)
    }
}

extension ProfileViewController: LocalUserStateChangeListener {
    
    func localUserStateDidChange(to: LocalUserManager.LocalUserState) {
        resetForStateChange()
    }
}

extension ProfileViewController: CommunityChangeListener {
    
    func communityDidChange() {
        resetForStateChange()
    }
}

