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
        case Guest
        case LoggedIn
    }
    
    //The variable to access this class trhough
    static let sharedInstance = LocalUserManager()
    
    //This prevents others from using the default '()' initializer for this class
    private init() {}
    
    private(set) var localUser: LocalUser?
    private(set) var state: LocalUserState = .Guest
    
    func login(withLocalUser localUser: LocalUser) {
        self.localUser = localUser
        state = .LoggedIn
    }
    
    func logout() {
        localUser = nil
        state = .Guest
    }
}