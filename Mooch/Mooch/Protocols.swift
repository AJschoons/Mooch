//
//  Protocols.swift
//  Mooch
//
//  Created by adam on 9/20/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

//Protocol for an object that has another responder to become active after the object is done
//Example: Pressing "Done" on a UITextView
protocol NavigableResponder: class {
    weak var nextNavigableResponder: UIResponder? { get }
}

//Used to allow the MoochTabBarController to update its view controllers when the login state changes
protocol LocalUserStateChangeListener {
    func localUserStateDidChange(to: LocalUserManager.LocalUserState)
}
