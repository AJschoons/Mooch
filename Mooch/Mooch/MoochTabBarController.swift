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
    
    
    static func instantiate() -> MoochTabBarController {
        let mtbc = MoochTabBarController()
        
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
        let profileViewControllerNav = UINavigationController(rootViewController: profileViewController)
        
        //Set the view controllers
        mtbc.viewControllers = [listingsNav, searchViewControllerNav, dummySellViewController, profileViewControllerNav]
        
        //Starts at first tab
        mtbc.selectedIndex = 0
        
        
        
        //
        //We have to temporarily set these because this tab bar controller is created when it is out of the view hierarchy
        //The tab bar items get replaced the first time they are selected, but until then this makes them still appear
        //
        
        let listingsTabBarItem = ListingsViewController.tabBarItem()
        mtbc.tabBar.items![0].title = listingsTabBarItem.title
        mtbc.tabBar.items![0].image = listingsTabBarItem.image
        mtbc.tabBar.items![0].selectedImage = listingsTabBarItem.selectedImage
        
        let searchTabBarItem = SearchViewController.tabBarItem()
        mtbc.tabBar.items![1].title = searchTabBarItem.title
        mtbc.tabBar.items![1].image = searchTabBarItem.image
        mtbc.tabBar.items![1].selectedImage = searchTabBarItem.selectedImage
        
        let dummySellTabBarItem = DummySellViewController.tabBarItem()
        mtbc.tabBar.items![2].title = dummySellTabBarItem.title
        mtbc.tabBar.items![2].image = dummySellTabBarItem.image
        mtbc.tabBar.items![2].selectedImage = dummySellTabBarItem.selectedImage
        
        let profileTabBarItem = ProfileViewController.tabBarItem()
        mtbc.tabBar.items![3].title = profileTabBarItem.title
        mtbc.tabBar.items![3].image = profileTabBarItem.image
        mtbc.tabBar.items![3].selectedImage = profileTabBarItem.selectedImage
        
        return mtbc
    }
}
