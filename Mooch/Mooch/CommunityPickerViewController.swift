//
//  CommunityPickerViewController.swift
//  Mooch
//
//  Created by adam on 10/19/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import AlamofireImage
import UIKit

protocol CommunityPickerViewControllerDelegate: class {
    func communityPickerViewController(_ : CommunityPickerViewController, didPick community: Community)
    func communityPickerViewControllerDidCancel(_ : CommunityPickerViewController)
}

class CommunityPickerViewController: MoochViewController {
    
    struct Configuration {
        
        //Whether or not we allow the user to cancel picking the community
        enum PickingMode {
            case forced
            case optional
        }
        
        var pickingMode: PickingMode
        var shouldUploadToAPIForLocalUser: Bool
    }
    
    // MARK: Public variables
    
    @IBOutlet var collectionHandler: CommunityPickerCollectionHandler! {
        didSet {
            collectionHandler.delegate = self
        }
    }
    
    let communities = CommunityManager.sharedInstance.communities
    
    weak var delegate: CommunityPickerViewControllerDelegate!
    
    var configuration: Configuration!
    
    // MARK: Private variables
    
    static fileprivate let StoryboardName = "CommunityPicker"
    static fileprivate let Identifier = "CommunityPickerViewController"
    
    private var finishSendingToAPIAfterMinimumDurationTimer: ExecuteActionAfterMinimumDurationTimer?
    
    
    // MARK: Actions
    
    func onCancel() {
        delegate.communityPickerViewControllerDidCancel(self)
    }
    
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
    
    fileprivate func onDidSelect(_ community: Community) {
        if configuration.shouldUploadToAPIForLocalUser {
            sendNewCommunityToAPI(community)
        } else {
            delegate.communityPickerViewController(self, didPick: community)
        }
    }
    
    fileprivate func sendNewCommunityToAPI(_ community: Community) {
        guard let localUser = LocalUserManager.sharedInstance.localUser else { return }
        
        showLoadingOverlayView(withInformationText: "Changing Community", overEntireWindow: true, withUserInteractionEnabled: false, showingProgress: false, withHiddenAlertView: false)
        
        finishSendingToAPIAfterMinimumDurationTimer = ExecuteActionAfterMinimumDurationTimer(minimumDuration: 1.0)
        
        MoochAPI.PUTUserCommunity(userId: localUser.user.id, communityId: community.id) { success, error in
            //The code inside this execute closure gets executed only after the minimum duration has passed
            self.finishSendingToAPIAfterMinimumDurationTimer!.execute { [unowned self] in
                //DO NOT keep the timer around after it's been executed
                self.finishSendingToAPIAfterMinimumDurationTimer = nil
                
                self.hideLoadingOverlayView(animated: true)
                
                guard success else {
                    self.presentSingleActionAlert(title: "Problem changing community", message: "Please try again", actionTitle: Strings.Alert.defaultSingleActionTitle.rawValue)
                    return
                }
                
                self.delegate.communityPickerViewController(self, didPick: community)
            }
        }
    }
    
    fileprivate func setupNavigationBar() {
        title = Strings.CommunityPicker.title.rawValue
        
        if configuration.pickingMode == .optional {
            let cancelImage = #imageLiteral(resourceName: "cancel").af_imageAspectScaled(toFit: CGSize(width: 22, height: 22))
            let cancelBarButtonItem = UIBarButtonItem(image: cancelImage, style: .plain, target: self, action: #selector(onCancel))
            navigationItem.leftBarButtonItems = [cancelBarButtonItem]
        }
    }
}

extension CommunityPickerViewController: CommunityPickerCollectionHandlerDelegate {
    
    func getCommunities() -> [Community] {
        return communities
    }
    
    func didSelect(_ community: Community) {
        onDidSelect(community)
    }
}
