//
//  MoochModalViewController.swift
//  Mooch
//
//  Created by adam on 9/10/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

//Base class modal view controller
class MoochModalViewController: MoochViewController {
    
    // MARK: Public variables
    
    // MARK: Private variables
    
    fileprivate var presentingViewControllerNavigationBarWasHidden = false
    
    
    // MARK: Actions
    
    // MARK: Public methods
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        capturePresentingViewControllerNavigationBarState()
        updateNavigationBarState()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        restorePresentingViewControllerNavigationBarState()
    }
    
    //Override this function to hide the navigation bar when the modal appears
    func prefersNavigationBarHidden() -> Bool {
        return false
    }
    
    
    // MARK: Private methods
    
    fileprivate func updateNavigationBarState() {
        if let navC = navigationController {
            navC.navigationBar.isHidden = prefersNavigationBarHidden()
        }
    }
    
    fileprivate func capturePresentingViewControllerNavigationBarState() {
        if let navC = navigationController {
            presentingViewControllerNavigationBarWasHidden = navC.isNavigationBarHidden
        }
    }
    
    fileprivate func restorePresentingViewControllerNavigationBarState() {
        if let navC = navigationController {
            navC.navigationBar.isHidden = presentingViewControllerNavigationBarWasHidden
        }
    }
}
