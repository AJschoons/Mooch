//
//  InitialLoadingViewController.swift
//  Mooch
//
//  Created by adam on 9/10/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

class InitialLoadingViewController: MoochModalViewController {

    // MARK: Public variables
    
    // MARK: Private variables
    
    // MARK: Actions
    
    // MARK: Public methods
    
    override func setup() {
        super.setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getDataInitiallyNeededFromAPI()
    }
    
    override func prefersNavigationBarHidden() -> Bool {
        return true
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    override func shouldAnimateStatusBarChange() -> Bool {
        return false
    }
    
    func onFinishedLoading() {
        performCrossFadeViewControllerPop()
    }
    
    
    // MARK: Private methods

    private func getDataInitiallyNeededFromAPI() {
        //TODO: actually login a user instead of hardcoding a guest to community with id 1
        LocalUserManager.sharedInstance.updateGuest(communityId: 1)
        
        MoochAPI.GETListingCategories() { listingCategories, error in
            if let listingCategories = listingCategories {
                ListingCategoryManager.sharedInstance.update(withListingCategories: listingCategories)
                self.onFinishedLoading()
            } else {
                self.presentCouldNotDownloadInitialDataAlert()
            }
        }
    }
    
    private func presentCouldNotDownloadInitialDataAlert() {
        presentSingleActionAlert(title: Strings.InitialLoading.couldNotDownloadInitialDataAlertTitle.rawValue, message: Strings.InitialLoading.couldNotDownloadInitialDataAlertMessage.rawValue, actionTitle: Strings.Alert.singleActionTryAgainTitle.rawValue) { action in
            self.getDataInitiallyNeededFromAPI()
        }
    }
    
    fileprivate func performCrossFadeViewControllerPop() {
        guard let navC = navigationController else { return }
        
        // Setup cross fade transition for popping view controller
        let transtion = CATransition()
        transtion.duration = 0.3
        transtion.type = kCATransitionFade
        navC.view.layer.add(transtion, forKey: kCATransition)
        navC.setNavigationBarHidden(false, animated: false)
        navC.popViewController(animated: false)
    }
}
