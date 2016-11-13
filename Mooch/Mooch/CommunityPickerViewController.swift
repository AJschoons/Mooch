//
//  CommunityPickerViewController.swift
//  Mooch
//
//  Created by adam on 10/19/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import AlamofireImage
import INTULocationManager
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
    
    weak var delegate: CommunityPickerViewControllerDelegate!
    
    var configuration: Configuration!
    
    // MARK: Private variables
    
    static fileprivate let StoryboardName = "CommunityPicker"
    static fileprivate let Identifier = "CommunityPickerViewController"
    
    static fileprivate let LocationTimeout: Double = 10.0
    
    fileprivate let _allCommunities = CommunityManager.sharedInstance.communities
    
    fileprivate var communities: [Community] {
        get {
            switch selectedControl {
            //Alphabetical order
            case .first:
                return _allCommunities.sorted(by: {$0.name < $1.name})
            
            //Closest distance order
            case .second:
                if isGettingLocation {
                    return []
                } else {
                    guard let currentLocation = currentLocation else { return [] }
                    
                    var communitiesWithUpdatedDistances = [Community]()
                    for var community in _allCommunities {
                        community.updateAndCalculateDistance(fromUserLocation: currentLocation)
                        communitiesWithUpdatedDistances.append(community)
                    }
                    
                    return communitiesWithUpdatedDistances.sorted(by: { $0.distanceFromUser < $1.distanceFromUser })
                }
            }
        }
    }
    
    private var finishSendingToAPIAfterMinimumDurationTimer: ExecuteActionAfterMinimumDurationTimer?
    private var finishGettingLocationAfterMinimumDurationTimer: ExecuteActionAfterMinimumDurationTimer?
    
    fileprivate var selectedControl: BottomBarDoubleSegmentedControl.Control = .first
    fileprivate var isGettingLocation = false
    
    //Used to get location permissions
    fileprivate var locationManager: CLLocationManager!
    
    fileprivate var isGettingLocationAuthorized = false
    
    fileprivate var currentLocation: CLLocation?
    
    
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
        
        setupLocationManager()
        getLocationPermissions()
        
        updateUI()
    }
    
    override func updateUI() {
        super.updateUI()
        
        collectionHandler.reloadData()
    }
    
    
    // MARK: Private methods
    
    fileprivate func onDidSelectControl(_ control: BottomBarDoubleSegmentedControl.Control) {
        selectedControl = control
        
        switch control {
        case .first:
            if isGettingLocation {
                //When the user was waiting for the location and selected the other tab...
                isGettingLocation = false
                hideLoadingOverlayView(animated: true)
            }
            collectionHandler.resetScroll()
            updateUI()
            
        case .second:
            guard isGettingLocationAuthorized else {
                selectedControl = .first
                updateUI()
                presentSingleActionAlert(title: "Location Services Unauthorized", message: "Location Serives must be authorized to find the closest communities. Please enable Location Services by going to Settings > Mooch > Location, and try again", actionTitle: Strings.Alert.defaultSingleActionTitle.rawValue)
                return
            }
            
            isGettingLocation = true
            updateUI()
            
            showLoadingOverlayView(withInformationText: "Getting Location", overEntireWindow: false, withUserInteractionEnabled: true, showingProgress: false, withHiddenAlertView: false)
            
            getLocation()
        }
    }
    
    fileprivate func getLocationPermissions() {
        if CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            isGettingLocationAuthorized = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    fileprivate func getLocation() {
        let locationManager = INTULocationManager.sharedInstance()
        let timeout = CommunityPickerViewController.LocationTimeout
        
        finishGettingLocationAfterMinimumDurationTimer = ExecuteActionAfterMinimumDurationTimer(minimumDuration: 1.0)
        
        currentLocation = nil
        locationManager.requestLocation(withDesiredAccuracy: .city, timeout: timeout, delayUntilAuthorized: true, block: { currentLocation, accuracy, status in
            DispatchQueue.main.async { [weak self] in
                guard let minimumDurationTimer = self?.finishGettingLocationAfterMinimumDurationTimer else { return }
                
                minimumDurationTimer.execute { [weak self] in
                    guard let strongSelf = self else { return }
                    
                    //Make sure a different tab was not selected
                    guard strongSelf.isGettingLocation else { return }
                    
                    strongSelf.isGettingLocation = false
                    strongSelf.hideLoadingOverlayView(animated: true)
                    
                    guard status == .success, let currentLocation = currentLocation else {
                        strongSelf.presentSingleActionAlert(title: "Problem Getting Location", message: "We were not able to find the location in the current conditions. Please try again", actionTitle: Strings.Alert.defaultSingleActionTitle.rawValue)
                        return
                    }
                    
                    strongSelf.currentLocation = currentLocation
                    
                    strongSelf.updateUI()
                }
            }
        })
    }
    
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
    
    fileprivate func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
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
    
    func getSelectedControl() -> BottomBarDoubleSegmentedControl.Control {
        return selectedControl
    }
    
    func didSelect(_ community: Community) {
        onDidSelect(community)
    }
}

extension CommunityPickerViewController: BottomBarDoubleSegmentedControlDelegate {
    //Part of ProfileCollectionHandlerDelegate
    
    func didSelect(_ selectedControl: BottomBarDoubleSegmentedControl.Control) {
        onDidSelectControl(selectedControl)
    }
}

extension CommunityPickerViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            isGettingLocationAuthorized = true
        } else {
            isGettingLocationAuthorized = false
        }
    }
}
