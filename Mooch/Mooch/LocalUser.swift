//
//  LocalUser.swift
//  Mooch
//
//  Created by adam on 9/7/16.
//  Copyright © 2016 cse498. All rights reserved.
//



struct LocalUser {
    
    var user: User
    let password: String
    
    //Designated initializer
    init(user: User, password: String) {
        self.user = user
        self.password = password
    }
    
    //Convenience JSON initializer
    init(userJSON: JSON, password: String) throws {
        let user = try User(json: userJSON)
        self.init(user: user, password: password)
    }
}
