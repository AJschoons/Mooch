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
    fileprivate let CellReuseIdentifier = "searchFilterCell"
    let searchController = UISearchController(searchResultsController: nil)
    var tableView: UITableView = UITableView()
    weak var delegate: ListingCategoryPickerTableHandlerDelegate!
    var listings : [Listing]
        {
        get {
        return CommunityListingsManager.sharedInstance.listingsInCurrentCommunity
        }
    }
    var ListingCategorys : [ListingCategory]
        {
        get {
            return  ListingCategoryManager.sharedInstance.listingCategories
        }
    }
    // MARK: Private variables let me check i want to see shareinstance do you have any data in listing caterog?
    static fileprivate let StoryboardName = "Search"
    static fileprivate let Identifier = "SearchViewController"

    override func viewDidLoad() {
        super.viewDidLoad()
        let nibName = UINib(nibName: "SearchViewFilterCell", bundle:nil)
        definesPresentationContext = true
        let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 64))
        searchBar.delegate = self
        self.navigationItem.titleView = searchBar
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        tableView.frame = view.frame
        tableView.register(nibName, forCellReuseIdentifier: CellReuseIdentifier)
        self.view.addSubview(self.tableView)
    }
    
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
        return UITabBarItem(title: "", image: #imageLiteral(resourceName: "tabBarSearchUnselected"), selectedImage: #imageLiteral(resourceName: "tabBarSearchSelected"))
    }
    
    // MARK: Private methods

    func pushListingsViewController(with listings: [Listing], isFromCell : Bool = true) {
        guard let navC = navigationController else { return }
        let vc = ListingsViewController.instantiateFromStoryboard()
        vc.mode = isFromCell ? .nestedInSearch : .generalInSearch
        vc.listings = listings
        navC.pushViewController(vc, animated: isFromCell)
    }
    
    func pushListingsCategoryPicker(){
        guard let navC = navigationController else { return }
        let vc = ListingCategoryPickerViewController.instantiateFromStoryboard()
        navC.pushViewController(vc, animated: true)
    }
    
    
    //Completely resets the UI and state of the view controller
    fileprivate func resetForStateChange() {
        guard let navC = navigationController else { return }
        navC.popToRootViewController(animated: false)
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

extension SearchViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let listingCategory = ListingCategorys[indexPath.row]
        //let cell = tableView.dequeueReusableCell(withIdentifier: CellReuseIdentifier, for: indexPath) as! SearchViewFilterCell
        
        var cell = tableView.dequeueReusableCell(withIdentifier: CellReuseIdentifier, for: indexPath) as! SearchViewFilterCell
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.value2, reuseIdentifier: CellReuseIdentifier) as! SearchViewFilterCell
        }
        cell.myLabel.text = listingCategory.name
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ListingCategorys.count
    }
}

 extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var sortList : [Listing] = []
        var filter = ListingFilter()
        filter.category = ListingCategorys[indexPath.row]
        sortList = ListingProcessingHandler.sortByCategory(listings: listings,with: filter)
        self.pushListingsViewController(with:sortList)
    }

}

extension SearchViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.resignFirstResponder()
        self.pushListingsViewController(with:listings, isFromCell: false)
        
        return false
    }
}
