//
//  SearchViewController.swift
//  Mooch
//
//  Created by adam on 10/13/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

class SearchViewController: MoochViewController {
    
    // MARK: Public variables
    
    
    // MARK: Private variables
    
    static fileprivate let StoryboardName = "Search"
    static fileprivate let Identifier = "SearchViewController"

    
    // MARK: Actions
    
    // MARK: Public methods
    
    override func setup() {
        super.setup()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        tabBarItem = SearchViewController.tabBarItem()
        
        updateUI()
    }
    
    override func updateUI() {
        super.updateUI()
        
    }
    
    static func instantiateFromStoryboard() -> SearchViewController {
        let storyboard = UIStoryboard(name: SearchViewController.StoryboardName, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: SearchViewController.Identifier) as! SearchViewController
    }
    
    static func tabBarItem() -> UITabBarItem {
        return UITabBarItem(title: Strings.TabBar.search.rawValue, image: nil, selectedImage: nil)
    }
    
    // MARK: Private methods

}
