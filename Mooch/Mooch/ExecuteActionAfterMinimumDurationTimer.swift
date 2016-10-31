//
//  ExecuteActionAfterMinimumDurationTimer.swift
//  Mooch
//
//  Created by adam on 10/17/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import Foundation

class ExecuteActionAfterMinimumDurationTimer {
    
    private let minimumDuration: Double
    private var durationElapsed: Double = 0.0
    private var action: (() -> ())!
    private var durationHasElapsed = false
    private var didAttemptToExecuteAction = false
    
    //Make sure to use unowned self in the action closure
    init(minimumDuration: Double) {
        self.minimumDuration = minimumDuration
        
        Timer.scheduledTimer(timeInterval: minimumDuration, target: self, selector: #selector(onMinimumDurationElapsed), userInfo: nil, repeats: false)
    }
    
    //Do NOT call; public for timer selector
    @objc func onMinimumDurationElapsed() {
        durationHasElapsed = true
        
        if didAttemptToExecuteAction {
            performAction()
        }
    }
    
    func execute(action: @escaping (() -> ())) {
        self.action = action
        didAttemptToExecuteAction = true
        
        if durationHasElapsed {
            performAction()
        }
    }
    
    private func performAction() {
        guard let action = self.action else { return }
        action()
        self.action = nil
    }
}
