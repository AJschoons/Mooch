//
//  LocalUserManager.swift
//  Mooch
//
//  Created by adam on 9/10/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

//Adds the keys to be used with SwiftyUserDefaults
extension DefaultsKeys {
    static let userId = DefaultsKey<Int?>(Strings.UserDefaultsKeys.userId.rawValue)
    static let authenticationToken = DefaultsKey<String?>(Strings.UserDefaultsKeys.authenticationToken.rawValue)
    static let email = DefaultsKey<String?>(Strings.UserDefaultsKeys.email.rawValue)
}

//Singleton for managing the local user
class LocalUserManager {
    
    enum LocalUserState {
        case guest
        case loggedIn
    }
    
    struct SavedUserInformation {
        let userId: Int
        let authenticationToken: String
        let email: String
    }
    
    //The variable to access this class through
    static let sharedInstance = LocalUserManager()
    
    //This prevents others from using the default '()' initializer for this class
    fileprivate init() {}
    
    fileprivate var _localUser: LocalUser?
    fileprivate var guestCommunityId: Int?
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
        saveToUserDefaults(localUser)
    }
    
    //Defaults the guest community id to the community id of the user logging out
    func logout() {
        guestCommunityId = _localUser?.user.communityId
        
        _localUser = nil
        state = .guest
        MoochAPI.clearAuthorizationCredentials()
        deleteFromUserDefaults()
    }
    
    func getSavedInformationFromUserDefaults() -> SavedUserInformation? {
        guard let userId = Defaults[.userId], let authenticationToken = Defaults[.authenticationToken], let email = Defaults[.email] else { return nil }
        return SavedUserInformation(userId: userId, authenticationToken: authenticationToken, email: email)
    }
    
    private func saveToUserDefaults(_ localUser: LocalUser) {
        Defaults[.userId] = localUser.user.id
        Defaults[.authenticationToken] = localUser.authenticationToken
        Defaults[.email] = localUser.user.contactInformation.email
    }
    
    private func deleteFromUserDefaults() {
        Defaults[.userId] = nil
        Defaults[.authenticationToken] = nil
        Defaults[.email] = nil
    }
}
