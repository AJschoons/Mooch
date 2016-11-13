//
//  MoochTabBarController.swift
//  Mooch
//
//  Created by adam on 10/13/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

//The main tab bar for the app
class MoochTabBarController: UITabBarController {
    
    fileprivate enum Tab: Int {
        case home = 0
        case search = 1
        case sell = 2
        case myProfile = 3
        
        var index: Int {
            return rawValue
        }
    }
    
    //These allow the appropriate action to be taken once logged in
    fileprivate var selectedMyProfileTabWhenNotLoggedIn = false
    fileprivate var selectedSellTabWhenNotLoggedIn = false
    
    fileprivate var hasLoadedListingsAfterLaunch = false
    fileprivate var pushReceivedWhenAppClosed: PushNotificationsManager.ListingPush?
    
    fileprivate var cameraViewControllerBeingShown: CameraViewController?
    
    fileprivate var selectedTabBottomBar: UIView!
    
    static func instantiate() -> MoochTabBarController {
        let mtbc = MoochTabBarController()
        mtbc.delegate = mtbc
        
        //First tab
        let listingsViewController = ListingsViewController.instantiateFromStoryboard()
        let listingsNav = UINavigationController(rootViewController: listingsViewController)
        
        //Second tab
        let searchViewController = SearchViewController.instantiateFromStoryboard()
        let searchViewControllerNav = UINavigationController(rootViewController: searchViewController)
        
        //Third tab
        //Used to get the "Sell" tab to appear; doesn't actually do anything because we intercept that tab selection
        let dummySellViewController = DummySellViewController()
        
        //Fourth tab
        let profileViewController = ProfileViewController.instantiateFromStoryboard()
        profileViewController.configuration = ProfileConfiguration.defaultConfiguration(for: .localUser)
        profileViewController.delegate = mtbc
        let profileViewControllerNav = UINavigationController(rootViewController: profileViewController)
        
        //Set the view controllers
        mtbc.viewControllers = [listingsNav, searchViewControllerNav, dummySellViewController, profileViewControllerNav]
        
        //Starts at first tab
        mtbc.selectedIndex = Tab.home.index
        
        
        
        //
        //We have to temporarily set these because this tab bar controller is created when it is out of the view hierarchy
        //The tab bar items get replaced the first time they are selected, but until then this makes them still appear
        //
        
        let listingsTabBarItem = ListingsViewController.tabBarItem()
        mtbc.tabBar.items![Tab.home.index].title = listingsTabBarItem.title
        mtbc.tabBar.items![Tab.home.index].image = listingsTabBarItem.image
        mtbc.tabBar.items![Tab.home.index].selectedImage = listingsTabBarItem.selectedImage
        
        let searchTabBarItem = SearchViewController.tabBarItem()
        mtbc.tabBar.items![Tab.search.index].title = searchTabBarItem.title
        mtbc.tabBar.items![Tab.search.index].image = searchTabBarItem.image
        mtbc.tabBar.items![Tab.search.index].selectedImage = searchTabBarItem.selectedImage
        
        let dummySellTabBarItem = DummySellViewController.tabBarItem()
        mtbc.tabBar.items![Tab.sell.index].title = dummySellTabBarItem.title
        mtbc.tabBar.items![Tab.sell.index].image = dummySellTabBarItem.image
        mtbc.tabBar.items![Tab.sell.index].selectedImage = dummySellTabBarItem.selectedImage
        
        let profileTabBarItem = ProfileViewController.tabBarItem()
        mtbc.tabBar.items![Tab.myProfile.index].title = profileTabBarItem.title
        mtbc.tabBar.items![Tab.myProfile.index].image = profileTabBarItem.image
        mtbc.tabBar.items![Tab.myProfile.index].selectedImage = profileTabBarItem.selectedImage
        
        return mtbc
    }
    
    override func viewDidLoad() {
        addSelectedTabBottomBar()
    }
    
    override func viewDidLayoutSubviews() {
        updateSelectedTabBottomBarPosition(animated: false)
    }
    
    private func addSelectedTabBottomBar() {
        selectedTabBottomBar = UIView()
        selectedTabBottomBar.backgroundColor = ThemeColors.moochRed.color()
        tabBar.addSubview(selectedTabBottomBar)
    }
    
    //This function must be used to programatically change the selectedIndex so that the bottom bar state is correct
    func setSelected(index: Int) {
        selectedIndex = index
        updateSelectedTabBottomBarPosition(animated: false)
    }
    
    fileprivate func updateSelectedTabBottomBarPosition(animated: Bool) {
        guard animated else {
            selectedTabBottomBar.frame = rectForSelectedTabBottomBar()
            return
        }
        
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.7,
            options: .curveEaseOut,
            animations: {
                self.selectedTabBottomBar.frame = self.rectForSelectedTabBottomBar()
            },
            completion: nil
        )
    }
    
    private func rectForSelectedTabBottomBar() -> CGRect {
        let selectedTabFrame = frameForTab(in: tabBar, withIndex: selectedIndex)
        let tabBarHeight = tabBar.bounds.height
        
        let bottomBarWidth: CGFloat = 60
        let bottomBarHeight: CGFloat = 5
        let bottomBarY = tabBarHeight - bottomBarHeight
        let bottomBarX = (selectedTabFrame.origin.x + selectedTabFrame.width / 2) - (bottomBarWidth / 2)
        
        return CGRect(x: bottomBarX, y: bottomBarY, width: bottomBarWidth, height: bottomBarHeight)
    }
    
    fileprivate func presentLoginViewController() {
        let lvc = LoginViewController.instantiateFromStoryboard()
        lvc.delegate = self
        present(lvc, animated: true, completion: nil)
    }
    
    fileprivate func presentCameraViewController() {
        let cameraViewController = CameraViewController()
        cameraViewController.delegate = self
        cameraViewControllerBeingShown = cameraViewController
        present(cameraViewController, animated: true, completion: nil)
    }
    
    fileprivate func presentEditListingViewController(with photo: UIImage) {
        guard let cameraViewController = cameraViewControllerBeingShown else { return }
        
        let vc = EditListingViewController.instantiateFromStoryboard()
        vc.configuration = EditListingConfiguration.defaultConfiguration(for: .creating)
        vc.setPhoto(photo: photo)
        vc.delegate = self
        
        let transtion = CATransition()
        transtion.duration = 0.3
        transtion.type = kCATransitionFade
        cameraViewController.view.layer.add(transtion, forKey: kCATransition)
        cameraViewController.setNavigationBarHidden(false, animated: false)
        cameraViewController.pushViewController(vc, animated: false)
    }

    
    fileprivate func notifyTabViewControllers(ofLocalUserStateChange localUserState: LocalUserManager.LocalUserState) {
        guard let tabViewControllers = viewControllers else { return }
        
        for vc in tabViewControllers {
            if let vcToNotify = getViewControllerOrRootOfNavigationViewController(from: vc) as? LocalUserStateChangeListener {
                vcToNotify.localUserStateDidChange(to: localUserState)
            }
        }
    }
    
    fileprivate func notifyTabViewControllersOfCommunityChange() {
        guard let tabViewControllers = viewControllers else { return }
        
        for vc in tabViewControllers {
            if let vcToNotify = getViewControllerOrRootOfNavigationViewController(from: vc) as? CommunityChangeListener {
                vcToNotify.communityDidChange()
            }
        }
    }
    
    //Returns the view controller passed, or the root view controller if that view controller is a navigation controller
    fileprivate func getViewControllerOrRootOfNavigationViewController(from viewController: UIViewController) -> UIViewController {
        guard let navC = viewController as? UINavigationController else {
            return viewController
        }
        return navC.viewControllers[0]
    }
    
    //Action sheet for when the user presses the "My Profile" tab, but is logged out
    fileprivate func presentLoggedOutMyProfileButtonActionSheet() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let loginOrSignUpAction = UIAlertAction(title: Strings.TabBar.loggedOutMyProfileTabActionSheetActionTitleLoginOrSignUp.rawValue, style: .default) { _ in
            self.selectedMyProfileTabWhenNotLoggedIn = true
            self.presentLoginViewController()
        }
        let changeCommunityAction = UIAlertAction(title: Strings.TabBar.loggedOutMyProfileTabActionSheetActionTitleChangeCommunity.rawValue, style: .default) { _ in
            self.presentCommunityPicker()
        }
        let cancelAction = UIAlertAction(title: Strings.TabBar.loggedOutMyProfileTabActionSheetActionTitleCancel.rawValue, style: .cancel, handler: nil)
        
        actionSheet.addAction(loginOrSignUpAction)
        actionSheet.addAction(changeCommunityAction)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    fileprivate func presentCommunityPicker() {
        let vc = CommunityPickerViewController.instantiateFromStoryboard()
        vc.configuration = CommunityPickerViewController.Configuration(pickingMode: .optional, shouldUploadToAPIForLocalUser: false)
        vc.delegate = self
        let navC = UINavigationController(rootViewController: vc)
        present(navC, animated: true, completion: nil)
    }
    
    fileprivate func presentListingDetailsViewController(with listing: Listing, in mode: ListingDetailsConfiguration.Mode, isViewingSellerProfileNotAllowed: Bool) {
        let vc = ListingDetailsViewController.instantiateFromStoryboard()
        
        //Since we're presenting the view controller, we have to add a cancel button
        var configuration = ListingDetailsConfiguration.defaultConfiguration(for: mode, with: listing, isViewingSellerProfileNotAllowed: isViewingSellerProfileNotAllowed)
        configuration.leftBarButtons = [.cancel]
        vc.configuration = configuration
        
        let navC = UINavigationController(rootViewController: vc)
        present(navC, animated: true, completion: nil)
    }
    
    fileprivate func handle(listingPush: PushNotificationsManager.ListingPush, wasAppClosed: Bool) {
        
        MoochAPI.GETListing(withId: listingPush.listingId) { [weak self] listing, error in
            guard let pushedListing = listing else { return }
            
            CommunityListingsManager.sharedInstance.updateOrAdd(pushedListing: pushedListing)
            
            switch listingPush.exchangeType {
            case .buyerRequested:
                self?.handleBuyerRequestedListingPush(for: pushedListing, wasAppClosed: wasAppClosed)
                
            case .sellerApproved:
                self?.handleSellerApprovedListingPush(for: pushedListing, wasAppClosed: wasAppClosed)
            }
        }
    }
    
    fileprivate func handleBuyerRequestedListingPush(for listing: Listing, wasAppClosed: Bool) {
        if wasAppClosed {
            presentListingDetailsViewController(with: listing, in: .viewingThisUsersListing, isViewingSellerProfileNotAllowed: false)
        } else {
            presentCancellableViewPushAlert(title: "Buyer Requested Exchange", message: "A buyer has requested to contact you about one of your listings") { action in
                self.presentListingDetailsViewController(with: listing, in: .viewingThisUsersListing, isViewingSellerProfileNotAllowed: false)
            }
        }
    }
    
    fileprivate func handleSellerApprovedListingPush(for listing: Listing, wasAppClosed: Bool) {
        if wasAppClosed {
            presentListingDetailsViewController(with: listing, in: .viewingOtherUsersCompletedListing, isViewingSellerProfileNotAllowed: false)
        } else {
            presentCancellableViewPushAlert(title: "Seller Approved Exchange", message: "A seller has accepted your request to complete an exchange with their listing") { action in
                self.presentListingDetailsViewController(with: listing, in: .viewingOtherUsersCompletedListing, isViewingSellerProfileNotAllowed: false)
            }
        }
    }
    
    fileprivate func presentCancellableViewPushAlert(title: String, message: String, handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "View Now", style: .default, handler: handler)
        let cancel = UIAlertAction(title: "View Later", style: .cancel, handler: nil)
        alert.addAction(cancel)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

extension MoochTabBarController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let viewControllerToSelect = getViewControllerOrRootOfNavigationViewController(from: viewController)
        
        if viewControllerToSelect is ProfileViewController {
            guard LocalUserManager.sharedInstance.state == .loggedIn, let localUser = LocalUserManager.sharedInstance.localUser else {
                presentLoggedOutMyProfileButtonActionSheet()
                return false
            }
            
            if let profileViewController = viewControllerToSelect as? ProfileViewController {
                if profileViewController.user == nil {
                    profileViewController.updateWith(user: localUser.user)
                }
            }
            
            return true
        } else if viewControllerToSelect is DummySellViewController {
            guard LocalUserManager.sharedInstance.state == .loggedIn else {
                selectedSellTabWhenNotLoggedIn = true
                presentLoginViewController()
                return false
            }
            
            //Don't actually let the tab be selected; show the camera view controller
            presentCameraViewController()
            return false
        }
        
        return true
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        updateSelectedTabBottomBarPosition(animated: true)
    }
}

extension MoochTabBarController: LoginViewControllerDelegate {
    
    func loginViewControllerDidLogin(localUser: LocalUser) {
        notifyTabViewControllers(ofLocalUserStateChange: .loggedIn)
        
        if selectedMyProfileTabWhenNotLoggedIn {
            setSelected(index: Tab.home.index)
        }
        
        //Reset these now that the user logged in
        selectedMyProfileTabWhenNotLoggedIn = false
        selectedSellTabWhenNotLoggedIn = false
        
        dismiss(animated: true, completion: nil)
    }
    
    func loginViewControllerDidCancel() {
        //Reset these since the user didn't login
        selectedMyProfileTabWhenNotLoggedIn = false
        selectedSellTabWhenNotLoggedIn = false
        
        dismiss(animated: true, completion: nil)
    }
}

extension MoochTabBarController: ProfileViewControllerDelegate {
    
    func profileViewControllerDidLogOutUser(_ profileViewController: ProfileViewController) {
        notifyTabViewControllers(ofLocalUserStateChange: .guest)
        setSelected(index: Tab.home.index)
        
        profileViewController.updateWith(user: nil)
    }
    
    func profileViewControllerDidChangeCommunity(_ profileViewController: ProfileViewController) {
        notifyTabViewControllersOfCommunityChange()
        setSelected(index: Tab.home.index)
    }
}

extension MoochTabBarController: CommunityPickerViewControllerDelegate {
    
    func communityPickerViewController(_ : CommunityPickerViewController, didPick community: Community) {
        LocalUserManager.sharedInstance.updateGuest(communityId: community.id)
        notifyTabViewControllersOfCommunityChange()
        setSelected(index: Tab.home.index)
        dismiss(animated: true, completion: nil)
    }
    
    func communityPickerViewControllerDidCancel(_ : CommunityPickerViewController) {
        dismiss(animated: true, completion: nil)
    }
}

extension MoochTabBarController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let photo = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }
        
        presentEditListingViewController(with: photo)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        cameraViewControllerBeingShown = nil
        dismiss(animated: true, completion: nil)
    }
}

//Required by UIImagePickerController delegate property
extension MoochTabBarController: UINavigationControllerDelegate {
 
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewController is EditListingViewController {
            cameraViewControllerBeingShown?.setStatusBar(hidden: false)
        }
    }
}

extension MoochTabBarController: EditListingViewControllerDelegate {
    
    func editListingViewControllerDidFinishEditing(with listing: Listing, isNew: Bool) {
        if isNew {
            CommunityListingsManager.sharedInstance.add(listing)
        }
        
        cameraViewControllerBeingShown = nil
        dismiss(animated: true, completion: nil)
    }
    
    func editListingViewControllerDidCancel() {
        cameraViewControllerBeingShown = nil
        dismiss(animated: true, completion: nil)
    }
}

extension MoochTabBarController: PushNotificationsManagerNotificationsDelegate {
    
    func onDidReceive(listingPush: PushNotificationsManager.ListingPush, whenAppClosed wasAppClosed: Bool) {
        print("didReceive \(listingPush)... when app closed: \(wasAppClosed)")
        guard hasLoadedListingsAfterLaunch else {
            pushReceivedWhenAppClosed = listingPush
            return
        }
        
        handle(listingPush: listingPush, wasAppClosed: wasAppClosed)
    }
}

extension MoochTabBarController: CommunityListingsManagerDelegate {
    
    func communityListingsManagerDidReloadListings() {
        hasLoadedListingsAfterLaunch = true
        
        //Once the Listings have loaded for the first time, show the push.
        if let push = pushReceivedWhenAppClosed {
            pushReceivedWhenAppClosed = nil
            handle(listingPush: push, wasAppClosed: true)
        }
    }
}
