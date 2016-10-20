//
//  ListingFilterOptionPickerViewController.swift
//  Mooch
//
//  Created by adam on 10/20/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

protocol ListingFilterOptionPickerViewControllerDelegate: class {
    func didPick(sortByOption: ListingFilter.SortByOption)
    func didPick(datePostedWithinOption: ListingFilter.DatePostedWithinOption)
}

class ListingFilterOptionPickerViewController: MoochViewController {
    
    enum OptionPickingMode {
        case sortBy
        case postedWithin
    }
    
    // MARK: Public variables
    
    var optionPickingMode: OptionPickingMode!
    weak var delegate: ListingFilterOptionPickerViewControllerDelegate!
    
    
    // MARK: Private variables
    
    let CellIdentifier = "Cell"
    
    
    // MARK: Actions
    
    // MARK: Public methods
    
    override func setup() {
        super.setup()
        
        let tableView = UITableView(frame: view.bounds)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CellIdentifier)
        view.addSubview(tableView)
        
        var title: String
        switch optionPickingMode! {
        case .sortBy:
            title = "Sort By"
        case .postedWithin:
            title = "Posted Within"
        }
        self.title = title
    }
    
    
    // MARK: Private methods
    
}

extension ListingFilterOptionPickerViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch optionPickingMode! {
        case .sortBy:
            return ListingFilter.SortByOption.numberOfOptions()
        case .postedWithin:
            return ListingFilter.DatePostedWithinOption.numberOfOptions()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier, for: indexPath)
        
        switch optionPickingMode! {
        case .sortBy:
            cell.textLabel?.text = ListingFilter.SortByOption.option(forIndex: indexPath.row).rawValue
        case .postedWithin:
            cell.textLabel?.text = ListingFilter.DatePostedWithinOption.option(forIndex: indexPath.row).rawValue
        }
        
        return cell
    }
}

extension ListingFilterOptionPickerViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch optionPickingMode! {
        case .sortBy:
            let optionPicked = ListingFilter.SortByOption.option(forIndex: indexPath.row)
            delegate.didPick(sortByOption: optionPicked)
        case .postedWithin:
            let optionPicked = ListingFilter.DatePostedWithinOption.option(forIndex: indexPath.row)
            delegate.didPick(datePostedWithinOption: optionPicked)
        }
    }
}
