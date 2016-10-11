//
//  LocalUser.swift
//  Mooch
//
//  Created by adam on 9/7/16.
//  Copyright © 2016 cse498. All rights reserved.
//


struct LocalUser {
    
    //The required data for JSON initialization
    enum JSONInitializationError: Error {
        case token
    }
    
    enum JSONMapping: String {
        case authenticationToken = "authentication_token"
    }
    
    var user: User
    let authenticationToken: String
    
    //Designated initializer
    init(user: User, authenticationToken: String) {
        self.user = user
        self.authenticationToken = authenticationToken
    }
    
    //Convenience JSON initializer
    init(json: JSON) throws {
        guard let authenticationToken = json[JSONMapping.authenticationToken.rawValue].string else {
            throw JSONInitializationError.token
        }
        
        let user = try User(json: json)
        
        self.init(user: user, authenticationToken: authenticationToken)
    }
}
