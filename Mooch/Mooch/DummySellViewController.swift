//
//  DummySellViewController.swift
//  Mooch
//
//  Created by adam on 10/13/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

//A view controller used to get the "Sell" tab to appear; doesn't actually do anything because we intercept that tab selection
class DummySellViewController: MoochViewController {
    
    // MARK: Public variables
    
    // MARK: Private variables
    
    // MARK: Actions
    
    // MARK: Public methods
    
    override func setup() {
        super.setup()
        
        tabBarItem = DummySellViewController.tabBarItem()
    }
    
    static func tabBarItem() -> UITabBarItem {
        return UITabBarItem(title: Strings.TabBar.sell.rawValue, image: #imageLiteral(resourceName: "tabBarSellUnselected"), selectedImage: #imageLiteral(resourceName: "tabBarSellSelected"))
    }
    
    // MARK: Private methods
}
