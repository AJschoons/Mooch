//
//  ListingDetailsViewController.swift
//  Mooch
//
//  Created by adam on 9/11/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

class ListingDetailsViewController: MoochViewController {
    
    // MARK: Public variables
    
    var listing: Listing!
    
    // MARK: Private variables
    
    static private let StoryboardName = "ListingDetails"
    static private let Identifier = "ListingDetailsViewController"
    
    // MARK: Actions
    
    // MARK: Public methods
    
    override func setup() {
        super.setup()
        
        setupNavigationBar()
        print(listing.title)
    }
    
    override func updateUI() {
        super.updateUI()
        
    }
    
    static func instantiateFromStoryboard() -> ListingDetailsViewController {
        let storyboard = UIStoryboard(name: ListingDetailsViewController.StoryboardName, bundle: nil)
        return storyboard.instantiateViewControllerWithIdentifier(ListingDetailsViewController.Identifier) as! ListingDetailsViewController
    }
    
    // MARK: Private methods
    
    private func setupNavigationBar() {
        guard let nav = navigationController else { return }
        
        title = "Listing Details"
    }
}
