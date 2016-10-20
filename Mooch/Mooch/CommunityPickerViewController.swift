//
//  CommunityPickerViewController.swift
//  Mooch
//
//  Created by adam on 10/19/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

protocol CommunityPickerViewControllerDelegate: class {
    func didPick(community: Community)
}

class CommunityPickerViewController: MoochViewController {
    
    // MARK: Public variables
    
    @IBOutlet var collectionHandler: CommunityPickerCollectionHandler! {
        didSet {
            collectionHandler.delegate = self
        }
    }
    
    let communities = CommunityManager.sharedInstance.communities
    
    weak var delegate: CommunityPickerViewControllerDelegate!
    
    //The currently selected community will appear as selected
    var selectedCommunity: Community?
    
    // MARK: Private variables
    
    static fileprivate let StoryboardName = "CommunityPicker"
    static fileprivate let Identifier = "CommunityPickerViewController"
    
    
    // MARK: Actions
    
    // MARK: Public methods
    
    static func instantiateFromStoryboard() -> CommunityPickerViewController {
        let storyboard = UIStoryboard(name: CommunityPickerViewController.StoryboardName, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: CommunityPickerViewController.Identifier) as! CommunityPickerViewController
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
        title = Strings.CommunityPicker.title.rawValue
    }
}

extension CommunityPickerViewController: CommunityPickerCollectionHandlerDelegate {
    
    func getCommunities() -> [Community] {
        return communities
    }
    
    func didSelect(_ community: Community) {
        delegate.didPick(community: community)
    }
}
