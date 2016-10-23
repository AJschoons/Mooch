//
//  ListingDetailsViewController.swift
//  Mooch
//
//  Created by adam on 9/11/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

class ListingDetailsViewController: MoochViewController {
    
    typealias Configuration = ListingDetailsConfiguration
    
    // MARK: Public variables
    
    
    @IBOutlet var tableHandler: ListingDetailsTableHandler! {
        didSet {
            tableHandler.delegate = self
        }
    }
    
    //The configuration used to setup the class
    var configuration: Configuration!
    
    var listing: Listing!

    
    // MARK: Private variables
    
    static fileprivate let StoryboardName = "ListingDetails"
    static fileprivate let Identifier = "ListingDetailsViewController"
    
    fileprivate var editButton: UIBarButtonItem!
    
    // MARK: Actions
    
    func onEditAction() {
        print("edit action")
    }
    
    func onContactSellerAction() {
        print("contact seller action")
    }
    
    func onViewSellerProfileAction() {
        print("view seller action")
    }
    
    func onEndListingAction() {
        print("end listing action")
    }
    
    func onDidAcceptBuyer(_ buyer: User) {
        print("did accept buyer ", buyer)
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
    
    static func instantiateFromStoryboard() -> ListingDetailsViewController {
        let storyboard = UIStoryboard(name: ListingDetailsViewController.StoryboardName, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: ListingDetailsViewController.Identifier) as! ListingDetailsViewController
    }
    
    // MARK: Private methods
    
    fileprivate func setupNavigationBar() {
        editButton = UIBarButtonItem(image: UIImage(named: "settings"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(onEditAction))
        
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
        case .edit:
            return editButton
        }
    }
}

extension ListingDetailsViewController: ListingDetailsTableHandlerDelegate {
    
    func getConfiguration() -> Configuration {
        return configuration
    }
    
    func tabBarHeight() -> CGFloat {
        return (tabBarController != nil) ? tabBarController!.tabBar.frame.height : CGFloat(0.0)
    }
}

extension ListingDetailsViewController: ListingDetailsActionCellDelegate {
    
    func onActionButton(forFieldType fieldType: ListingDetailsViewController.Configuration.FieldType) {
        guard fieldType.isAction() else { return }
        switch fieldType {
            
        case .contactSeller:
            onContactSellerAction()
            
        case .viewSellerProfile:
            onViewSellerProfileAction()
            
        case .endListing:
            onEndListingAction()
            
        default:
            return
        }
    }
}

extension ListingDetailsViewController: ListingDetailsInterestedBuyerCellDelegate {
    
    func didAccept(buyer: User) {
        onDidAcceptBuyer(buyer)
    }
}
