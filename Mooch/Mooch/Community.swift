//
//  Community.swift
//  Mooch
//
//  Created by adam on 9/6/16.
//  Copyright © 2016 cse498. All rights reserved.
//



struct Community {
    
    enum JSONMapping: String {
        case Id = "id"
        case Address = "address"
        case Name = "name"
    }
    
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
        guard let id = json[JSONMapping.Id.rawValue].int, let address = json[JSONMapping.Address.rawValue].string, let name = json[JSONMapping.Name.rawValue].string else {
            throw InitializationError.insufficientJSONInformationForInitialization
        }
        
        self.init(id: id, address: address, name: name)
    }
    
    static func createDummy(fromNumber i: Int) -> Community {
        return Community(id: i, address: "\(i) Main St.", name: "\(i) Big Apartments")
    }
}
