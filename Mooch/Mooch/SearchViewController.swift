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
    var tap: UITapGestureRecognizer?
    var keyboardShow : Bool = false {
        didSet {
            tap?.isEnabled = keyboardShow
        }
    }
    let searchController = UISearchController(searchResultsController: nil)
    var tableView: UITableView = UITableView()
    weak var delegate: ListingCategoryPickerTableHandlerDelegate!
    var searchBar : UISearchBar? = nil
    var listings : [Listing]
        {
        get {
        return CommunityListingsManager.sharedInstance.listingsVisibleToCurrentUserInCurrentCommunity
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
    lazy var listingsViewController: ListingsViewController = {
        let vc = ListingsViewController.instantiateFromStoryboard()
        vc.mode = .nestedInSearch
        self.addViewControllerAsChildViewController(vc)
        return vc
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidHide), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        
        self.hideKeyboardWhenTappedAround()

        
        let nibName = UINib(nibName: "SearchViewFilterCell", bundle:nil)
        definesPresentationContext = true
        searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 64))
        searchBar!.placeholder = "What are you hungry for?"
        searchBar!.delegate = self

        self.navigationItem.titleView = searchBar
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorColor = UIColor.black;

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        tableView.frame = view.frame
        tableView.register(nibName, forCellReuseIdentifier: CellReuseIdentifier)
        self.view.addSubview(self.tableView)
        listingsViewController.view.isHidden = true
    }
    func keyboardDidShow(_ notif: Notification) {
        keyboardShow = true
    }
    
    func keyboardDidHide(_ notif: Notification) {
        keyboardShow = false
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchBar?.resignFirstResponder()
   }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: .UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide), name: .UIKeyboardDidHide, object: nil)
        
        hideKeyboardWhenTappedAround()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardDidShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardDidHide, object: nil)
        
        if let tap = tap { view.removeGestureRecognizer(tap) }
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
        //vc.isFromSearchBar = !isFromCell
        vc.mode = .nestedInSearch
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
    
    fileprivate func addViewControllerAsChildViewController(_ viewController: UIViewController) {
        // Add Child View Controller
        self.addChildViewController(viewController)
        
        // Add Child View as Subview
        view.addSubview(viewController.view)
        
        // Configure Child View
        viewController.view.backgroundColor = UIColor.red
        viewController.view.frame = CGRect(x: 0, y: 64, width: self.view.frame.width, height: self.view.frame.height - 64 - 40)
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Notify Child View Controller
        viewController.didMove(toParentViewController: self)
    }
    
    fileprivate func removeViewControllerAsChildViewController(_ viewController: UIViewController) {
        // Notify Child View Controller
        viewController.willMove(toParentViewController: nil)
        
        // Remove Child View From Superview
        viewController.view.removeFromSuperview()
        
        // Notify Child View Controller
        viewController.removeFromParentViewController()
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
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }


    
}

 extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !keyboardShow else { return }
        var sortList : [Listing] = []
        var filter = ListingFilter()
        filter.category = ListingCategorys[indexPath.row]
        sortList = ListingProcessingHandler.sortByCategory(listings: listings,with: filter)
        self.pushListingsViewController(with:sortList)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
     func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()

        view.backgroundColor = ThemeColors.moochRed.color()
        //view.backgroundColor = UIColor.orange
        let label = UILabel()
        label.text = "All Category"
        label.frame = CGRect(x: 14, y: 5,width: 157, height:17)
        label.textAlignment = .left
        view.addSubview(label)
        
        let screenSize: CGRect = UIScreen.main.bounds
        let lineY = view.frame.origin.y
        let screenWidth = screenSize.width
        let rect = CGRect(x: 0, y:lineY , width: screenWidth, height: 1) // CGFloat, Double, Int
        let lineView = UIView(frame: rect)
        lineView.layer.borderWidth = 1.0
        lineView.layer.borderColor = UIColor.black.cgColor
        view.addSubview(lineView)
        return view
        
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.resignFirstResponder()
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText != "" {
            
            let searchListings = ListingProcessingHandler.search(listings: listings, for: searchText)
            listingsViewController.listings = listings
            listingsViewController.searchListings = searchListings
            listingsViewController.isSearching = true
            listingsViewController.view.isHidden = false
            
        } else {
            searchBar.perform(#selector(self.resignFirstResponder), with: nil, afterDelay: 0.1)
            listingsViewController.view.isHidden = true
        }
    }
}

extension SearchViewController {
    func hideKeyboardWhenTappedAround() {
            tap = UITapGestureRecognizer(target: self, action: #selector(SearchViewController.dismissKeyboard))
            tap?.isEnabled = false
            view.addGestureRecognizer(tap!)
        
    }
    
    func dismissKeyboard() {
        if (keyboardShow){
            searchBar?.resignFirstResponder()
            tap?.isEnabled = false
        }
    }
}







