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
    
    fileprivate var _localUser: LocalUser?
    fileprivate(set) var guestCommunityId: Int?
    fileprivate(set) var state: LocalUserState = .guest
    
    var localUser: LocalUser? {
        guard state == .loggedIn else { return nil }
        return _localUser
    }
    
    var userCommunityId: Int? {
        if state == .guest {
            return guestCommunityId
        } else {
            if let localUser = _localUser {
                return localUser.user.communityId
            }
        }
        
        return nil
    }
    
    func updateGuest(communityId: Int) {
        guestCommunityId = communityId
    }
    
    func login(localUser: LocalUser) {
        self._localUser = localUser
        state = .loggedIn
        guestCommunityId = nil
        MoochAPI.setAuthorizationCredentials(email: localUser.user.contactInformation.email, authorizationToken: localUser.authenticationToken)
    }
    
    //Defaults the guest community id to the community id of the user logging out
    func logout() {
        guestCommunityId = _localUser?.user.communityId
        
        _localUser = nil
        state = .guest
        MoochAPI.clearAuthorizationCredentials()
    }
}
