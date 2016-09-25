//
//  ListingTag.swift
//  Mooch
//
//  Created by adam on 9/7/16.
//  Copyright © 2016 cse498. All rights reserved.
//



struct ListingTag {
    
    enum JSONMapping: String {
        case id = "id"
        case name = "name"
        case count = "taggings_count"
    }
    
    let id: Int
    let name: String
    let count: Int
    
    //Designated initializer
    init(id: Int, name: String, count: Int) {
        self.id = id
        self.name = name
        self.count = count
    }
    
    //Convenience JSON initializer
    init(json: JSON) throws {
        guard let id = json[JSONMapping.id.rawValue].int, let name = json[JSONMapping.name.rawValue].string, let count = json[JSONMapping.count.rawValue].int else {
            throw InitializationError.insufficientJSONInformationForInitialization
        }
        
        self.init(id: id, name: name, count: count)
    }
    
    static func createDummy(fromNumber i: Int) -> ListingTag {
        return ListingTag(id: i, name: "Tag\(i)", count: i)
    }
}
