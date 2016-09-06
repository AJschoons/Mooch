//
//  Community.swift
//  Mooch
//
//  Created by adam on 9/6/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Community {
    
    let id: Int
    let address: String
    let name: String
    
    init(json: JSON) throws {
        guard let id = json["id"].int, address = json["address"].string, name = json["name"].string else {
            throw InitializationError.InsufficientJSONInformationForInitialization
        }
        
        self.id = id
        self.address = address
        self.name = name
    }
}