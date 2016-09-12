//
//  ListingTag.swift
//  Mooch
//
//  Created by adam on 9/7/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import SwiftyJSON

struct ListingTag {
    
    enum JSONMapping: String {
        case Id = "id"
        case Name = "name"
    }
    
    let id: Int
    let name: String
    
    //Designated initializer
    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
    
    //Convenience JSON initializer
    init(json: JSON) throws {
        guard let id = json[JSONMapping.Id.rawValue].int, name = json[JSONMapping.Name.rawValue].string else {
            throw InitializationError.InsufficientJSONInformationForInitialization
        }
        
        self.init(id: id, name: name)
    }
    
    static func createDummy(fromNumber i: Int) -> ListingTag {
        return ListingTag(id: i, name: "Tag\(i)")
    }
}