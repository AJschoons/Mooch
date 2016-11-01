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
    
    @IBAction func onPushListings() {
        pushListingsViewController(with: CommunityListingsManager.sharedInstance.listingsVisibleToCurrentUserInCurrentCommunity)
    }
    
    
    // MARK: Public methods
    
    override func setup() {
        super.setup()
        
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
        return UITabBarItem(title: Strings.TabBar.search.rawValue, image: #imageLiteral(resourceName: "tabBarSearchUnselected"), selectedImage: #imageLiteral(resourceName: "tabBarSearchSelected"))
    }
    
    // MARK: Private methods

    func pushListingsViewController(with listings: [Listing]) {
        guard let navC = navigationController else { return }
        
        let vc = ListingsViewController.instantiateFromStoryboard()
        vc.mode = .nestedInSearch
        vc.listings = listings
        
        navC.pushViewController(vc, animated: true)
    }
    
    //Completely resets the UI and state of the view controller
    fileprivate func resetForStateChange() {
        guard let navC = navigationController else { return }
        navC.popToRootViewController(animated: false)
        
        //TODO: clear out and reset any search state
    }
}

extension SearchViewController: LocalUserStateChangeListener {
    
    func localUserStateDidChange(to: LocalUserManager.LocalUserState) {
        resetForStateChange()
    }
}

extension SearchViewController: CommunityChangeListener {
    
    func communityDidChange() {
        resetForStateChange()
    }
}
