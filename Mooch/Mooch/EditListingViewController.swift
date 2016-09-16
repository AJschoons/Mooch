//
//  EditListingViewController.swift
//  Mooch
//
//  Created by adam on 9/16/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

protocol EditListingViewControllerDelegate: class {
    
    //Allows the delegate to handle dismissing this view controller at the appropriate time
    func editListingViewControllerDidFinishEditing(withListing editedListing: Listing)
}

class EditListingViewController: MoochModalViewController {
    
    //A configuration to setup the class with
    struct Configuration {
        
        var mode: Mode
        
        var title: String
        var leftBarButtons: [BarButtonType]?
        var rightBarButtons: [BarButtonType]?
        
        //The bar buttons that can be added
        enum BarButtonType {
            case cancel
            case done
        }
        
        enum Mode {
            case creating
            case editing
        }
    }
    
    // MARK: Public variables
    
    static let DefaultCreatingConfiguration = Configuration(mode: .creating, title: "Create Listing", leftBarButtons: [.cancel], rightBarButtons: [.done])
    static let DefaultEditingConfiguration = Configuration(mode: .creating, title: "Edit Listing", leftBarButtons: [.cancel], rightBarButtons: [.done])
    
    weak var delegate: EditListingViewControllerDelegate!
    
    //The configuration used to setup the class
    var configuration: Configuration!
    
    //The listing being edited
    var listing: Listing?
    
    
    // MARK: Private variables
    
    static fileprivate let StoryboardName = "EditListing"
    static fileprivate let Identifier = "EditListingViewController"
    
    fileprivate var doneButton: UIBarButtonItem!
    fileprivate var cancelButton: UIBarButtonItem!
    
    
    // MARK: Actions
    
    func onDoneAction() {
        let dummyListing = Listing.createDummy(fromNumber: 23)
        dismiss(animated: true) {
            self.delegate.editListingViewControllerDidFinishEditing(withListing: dummyListing)
        }
    }
    
    func onCancelAction() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Public methods
    
    override func setup() {
        super.setup()
        
        setupNavigationBar()
        
        updateUI()
    }
    
    override func updateUI() {
        super.updateUI()
        
    }
    
    static func instantiateFromStoryboard() -> EditListingViewController {
        let storyboard = UIStoryboard(name: EditListingViewController.StoryboardName, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: EditListingViewController.Identifier) as! EditListingViewController
    }
    
    
    // MARK: Private methods
    
    fileprivate func setupNavigationBar() {
        doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(onDoneAction))
        cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(onCancelAction))
        
        title = configuration.title
        
        if let leftButtons = configuration.leftBarButtons {
            navigationItem.leftBarButtonItems = barButtons(fromTypeList: leftButtons)
        } else {
            navigationItem.leftBarButtonItems = nil
        }
        
        if let rightButtons = configuration.rightBarButtons {
            navigationItem.rightBarButtonItems = barButtons(fromTypeList: rightButtons)
        } else {
            navigationItem.rightBarButtonItems = nil
        }
    }
    
    fileprivate func barButtons(fromTypeList typeList: [Configuration.BarButtonType]) -> [UIBarButtonItem] {
        return typeList.map({barButton(forType: $0)})
    }
    
    fileprivate func barButton(forType type: Configuration.BarButtonType) -> UIBarButtonItem {
        switch type {
        case .cancel:
            return cancelButton
        case .done:
            return doneButton
        }
    }
}
