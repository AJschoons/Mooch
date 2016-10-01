//
//  Listing.swift
//  Mooch
//
//  Created by adam on 9/11/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

struct Listing {
    
    //The required data for JSON initialization
    enum JSONInitializationError: Error {
        case id
        case title
        case price
        case isFree
        case categoryId
        case isAvailable
        case createdAt
        case pictureURL
        case thumbnailPictureURL
        case communityId
        case owner
    }
    
    enum JSONMapping: String {
        case id = "id"
        case title = "title"
        case description = "detail"
        case price = "price"
        case isFree = "free"
        case categoryId = "category_id"
        case isAvailable = "available"
        case createdAt = "created_at"
        case modifiedAt = "modified_at"
        case tags = "tags"
        case pictureURL = "profile_pic"
        case thumbnailPictureURL = "profile_pic_small"
        case communityId = "community_id"
        case owner = "user"
    }
    
    let id: Int
    var photo: UIImage?
    var title: String
    var description: String?
    var price: Float
    var isFree: Bool
    var categoryId: Int
    var isAvailable: Bool
    var createdAt: Date
    var modifiedAt: Date?
    var pictureURL: String
    var thumbnailPictureURL: String
    let communityId: Int
    let owner: User
    
    var priceString: String {
        return "$" + String(format: "%.2f", price)
    }
    
    //Designated initializer
    init(id: Int, photo: UIImage?, title: String, description: String?, price: Float, isFree: Bool, categoryId: Int, isAvailable: Bool, createdAt: Date, modifiedAt: Date?, owner: User, pictureURL: String, thumbnailPictureURL: String, communityId: Int) {
        self.id = id
        self.photo = photo
        self.title = title
        self.description = description
        self.price = price
        self.isFree = isFree
        self.categoryId = categoryId
        self.isAvailable = isAvailable
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        self.owner = owner
        self.pictureURL = pictureURL
        self.thumbnailPictureURL = thumbnailPictureURL
        self.communityId = communityId
    }
    
    //Convenience JSON initializer
    init(json: JSON) throws {
        
        //
        //Required variables
        //
        
        guard let id = json[JSONMapping.id.rawValue].int else { throw JSONInitializationError.id }
        guard let title = json[JSONMapping.title.rawValue].string else { throw JSONInitializationError.title }
        guard let price = json[JSONMapping.price.rawValue].float else { throw JSONInitializationError.price }
        guard let isFree = json[JSONMapping.isFree.rawValue].bool else { throw JSONInitializationError.isFree }
        guard let categoryId = json[JSONMapping.categoryId.rawValue].int else { throw JSONInitializationError.categoryId }
        guard let isAvailable = json[JSONMapping.isAvailable.rawValue].bool else { throw JSONInitializationError.isAvailable }
        guard let createdAtString = json[JSONMapping.createdAt.rawValue].string else { throw JSONInitializationError.createdAt }
        guard let pictureURL = json[JSONMapping.pictureURL.rawValue].string else { throw JSONInitializationError.pictureURL }
        guard let thumbnailPictureURL = json[JSONMapping.thumbnailPictureURL.rawValue].string else { throw JSONInitializationError.thumbnailPictureURL }
        guard let communityId = json[JSONMapping.communityId.rawValue].int else { throw JSONInitializationError.communityId }
        guard json[JSONMapping.owner.rawValue].exists() else { throw JSONInitializationError.owner }
        
        let createdAt = date(fromAPITimespamp: createdAtString)
        let owner = try User(json: JSON(json[JSONMapping.owner.rawValue].object))
        
        
        //
        //Optional variables
        //
        
        let description = json[JSONMapping.description.rawValue].string
        
        var modifiedAt: Date?
        if let modifiedAtString = json[JSONMapping.modifiedAt.rawValue].string {
            modifiedAt = date(fromAPITimespamp: modifiedAtString)
        }
        
        
        //
        //Intialization
        //

        self.init(id: id, photo: nil, title: title, description: description, price: price, isFree: isFree, categoryId: categoryId, isAvailable: isAvailable, createdAt: createdAt, modifiedAt: modifiedAt, owner: owner, pictureURL: pictureURL, thumbnailPictureURL: thumbnailPictureURL, communityId: communityId)
    }
    
    static func createDummy(fromNumber i: Int) -> Listing {
        let photo = UIImage(named: "apples")
        let description = "This is some text that describes what the listing is but that will hopefully be more useful than this decription specifically"
        let price = Float(i % 100) * 1.68723
        let owner = User.createDummy(fromNumber: i)
        
        return Listing(id: i, photo: photo, title: "Listing \(i)", description: description, price: price, isFree: false, categoryId: i, isAvailable: true, createdAt: Date(), modifiedAt: nil, owner: owner, pictureURL: "http://placehold.it/500x500", thumbnailPictureURL: "http://placehold.it/100x100", communityId: i)
    }
}
