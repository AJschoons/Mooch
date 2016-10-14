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
    
    fileprivate func presentLoginViewController() {
        let lvc = LoginViewController.instantiateFromStoryboard()
        lvc.delegate = self
        present(lvc, animated: true, completion: nil)
    }
    
    fileprivate func notifyTabViewControllers(ofLocalUserStateChange localUserState: LocalUserManager.LocalUserState) {
        guard let tabViewControllers = viewControllers else { return }
        
        for vc in tabViewControllers {
            if let vcToNotify = getViewControllerOrRootOfNavigationViewController(from: vc) as? LocalUserStateChangeListener {
                vcToNotify.localUserStateDidChange(to: localUserState)
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
}

extension MoochTabBarController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let viewControllerToSelect = getViewControllerOrRootOfNavigationViewController(from: viewController)
        
        if viewControllerToSelect is ProfileViewController {
            guard LocalUserManager.sharedInstance.state == .loggedIn else {
                selectedMyProfileTabWhenNotLoggedIn = true
                presentLoginViewController()
                return false
            }
            
            return true
        }
        
        return true
    }
}

extension MoochTabBarController: LoginViewControllerDelegate {
    
    func loginViewControllerDidLogin(localUser: LocalUser) {
        notifyTabViewControllers(ofLocalUserStateChange: .loggedIn)
        
        if selectedMyProfileTabWhenNotLoggedIn {
            selectedIndex = Tab.myProfile.index
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
    
    func profileViewControllerDidLogOutUser() {
        notifyTabViewControllers(ofLocalUserStateChange: .guest)
        selectedIndex = Tab.home.index
    }
}
