//
//  LocalUser.swift
//  Mooch
//
//  Created by adam on 9/7/16.
//  Copyright © 2016 cse498. All rights reserved.
//


class LocalUser {
    
    //The required data for JSON initialization
    enum JSONInitializationError: Error {
        case token
    }
    
    enum JSONMapping: String {
        case authenticationToken = "authentication_token"
    }
    
    private(set) var user: User
    let authenticationToken: String
    
    func changeUser(to user: User) {
        self.user = user
    }
    
    //Designated initializer
    init(user: User, authenticationToken: String) {
        self.user = user
        self.authenticationToken = authenticationToken
    }
    
    //Convenience JSON initializer
    convenience init(json: JSON) throws {
        guard let authenticationToken = json[JSONMapping.authenticationToken.rawValue].string else {
            throw JSONInitializationError.token
        }
        
        let user = try User(json: json)
        
        self.init(user: user, authenticationToken: authenticationToken)
    }
}
