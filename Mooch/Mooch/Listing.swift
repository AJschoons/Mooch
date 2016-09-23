//
//  Listing.swift
//  Mooch
//
//  Created by adam on 9/11/16.
//  Copyright © 2016 cse498. All rights reserved.
//



struct Listing {
    
    enum JSONMapping: String {
        case id = "id"
        case title = "title"
        case description = "description"
        case price = "price"
        case isAvailable = "available"
        case owner = "user"
        case community = "community"
        case tags = "tags"
    }
    
    let id: Int
    var title: String
    var description: String
    var price: Float
    var isAvailable: Bool
    
    let owner: User
    var community: Community
    var tags: [String]
    
    var priceString: String {
        return "$" + String(format: "%.2f", price)
    }
    
    //Designated initializer
    init(id: Int, title: String, description: String, price: Float, isAvailable: Bool, owner: User, community: Community, tags: [String]) {
        self.id = id
        self.title = title
        self.description = description
        self.price = price
        self.owner = owner
        self.community = community
        self.tags = tags
        self.isAvailable = isAvailable
    }
    
    //Convenience JSON initializer
    init(json: JSON) throws {
        guard let id = json[JSONMapping.id.rawValue].int, let title = json[JSONMapping.title.rawValue].string, let description = json[JSONMapping.description.rawValue].string, let price = json[JSONMapping.price.rawValue].float, let isAvailable = json[JSONMapping.isAvailable.rawValue].bool , json[JSONMapping.owner.rawValue].exists() && json[JSONMapping.community.rawValue].exists() && json[JSONMapping.tags.rawValue].exists() else {
            throw InitializationError.insufficientJSONInformationForInitialization
        }
        
        let owner = try User(json: JSON(json[JSONMapping.owner.rawValue].object))
        let community = try Community(json: JSON(json[JSONMapping.community.rawValue].object))
        
        //let tag = try ListingTag(json: JSON(json[JSONMapping.tags.rawValue].object))
        let tagsArray = json[JSONMapping.tags.rawValue].arrayValue
        let tags = tagsArray.map({$0.stringValue})
        
        self.init(id: id, title: title, description: description, price: price, isAvailable: isAvailable, owner: owner, community: community, tags: tags)
    }
    
    static func createDummy(fromNumber i: Int) -> Listing {
        let description = "This is some text that describes what the listing is but that will hopefully be more useful than this decription specifically"
        let price = Float(i % 100) * 1.68723
        let owner = User.createDummy(fromNumber: i)
        let community = Community.createDummy(fromNumber: i)
        let tags = ["SomeTagName"]
        return Listing(id: i, title: "Listing \(i)", description: description, price: price, isAvailable: true, owner: owner, community: community, tags: tags)
    }
}
