//
//  ListingCategoryPickerViewController.swift
//  Mooch
//
//  Created by adam on 10/1/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

protocol ListingCategoryPickerViewControllerDelegate: class {
    func didPick(listingCategory: ListingCategory)
}

class ListingCategoryPickerViewController: MoochViewController {

    // MARK: Public variables
    
    @IBOutlet var tableHandler: ListingCategoryPickerTableHandler! {
        didSet {
            tableHandler.delegate = self
        }
    }
    
    weak var delegate: ListingCategoryPickerViewControllerDelegate!
    
    //The currently selected listing category will appear as selected
    var selectedListingCategory: ListingCategory?
    
    // MARK: Private variables
    
    static fileprivate let StoryboardName = "ListingCategoryPicker"
    static fileprivate let Identifier = "ListingCategoryPickerViewController"

    
    // MARK: Actions
    
    // MARK: Public methods
    
    static func instantiateFromStoryboard() -> ListingCategoryPickerViewController {
        let storyboard = UIStoryboard(name: ListingCategoryPickerViewController.StoryboardName, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: ListingCategoryPickerViewController.Identifier) as! ListingCategoryPickerViewController
    }
    
    override func setup() {
        super.setup()
        
        setupNavigationBar()
        
        updateUI()
    }
    
    override func updateUI() {
        super.updateUI()
        
    }
    
    // MARK: Private methods
    
    fileprivate func setupNavigationBar() {
        title = Strings.ListingCategoryPicker.title.rawValue
    }
}

extension ListingCategoryPickerViewController: ListingCategoryPickerTableHandlerDelegate {
    
    func getListingCategories() -> [ListingCategory] {
        return ListingCategoryManager.sharedInstance.listingCategories
    }
    
    func getSelectedListingCategory() -> ListingCategory? {
        return selectedListingCategory
    }
    
    func didSelect(_ listingCategory: ListingCategory) {
        delegate.didPick(listingCategory: listingCategory)
    }
}
