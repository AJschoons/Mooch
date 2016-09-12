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
        
        NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: #selector(onFinishedLoading), userInfo: nil, repeats: false)
    }
    
    override func prefersNavigationBarHidden() -> Bool {
        return true
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func shouldAnimateStatusBarChange() -> Bool {
        return false
    }
    
    func onFinishedLoading() {
        performCrossFadeViewControllerPop()
    }
    
    
    // MARK: Private methods

    private func performCrossFadeViewControllerPop() {
        guard let navC = navigationController else { return }
        
        // Setup cross fade transition for popping view controller
        let transtion = CATransition()
        transtion.duration = 0.3
        transtion.type = kCATransitionFade
        navC.view.layer.addAnimation(transtion, forKey: kCATransition)
        navC.setNavigationBarHidden(false, animated: false)
        navC.popViewControllerAnimated(false)
    }
}
