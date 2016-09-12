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
    private var isShowingNetworkReachabilityVerificationViewController = false
    
    //The view controller that is shown while the network reachability is being established
    private var networkReachabilityVerificationViewController: UIViewController?
    
    //The network reachability manager used to observe network reachability changes
    private var reachabilityManager: NetworkReachabilityManager!
    
    //Used to restore previous status bar style if changed for this view controller
    private var statusBarStyleBeforeChanging: UIStatusBarStyle?
    
    
    // MARK: Actions
    
    // MARK: Public methods
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        captureStatusBarStyle()
        updateStatusBarStyle()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupReachabilityManager()
        setup()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if requiresNetworkReachability && !reachabilityManager.isReachable {
            presentNetworkReachabilityVerificationViewController()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
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
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.Default
    }
    
    //Override this function to change status bar animation behavior
    func shouldAnimateStatusBarChange() -> Bool {
        return true
    }
    
    func presentModalInNavigationController(withRootViewController rootViewController: UIViewController) {
        let navController = UINavigationController(rootViewController: rootViewController)
        presentViewController(navController, animated: true, completion: nil)
    }
    
    
    // MARK: Private methods
    
    //Sets up the reachability manager with the reachabilityHostURL that exists at the time this function is called
    private func setupReachabilityManager() {
        reachabilityManager = NetworkReachabilityManager()
        reachabilityManager.listener = { [weak self] reachabilityStatus in
            guard let strongSelf = self else { return }
            
            print("network changed to reachable:\(strongSelf.reachabilityManager.isReachable)")
            if strongSelf.reachabilityManager.isReachable {
                strongSelf.hideNetworkReachabilityVerificationViewController()
            } else {
                strongSelf.presentNetworkReachabilityVerificationViewController()
            }
        }
        reachabilityManager.startListening()
    }
    
    //Shows the appropriate view controller while the network connection is being established
    private func presentNetworkReachabilityVerificationViewController() {
        guard requiresNetworkReachability && isVisible() && isShowingNetworkReachabilityVerificationViewController == false else { return }
        
        isShowingNetworkReachabilityVerificationViewController = true
        
        let nrvvc = NetworkReachabilityVerificationViewController()
        networkReachabilityVerificationViewController = nrvvc
        nrvvc.modalTransitionStyle = .CrossDissolve
        nrvvc.modalPresentationStyle = .OverFullScreen
        presentViewController(nrvvc, animated: true, completion: nil)
    }
    
    //Hides the appropriate view controller while the network connection is being established
    private func hideNetworkReachabilityVerificationViewController() {
        guard networkReachabilityVerificationViewController != nil && isShowingNetworkReachabilityVerificationViewController else { return }
        
        networkReachabilityVerificationViewController?.dismissViewControllerAnimated(true) {
            self.networkReachabilityVerificationViewController = nil
            self.isShowingNetworkReachabilityVerificationViewController = false
            self.didEstablishNetworkReachability()
        }
    }
    
    //Returns true when this view controller is visible
    private func isVisible() -> Bool {
        return isViewLoaded() && view.window != nil
    }
    
    private func updateStatusBarStyle() {
        guard let _ = statusBarStyleBeforeChanging else { return }
        UIApplication.sharedApplication().setStatusBarStyle(preferredStatusBarStyle(), animated: shouldAnimateStatusBarChange())
    }
    
    private func captureStatusBarStyle() {
        let currentStyle = UIApplication.sharedApplication().statusBarStyle
        if currentStyle != preferredStatusBarStyle() {
            statusBarStyleBeforeChanging = currentStyle
        }
    }
    
    private func restoreStatusBarStyle() {
        guard let previousStyle = statusBarStyleBeforeChanging else { return }
        UIApplication.sharedApplication().setStatusBarStyle(previousStyle, animated: false)
    }
}
