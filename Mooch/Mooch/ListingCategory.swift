//
//  ListingCategory.swift
//  Mooch
//
//  Created by adam on 9/7/16.
//  Copyright © 2016 cse498. All rights reserved.
//

struct ListingCategory {
    
    enum JSONInitializationError: Error {
        case id
        case name
    }
    
    enum JSONMapping: String {
        case id = "id"
        case name = "name"
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
        guard let id = json[JSONMapping.id.rawValue].int else {
            throw JSONInitializationError.id
        }
        
        guard let name = json[JSONMapping.name.rawValue].string else {
            throw JSONInitializationError.name
        }
        
        self.init(id: id, name: name)
    }
    
    static func createDummy(fromNumber i: Int) -> ListingCategory {
        return ListingCategory(id: i, name: "Category\(i)")
    }
}
