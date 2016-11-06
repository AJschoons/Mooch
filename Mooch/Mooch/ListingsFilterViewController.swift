//
//  ListingsFilterViewController.swift
//  Mooch
//
//  Created by adam on 10/19/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

protocol ListingsFilterViewControllerDelegate: class {
    func didClearFilters()
    func didApply(listingFilter: ListingFilter)
}

class ListingsFilterViewController: MoochViewController {
    
    enum CellType: String {
        case sortBy = "Sort By"
        case category = "Category"
        case postedWithin = "Posted Within"
        case price = "Price"
    }
    
    // MARK: Public variables
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHeightConstraint: NSLayoutConstraint!
    
    var showCategoryFilter = true
    var filterApplied: ListingFilter = ListingFilter()
    weak var delegate: ListingsFilterViewControllerDelegate!
    
    // MARK: Private variables
    
    static fileprivate let StoryboardName = "ListingsFilter"
    static fileprivate let Identifier = "ListingsFilterViewController"
    
    fileprivate let HeaderHeight: CGFloat = 32
    
    fileprivate let DisclosureCellIdentifier = "DisclosureCell"
    fileprivate let DisclosureCellHeight: CGFloat = 44
    
    fileprivate let PriceRangeCellHeight = ListingsPriceFilterTableViewCell.EstimatedHeight
    
    
    // MARK: Actions
    
    @IBAction func onClearAction(_ sender: AnyObject) {
        delegate.didClearFilters()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onDoneAction(_ sender: AnyObject) {
        delegate.didApply(listingFilter: filterApplied)
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: Public methods
    
    static func instantiateFromStoryboard() -> ListingsFilterViewController {
        let storyboard = UIStoryboard(name: ListingsFilterViewController.StoryboardName, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: ListingsFilterViewController.Identifier) as! ListingsFilterViewController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    override func setup() {
        super.setup()
        
        //Set the table height based on the number of cells that will be shown
        let numberOfDisclosureCells: CGFloat = showCategoryFilter ? 3 : 2
        let tableHeight = HeaderHeight + numberOfDisclosureCells * DisclosureCellHeight + PriceRangeCellHeight
        tableHeightConstraint.constant = tableHeight
        
        //Remove the text from the nav bar back button so that is doesn't show in view controllers pushed from this view controller
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        updateUI()
    }
    
    override func updateUI() {
        super.updateUI()
        
    }
    
    // MARK: Private methods
    
    fileprivate func cellType(for indexPath: IndexPath) -> CellType {
        switch indexPath.row {
        case 0:
            return .sortBy
        case 1:
            return showCategoryFilter ? .category : .postedWithin
        case 2:
            return showCategoryFilter ? .postedWithin : .price
        case 3:
            return .price
        default:
            //Just to have something here.....
            return .price
        }
    }
    
    fileprivate func pushListingCategoryPickerViewController() {
        guard let navC = navigationController else { return }
        
        let listingCategoryPickerViewController = ListingCategoryPickerViewController.instantiateFromStoryboard()
        listingCategoryPickerViewController.delegate = self
        listingCategoryPickerViewController.selectedListingCategory = filterApplied.category
        
        navC.pushViewController(listingCategoryPickerViewController, animated: true)
    }
    
    fileprivate func pushListingFilterOptionPickerViewController(withMode mode: ListingFilterOptionPickerViewController.OptionPickingMode) {
        guard let navC = navigationController else { return }
        
        let vc = ListingFilterOptionPickerViewController()
        vc.delegate = self
        vc.optionPickingMode = mode
        vc.currentlySelectedSortByOption = filterApplied.sortByOption
        vc.currentlySelectedPostedWithinOption = filterApplied.datePostedWithinOption
        
        navC.pushViewController(vc, animated: true)
    }
}

extension ListingsFilterViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return showCategoryFilter ? 4 : 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell
        
        let cellType = self.cellType(for: indexPath)
        switch cellType {
        case .sortBy, .category, .postedWithin:
            cell = tableView.dequeueReusableCell(withIdentifier: DisclosureCellIdentifier, for: indexPath)
            
            var disclosureCellText = ""
            
            if cellType == .sortBy {
                disclosureCellText = "\(CellType.sortBy.rawValue): \(filterApplied.sortByOption.rawValue)"
            } else if cellType == .category {
                disclosureCellText = filterApplied.category != nil ? "\(CellType.category.rawValue): \(filterApplied.category!.name)" : "\(CellType.category.rawValue)"
            } else if cellType == .postedWithin {
                disclosureCellText = filterApplied.datePostedWithinOption != nil ? "\(CellType.postedWithin.rawValue): \(filterApplied.datePostedWithinOption!.rawValue)" : "\(CellType.postedWithin.rawValue)"
            }
            
            cell.textLabel?.text = disclosureCellText
            
            
        case .price:
            cell = tableView.dequeueReusableCell(withIdentifier: ListingsPriceFilterTableViewCell.Identifier, for: indexPath)
            if let priceFilterCell = cell as? ListingsPriceFilterTableViewCell {
                priceFilterCell.setPriceRange(min: filterApplied.minimumPrice, max: filterApplied.maximumPrice)
                priceFilterCell.delegate = self
            }
        }
        
        return cell
    }
}

extension ListingsFilterViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch cellType(for: indexPath) {
        case .category:
            pushListingCategoryPickerViewController()
        case .sortBy:
            pushListingFilterOptionPickerViewController(withMode: .sortBy)
        case .postedWithin:
            pushListingFilterOptionPickerViewController(withMode: .postedWithin)
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellType(for: indexPath) == .price ? PriceRangeCellHeight : DisclosureCellHeight
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        //Don't allow the price cell to be selected
        return cellType(for: indexPath) == .price ? nil : indexPath
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        //Don't allow the price cell to be highlighted
        return cellType(for: indexPath) == .price ? false : true
    }
}

extension ListingsFilterViewController: ListingCategoryPickerViewControllerDelegate {
    
    func didPick(listingCategory: ListingCategory) {
        filterApplied.category = listingCategory
        tableView.reloadData()
        guard let navC = navigationController else { return }
        navC.popViewController(animated: true)
    }
}

extension ListingsFilterViewController: ListingFilterOptionPickerViewControllerDelegate {
    
    func didPick(sortByOption: ListingFilter.SortByOption) {
        filterApplied.sortByOption = sortByOption
        tableView.reloadData()
        guard let navC = navigationController else { return }
        navC.popViewController(animated: true)
    }
    
    func didPick(datePostedWithinOption: ListingFilter.DatePostedWithinOption) {
        filterApplied.datePostedWithinOption = datePostedWithinOption
        tableView.reloadData()
        guard let navC = navigationController else { return }
        navC.popViewController(animated: true)
    }
}

extension ListingsFilterViewController: ListingsPriceFilterTableViewCellDelegate {
    
    func priceRangeDidChange(min: Int, max: Int) {
        filterApplied.minimumPrice = min
        filterApplied.maximumPrice = max
    }
}
