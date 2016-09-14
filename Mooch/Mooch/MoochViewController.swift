//
//  MoochViewController.swift
//  Mooch
//
//  Created by adam on 9/5/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import Alamofire
import UIKit

//Base class view controller
class MoochViewController: UIViewController {
    
    // MARK: Public variables
    
    //Flag for whether or this this view controller will need a network connection
    var requiresNetworkReachability = true
    
    
    // MARK: Private variables
    
    //Flag for whether or not the network reachability verification view controller is being shown
    fileprivate var isShowingNetworkReachabilityVerificationViewController = false
    
    //The view controller that is shown while the network reachability is being established
    fileprivate var networkReachabilityVerificationViewController: UIViewController?
    
    //The network reachability manager used to observe network reachability changes
    fileprivate var reachabilityManager: NetworkReachabilityManager!
    
    //Used to restore previous status bar style if changed for this view controller
    fileprivate var statusBarStyleBeforeChanging: UIStatusBarStyle?
    
    
    // MARK: Actions
    
    // MARK: Public methods
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        captureStatusBarStyle()
        updateStatusBarStyle()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupReachabilityManager()
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if requiresNetworkReachability && !reachabilityManager.isReachable {
            presentNetworkReachabilityVerificationViewController()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        restoreStatusBarStyle()
    }
    
    //Performs any actions that need to be taken once the view has been loaded
    //Should be overridden by subclasses
    func setup() { }
    
    //Performs any actions that need to be taken once the network connectivity has been established
    //Should be overridden by subclasses
    func didEstablishNetworkReachability() { }
    
    //Updates the UI based on current state. All UI changes should be handled here
    //Should be overridden by subclasses
    func updateUI() { }
    
    //Override this function to change the default preferred status bar style
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.default
    }
    
    //Override this function to change status bar animation behavior
    func shouldAnimateStatusBarChange() -> Bool {
        return true
    }
    
    func presentModalInNavigationController(withRootViewController rootViewController: UIViewController) {
        let navController = UINavigationController(rootViewController: rootViewController)
        present(navController, animated: true, completion: nil)
    }
    
    
    // MARK: Private methods
    
    //Sets up the reachability manager with the reachabilityHostURL that exists at the time this function is called
    fileprivate func setupReachabilityManager() {
        reachabilityManager = NetworkReachabilityManager()
        reachabilityManager.listener = { [weak self] reachabilityStatus in
            guard let strongSelf = self else { return }
            
            if strongSelf.reachabilityManager.isReachable {
                strongSelf.hideNetworkReachabilityVerificationViewController()
            } else {
                strongSelf.presentNetworkReachabilityVerificationViewController()
            }
        }
        reachabilityManager.startListening()
    }
    
    //Shows the appropriate view controller while the network connection is being established
    fileprivate func presentNetworkReachabilityVerificationViewController() {
        guard requiresNetworkReachability && isVisible() && isShowingNetworkReachabilityVerificationViewController == false else { return }
        
        isShowingNetworkReachabilityVerificationViewController = true
        
        let nrvvc = NetworkReachabilityVerificationViewController()
        networkReachabilityVerificationViewController = nrvvc
        nrvvc.modalTransitionStyle = .crossDissolve
        nrvvc.modalPresentationStyle = .overFullScreen
        present(nrvvc, animated: true, completion: nil)
    }
    
    //Hides the appropriate view controller while the network connection is being established
    fileprivate func hideNetworkReachabilityVerificationViewController() {
        guard networkReachabilityVerificationViewController != nil && isShowingNetworkReachabilityVerificationViewController else { return }
        
        networkReachabilityVerificationViewController?.dismiss(animated: true) {
            self.networkReachabilityVerificationViewController = nil
            self.isShowingNetworkReachabilityVerificationViewController = false
            self.didEstablishNetworkReachability()
        }
    }
    
    //Returns true when this view controller is visible
    fileprivate func isVisible() -> Bool {
        return isViewLoaded && view.window != nil
    }
    
    fileprivate func updateStatusBarStyle() {
        guard let _ = statusBarStyleBeforeChanging else { return }
        UIApplication.shared.setStatusBarStyle(preferredStatusBarStyle, animated: shouldAnimateStatusBarChange())
    }
    
    fileprivate func captureStatusBarStyle() {
        let currentStyle = UIApplication.shared.statusBarStyle
        if currentStyle != preferredStatusBarStyle {
            statusBarStyleBeforeChanging = currentStyle
        }
    }
    
    fileprivate func restoreStatusBarStyle() {
        guard let previousStyle = statusBarStyleBeforeChanging else { return }
        UIApplication.shared.setStatusBarStyle(previousStyle, animated: false)
    }
}
