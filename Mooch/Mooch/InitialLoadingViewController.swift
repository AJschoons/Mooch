//
//  InitialLoadingViewController.swift
//  Mooch
//
//  Created by adam on 9/10/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

class InitialLoadingViewController: MoochModalViewController {

    enum State {
        case loading
        case failedPushNotifcationRegistration
    }
    
    // MARK: Public variables
    
    // MARK: Private variables
    
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    
    
    //Allows us to ensure that loading takes at least a minimim duration; makes the UX smoother
    private var finishLoadingAfterMinimumDurationTimer: ExecuteActionAfterMinimumDurationTimer!
    
    // MARK: Actions
    
    // MARK: Public methods
    
    override func setup() {
        super.setup()
        
        set(state: .loading)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        PushNotificationsManager.sharedInstance.registrationDelegate = nil
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
    
    //Finishes loading after the minimum duration has elapsed
    func onFinishedLoading(willShowCommunityPicker: Bool) {
        finishLoadingAfterMinimumDurationTimer.execute() { [weak self] in
            guard let strongSelf = self else { return }
            
            if willShowCommunityPicker {
                strongSelf.presentCommunityPicker()
            } else {
                strongSelf.transitionToMainApp()
            }
        }
    }
    
    
    // MARK: Private methods

    fileprivate func set(state: State) {
        switch state {

        case .loading:
            loadingLabel.text = Strings.InitialLoading.loadingText.rawValue
            loadingActivityIndicator.isHidden = false
            
        case .failedPushNotifcationRegistration:
            loadingLabel.text = Strings.InitialLoading.failedPushNotificationRegistrationText.rawValue
            loadingActivityIndicator.isHidden = true
        }
    }
    
    //Kicks off the string of API requests we need to load and launch the app
    fileprivate func getDataInitiallyNeededFromAPI() {
        finishLoadingAfterMinimumDurationTimer = ExecuteActionAfterMinimumDurationTimer(minimumDuration: 0.75)
        getListingCategories()
    }
    
    //The first API call we make
    private func getListingCategories() {
        MoochAPI.GETListingCategories() { listingCategories, error in
            if let listingCategories = listingCategories {
                ListingCategoryManager.sharedInstance.update(withListingCategories: listingCategories)
                self.getCommunities()
            } else {
                self.presentCouldNotDownloadInitialDataAlert()
            }
        }
    }
    
    //The second API call we make
    private func getCommunities() {
        MoochAPI.GETCommunities() { communities, error in
            if let communities = communities {
                CommunityManager.sharedInstance.update(withCommunities: communities)
                self.loginSavedUser()
            } else {
                self.presentCouldNotDownloadInitialDataAlert()
            }
        }
    }
    
    //The third API call we make
    //If a saved user exists, download their info and log them in and update their device token. Else continue with a guest
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
            LocalUserManager.sharedInstance.login(localUser: savedLocalUser)
            
            self.updateLocalUserDeviceToken()
        }
    }
    
    //The last API call we make. Not a huge deal if it fails so we allow loading to finish whether it succeeds or fails
    private func updateLocalUserDeviceToken() {
        guard let localUser = LocalUserManager.sharedInstance.localUser, let deviceToken = PushNotificationsManager.sharedInstance.deviceToken else {
            continueWithLocalUser()
            return
        }
        
        MoochAPI.PUTUserDeviceToken(userId: localUser.user.id, deviceToken: deviceToken) { success, error in
            self.continueWithLocalUser()
        }
    }
    
    //Handles what should be done when there IS a saved user we downloaded
    private func continueWithLocalUser() {
        onFinishedLoading(willShowCommunityPicker: false)
    }
    
    //Handles what should be done when there is NOT a saved user we downloaded
    private func continueWithGuest() {
        guard let savedGuestInformation = LocalUserManager.sharedInstance.getSavedGuesInformationFromUserDefaults() else {
            //We need to force the user to pick a community
            onFinishedLoading(willShowCommunityPicker: true)
            return
        }
        
        LocalUserManager.sharedInstance.updateGuest(communityId: savedGuestInformation.communityId)
        transitionToMainApp()
    }
    
    private func presentCommunityPicker() {
        let vc = CommunityPickerViewController.instantiateFromStoryboard()
        vc.configuration = CommunityPickerViewController.Configuration(pickingMode: .forced, shouldUploadToAPIForLocalUser: false)
        vc.delegate = self
        let navC = UINavigationController(rootViewController: vc)
        
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        
        present(navC, animated: true, completion: nil)
    }
    
    private func presentCouldNotDownloadInitialDataAlert() {
        presentSingleActionAlert(title: Strings.InitialLoading.couldNotDownloadInitialDataAlertTitle.rawValue, message: Strings.InitialLoading.couldNotDownloadInitialDataAlertMessage.rawValue, actionTitle: Strings.Alert.singleActionTryAgainTitle.rawValue) { action in
            self.getDataInitiallyNeededFromAPI()
        }
    }
    
    fileprivate func transitionToMainApp() {
        (UIApplication.shared.delegate! as! AppDelegate).transitionToMoochTabBarController()
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

extension InitialLoadingViewController: CommunityPickerViewControllerDelegate {
    
    func communityPickerViewController(_ : CommunityPickerViewController, didPick community: Community) {
        LocalUserManager.sharedInstance.updateGuest(communityId: community.id)
        transitionToMainApp()
    }
    
    func communityPickerViewControllerDidCancel(_ : CommunityPickerViewController) {
        //The CommunityPickerViewController is setup so it can't cancel; don't need to do anything
    }
}

extension InitialLoadingViewController: PushNotificationsManagerRegistrationDelegate {
    
    func pushNotificationsDidRegister(success: Bool) {
        getDataInitiallyNeededFromAPI()
    }
}
