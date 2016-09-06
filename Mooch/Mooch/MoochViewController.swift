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
    
    //Flag for whether or this this view controller will need a network connection
    private var requiresNetworkReachability = true
    
    //Flag for whether or not the network reachability verification view controller is being shown
    private var isShowingNetworkReachabilityVerificationViewController = false
    
    //The view controller that is shown while the network reachability is being established
    private var networkReachabilityVerificationViewController: UIViewController?
    
    //The network reachability manager used to observe network reachability changes
    private var reachabilityManager: NetworkReachabilityManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupReachabilityManager()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if requiresNetworkReachability && !reachabilityManager.isReachable {
            presentNetworkReachabilityVerificationViewController()
        }
    }
    
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
        
        let nrvvc = UIViewController()
        networkReachabilityVerificationViewController = nrvvc
        nrvvc.view.backgroundColor = UIColor.redColor()
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
    
    
    //Performs any actions that need to be taken once the network connectivity has been established
    //Should be overridden by subclasses
    private func didEstablishNetworkReachability() { }
    
    //Returns true when this view controller is visible
    private func isVisible() -> Bool {
        return isViewLoaded() && view.window != nil
    }
}
