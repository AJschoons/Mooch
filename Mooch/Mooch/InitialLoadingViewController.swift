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

    //Kicks off the string of API requests we need to load and launch the app
    private func getDataInitiallyNeededFromAPI() {
        getListingCategories()
    }
    
    //The first API call we make
    private func getListingCategories() {
        MoochAPI.GETListingCategories() { listingCategories, error in
            if let listingCategories = listingCategories {
                ListingCategoryManager.sharedInstance.update(withListingCategories: listingCategories)
                self.loginSavedUser()
            } else {
                self.presentCouldNotDownloadInitialDataAlert()
            }
        }
    }
    
    //The last API call we make
    //If a saved user exists, download their info and log them in. Else continue with a guest
    private func loginSavedUser() {
        guard let savedUserInformation = LocalUserManager.sharedInstance.getSavedInformationFromUserDefaults() else {
            continueWithGuest()
            return
        }
        
        let userId = savedUserInformation.userId
        let authenticationToken = savedUserInformation.authenticationToken
        let email = savedUserInformation.email
        
        MoochAPI.GETUserOnce(withId: userId, email: email, authorizationToken: authenticationToken) { user, error in
            guard let user = user else {
                self.continueWithGuest()
                return
            }
            
            let savedLocalUser = LocalUser(user: user, authenticationToken: savedUserInformation.authenticationToken)
            self.finishLoading(with: savedLocalUser)
        }
    }
    
    //Handles what should be done when there IS a saved user we downloaded
    private func finishLoading(with localUser: LocalUser) {
        LocalUserManager.sharedInstance.login(localUser: localUser)
        onFinishedLoading()
    }
    
    //Handles what should be done when there is NOT a saved user we downloaded
    private func continueWithGuest() {
        //TODO: handle picking a community instead of hardcoding a guest to community with id 1
        LocalUserManager.sharedInstance.updateGuest(communityId: 1)
        onFinishedLoading()
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
