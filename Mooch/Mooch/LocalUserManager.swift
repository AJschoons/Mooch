//
//  LocalUserManager.swift
//  Mooch
//
//  Created by adam on 9/10/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import Foundation

//Singleton for managing the local user
class LocalUserManager {
    
    enum LocalUserState {
        case guest
        case loggedIn
    }
    
    //The variable to access this class through
    static let sharedInstance = LocalUserManager()
    
    //This prevents others from using the default '()' initializer for this class
    fileprivate init() {}
    
    fileprivate(set) var localUser: LocalUser?
    fileprivate(set) var state: LocalUserState = .guest
    
    func login(withLocalUser localUser: LocalUser) {
        self.localUser = localUser
        state = .loggedIn
    }
    
    func logout() {
        localUser = nil
        state = .guest
    }
}
