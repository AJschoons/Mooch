//
//  ListingTag.swift
//  Mooch
//
//  Created by adam on 9/7/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import SwiftyJSON

struct ListingTag {
    
    let id: Int
    let name: String
    
    //Designated initializer
    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
    
    //Convenience JSON initializer
    init(json: JSON) throws {
        guard let id = json["id"].int, name = json["name"].string else {
            throw InitializationError.InsufficientJSONInformationForInitialization
        }
        
        self.init(id: id, name: name)
    }
}