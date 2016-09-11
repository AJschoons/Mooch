//
//  Listing.swift
//  Mooch
//
//  Created by adam on 9/11/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import SwiftyJSON

struct Listing {
    
    enum JSONMapping: String {
        case Id = "id"
        case Title = "title"
        case Price = "price"
        case IsAvailable = "is_available"
        case Owner = "owner"
        case Community = "community"
        case Tag = "tag"
    }
    
    let id: Int
    var title: String
    var price: Float
    var isAvailable: Bool
    
    let owner: User
    var community: Community
    var tag: ListingTag
    
    //Designated initializer
    init(id: Int, title: String, price: Float, isAvailable: Bool, owner: User, community: Community, tag: ListingTag) {
        self.id = id
        self.title = title
        self.price = price
        self.owner = owner
        self.community = community
        self.tag = tag
        self.isAvailable = isAvailable
    }
    
    //Convenience JSON initializer
    init(json: JSON) throws {
        guard let id = json[JSONMapping.Id.rawValue].int, title = json[JSONMapping.Title.rawValue].string, price = json[JSONMapping.Price.rawValue].float, isAvailable = json[JSONMapping.IsAvailable.rawValue].bool where json[JSONMapping.Owner.rawValue].isExists() && json[JSONMapping.Community.rawValue].isExists() && json[JSONMapping.Tag.rawValue].isExists() else {
            throw InitializationError.InsufficientJSONInformationForInitialization
        }
        
        let owner = try User(json: JSON(json[JSONMapping.Owner.rawValue].object))
        let community = try Community(json: JSON(json[JSONMapping.Community.rawValue].object))
        let tag = try ListingTag(json: JSON(json[JSONMapping.Tag.rawValue].object))
        
        self.init(id: id, title: title, price: price, isAvailable: isAvailable, owner: owner, community: community, tag: tag)
    }
}
