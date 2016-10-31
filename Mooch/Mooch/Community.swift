//
//  Community.swift
//  Mooch
//
//  Created by adam on 9/6/16.
//  Copyright © 2016 cse498. All rights reserved.
//

struct Community {
    
    //The required data for JSON initialization
    enum JSONInitializationError: Error {
        case id
        case address
        case name
        case pictureURL
    }
    
    enum JSONMapping: String {
        case id = "id"
        case address = "address"
        case name = "name"
        case pictureURL = "image_url"
    }
    
    let id: Int
    let address: String
    let name: String
    let pictureURL: String
    
    //Designated initializer
    init(id: Int, address: String, name: String, pictureURL: String) {
        self.id = id
        self.address = address
        self.name = name
        self.pictureURL = pictureURL
    }
    
    //Convenience JSON initializer
    init(json: JSON) throws {
        guard let id = json[JSONMapping.id.rawValue].int else { throw JSONInitializationError.id }
        guard let address = json[JSONMapping.address.rawValue].string else { throw JSONInitializationError.address }
        guard let name = json[JSONMapping.name.rawValue].string else { throw JSONInitializationError.name }
        guard let pictureURL = json[JSONMapping.pictureURL.rawValue].string else { throw JSONInitializationError.pictureURL }
        
        self.init(id: id, address: address, name: name, pictureURL: pictureURL)
    }
    
    static func createDummy(fromNumber i: Int) -> Community {
        return Community(id: i, address: "\(i) Main St.", name: "\(i) Big Apartments", pictureURL: "http://placehold.it/500x500")
    }
}
