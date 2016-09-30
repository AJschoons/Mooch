//
//  Listing.swift
//  Mooch
//
//  Created by adam on 9/11/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

struct Listing {
    
    enum JSONMapping: String {
        case id = "id"
        case title = "title"
        case description = "detail"
        case price = "price"
        case isFree = "free"
        case isAvailable = "available"
        case createdAt = "created_at"
        case modifiedAt = "modified_at"
        case owner = "user"
        case tags = "tags"
        case community = "community"
    }
    
    let id: Int
    var photo: UIImage?
    var title: String
    var description: String?
    var price: Float
    var isFree: Bool
    var isAvailable: Bool
    var createdAt: Date
    var modifiedAt: Date
    let owner: User
    var tags: [ListingTag]
    
    //Optional variables
    var community: Community?
    
    var priceString: String {
        return "$" + String(format: "%.2f", price)
    }
    
    //Designated initializer
    init(id: Int, photo: UIImage?, title: String, description: String?, price: Float, isFree: Bool, isAvailable: Bool, createdAt: Date, modifiedAt: Date, owner: User, tags: [ListingTag], community: Community?) {
        self.id = id
        self.photo = photo
        self.title = title
        self.description = description
        self.price = price
        self.isFree = isFree
        self.isAvailable = isAvailable
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        self.owner = owner
        self.tags = tags
        
        self.community = community
    }
    
    //Convenience JSON initializer
    init(json: JSON) throws {
        guard let id = json[JSONMapping.id.rawValue].int, let title = json[JSONMapping.title.rawValue].string, let price = json[JSONMapping.price.rawValue].float, let isFree = json[JSONMapping.isFree.rawValue].bool, let isAvailable = json[JSONMapping.isAvailable.rawValue].bool, let createdAtString = json[JSONMapping.createdAt.rawValue].string, let modifiedAtString = json[JSONMapping.createdAt.rawValue].string, json[JSONMapping.owner.rawValue].exists() else {
            throw InitializationError.insufficientJSONInformationForInitialization
        }
        
        let description = json[JSONMapping.description.rawValue].string
        
        let createdAt = date(fromAPITimespamp: createdAtString)
        let modifiedAt = date(fromAPITimespamp: modifiedAtString)
        
        let owner = try User(json: JSON(json[JSONMapping.owner.rawValue].object))
        
        var tags = [ListingTag]()
        if json[JSONMapping.tags.rawValue].exists() {
            let tagsArray = json[JSONMapping.tags.rawValue].arrayValue
            tags = try tagsArray.map({try ListingTag(json: $0)})
        }
        
        var community: Community?
        if json[JSONMapping.community.rawValue].exists() {
            community = try Community(json: JSON(json[JSONMapping.community.rawValue].object))
        }
        
        self.init(id: id, photo: nil, title: title, description: description, price: price, isFree: isFree, isAvailable: isAvailable, createdAt: createdAt, modifiedAt: modifiedAt, owner: owner, tags: tags, community: community)
    }
    
    static func createDummy(fromNumber i: Int) -> Listing {
        let photo = UIImage(named: "apples")
        let description = "This is some text that describes what the listing is but that will hopefully be more useful than this decription specifically"
        let price = Float(i % 100) * 1.68723
        let owner = User.createDummy(fromNumber: i)
        let tags = [ListingTag(id: i*312, name: "DummyTag1", count: 12), ListingTag(id: i*312+1, name: "DummyTag2", count: 11)]
        let community = Community.createDummy(fromNumber: i)
        
        return Listing(id: i, photo: photo, title: "Listing \(i)", description: description, price: price, isFree: false, isAvailable: true, createdAt: Date(), modifiedAt: Date(), owner: owner, tags: tags, community: community)
    }
}
