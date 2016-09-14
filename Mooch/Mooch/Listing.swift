//
//  Listing.swift
//  Mooch
//
//  Created by adam on 9/11/16.
//  Copyright © 2016 cse498. All rights reserved.
//



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
    
    var priceString: String {
        return "$" + String(format: "%.2f", price)
    }
    
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
        guard let id = json[JSONMapping.Id.rawValue].int, let title = json[JSONMapping.Title.rawValue].string, let price = json[JSONMapping.Price.rawValue].float, let isAvailable = json[JSONMapping.IsAvailable.rawValue].bool , json[JSONMapping.Owner.rawValue].exists() && json[JSONMapping.Community.rawValue].exists() && json[JSONMapping.Tag.rawValue].exists() else {
            throw InitializationError.insufficientJSONInformationForInitialization
        }
        
        let owner = try User(json: JSON(json[JSONMapping.Owner.rawValue].object))
        let community = try Community(json: JSON(json[JSONMapping.Community.rawValue].object))
        let tag = try ListingTag(json: JSON(json[JSONMapping.Tag.rawValue].object))
        
        self.init(id: id, title: title, price: price, isAvailable: isAvailable, owner: owner, community: community, tag: tag)
    }
    
    static func createDummy(fromNumber i: Int) -> Listing {
        let price = Float(i % 100) * 1.68723
        let owner = User.createDummy(fromNumber: i)
        let community = Community.createDummy(fromNumber: i)
        let tag = ListingTag.createDummy(fromNumber: i)
        return Listing(id: i, title: "Listing \(i)", price: price, isAvailable: true, owner: owner, community: community, tag: tag)
    }
}
