//
//  LocalUser.swift
//  Mooch
//
//  Created by adam on 9/7/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import SwiftyJSON

struct LocalUser {
    
    var user: User
    let hashedPassword: String
    let salt: String
    
    //Designated initializer
    init(user: User, hashedPassword: String, salt: String) {
        self.user = user
        self.hashedPassword = hashedPassword
        self.salt = salt
    }
    
    //Convenience JSON initializer
    init(userJSON: JSON, hashedPassword: String, salt: String) throws {
        let user = try User(json: userJSON)
        self.init(user: user, hashedPassword: hashedPassword, salt: salt)
    }
}