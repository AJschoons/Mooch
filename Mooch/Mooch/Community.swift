//
//  Community.swift
//  Mooch
//
//  Created by adam on 9/6/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import SwiftyJSON

struct Community {
    
    let id: Int
    let address: String
    let name: String
    
    //Designated initializer
    init(id: Int, address: String, name: String) {
        self.id = id
        self.address = address
        self.name = name
    }
    
    //Convenience JSON initializer
    init(json: JSON) throws {
        guard let id = json["id"].int, address = json["address"].string, name = json["name"].string else {
            throw InitializationError.InsufficientJSONInformationForInitialization
        }
        
        self.init(id: id, address: address, name: name)
    }
}
