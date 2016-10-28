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
        case quantity
        case categoryId
        case isAvailable
        case createdAt
        case pictureURL
        case thumbnailPictureURL
        case communityId
        case owner
        case exchanges
    }
    
    enum JSONMapping: String {
        case id = "id"
        case title = "title"
        case description = "detail"
        case price = "price"
        case isFree = "free"
        case quantity = "quantity"
        case categoryId = "category_id"
        case isAvailable = "available"
        case createdAt = "created_at"
        case modifiedAt = "modified_at"
        case tags = "tags"
        case pictureURL = "image_url"
        case thumbnailPictureURL = "thumbnail_image_url"
        case communityId = "community_id"
        case owner = "user"
        case exchanges = "exchanges"
    }
    
    let id: Int
    var photo: UIImage?
    var title: String
    var description: String?
    var price: Float
    var isFree: Bool
    var quantity: Int
    var categoryId: Int
    var isAvailable: Bool
    var createdAt: Date
    var modifiedAt: Date?
    var pictureURL: String
    var thumbnailPictureURL: String
    let communityId: Int
    let owner: User
    var exchanges: [Exchange]
    
    private(set) var interestedBuyers = [User]()
    
    var priceString: String {
        guard price > 0.009 else {
            return "Free"
        }
        return "$" + String(format: "%.2f", price)
    }
    
    var daysSincePostedString: String {
        let numberOfDaysSincePosted = daysFromTodaySince(previousDate: createdAt)
        let daysText = numberOfDaysSincePosted > 1 ? "days" : "day"
        return "\(numberOfDaysSincePosted) \(daysText) ago"
    }
    
    func isOwnerContactedBy(by userToCheck: User) -> Bool {
        return interestedBuyers.contains(where: {$0.id == userToCheck.id})
    }
    
    func isUserContactInformationVisible(to userToCheck: User) -> Bool {
        return exchanges.contains(where: {$0.buyer.id == userToCheck.id && $0.sellerAccepted})
    }
    
    //Returns true when a listing has been completed
    func isCompleted() -> Bool {
        return exchanges.contains(where: {$0.sellerAccepted})
    }
    
    mutating func addInterestedBuyer(_ user: User) {
        guard !interestedBuyers.contains(where: {$0.id == user.id}) else { return }
        interestedBuyers.append(user)
    }
    
    mutating func accept(exchange: Exchange) {
        guard let acceptedExchangeIndex =  exchanges.index(where: {$0.id == exchange.id}) else { return }
        var acceptedExchange = exchanges[acceptedExchangeIndex]
        acceptedExchange.sellerAccepted = true
    }
    
    //Designated initializer
    init(id: Int, photo: UIImage?, title: String, description: String?, price: Float, isFree: Bool, quantity: Int, categoryId: Int, isAvailable: Bool, createdAt: Date, modifiedAt: Date?, owner: User, pictureURL: String, thumbnailPictureURL: String, communityId: Int, exchanges: [Exchange]) {
        self.id = id
        self.photo = photo
        self.title = title
        self.description = description
        self.price = price
        self.isFree = isFree
        self.quantity = quantity
        self.categoryId = categoryId
        self.isAvailable = isAvailable
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        self.owner = owner
        self.pictureURL = pictureURL
        self.thumbnailPictureURL = thumbnailPictureURL
        self.communityId = communityId
        
        self.exchanges = exchanges
        self.interestedBuyers = self.exchanges.map({$0.buyer})
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
        guard let quantity = json[JSONMapping.quantity.rawValue].int else { throw JSONInitializationError.quantity }
        guard let categoryId = json[JSONMapping.categoryId.rawValue].int else { throw JSONInitializationError.categoryId }
        guard let isAvailable = json[JSONMapping.isAvailable.rawValue].bool else { throw JSONInitializationError.isAvailable }
        guard let createdAtString = json[JSONMapping.createdAt.rawValue].string else { throw JSONInitializationError.createdAt }
        guard let pictureURL = json[JSONMapping.pictureURL.rawValue].string else { throw JSONInitializationError.pictureURL }
        guard let communityId = json[JSONMapping.communityId.rawValue].int else { throw JSONInitializationError.communityId }
        guard json[JSONMapping.owner.rawValue].exists() else { throw JSONInitializationError.owner }
        guard let exchangesJSON = json[JSONMapping.exchanges.rawValue].array else { throw JSONInitializationError.exchanges }
        
        let createdAt = date(fromAPITimespamp: createdAtString)
        let owner = try User(json: JSON(json[JSONMapping.owner.rawValue].object))
        let exchanges = try exchangesJSON.map({try Exchange(json: $0)})
        
        //If the thumbnail URL isn't present then default to the pictureURL
        var thumbnailPictureURL = pictureURL
        if let thumbnailURL = json[JSONMapping.thumbnailPictureURL.rawValue].string {
            thumbnailPictureURL = thumbnailURL
        }
        
        
        //
        //Optional variables
        //
        
        var description = json[JSONMapping.description.rawValue].string
        if description != nil && description!.isEmpty {
            description = nil
        }
        
        var modifiedAt: Date?
        if let modifiedAtString = json[JSONMapping.modifiedAt.rawValue].string {
            modifiedAt = date(fromAPITimespamp: modifiedAtString)
        }
        
        
        //
        //Intialization
        //

        self.init(id: id, photo: nil, title: title, description: description, price: price, isFree: isFree, quantity: quantity, categoryId: categoryId, isAvailable: isAvailable, createdAt: createdAt, modifiedAt: modifiedAt, owner: owner, pictureURL: pictureURL, thumbnailPictureURL: thumbnailPictureURL, communityId: communityId, exchanges: exchanges)
    }
    
//    static func createDummy(fromNumber i: Int) -> Listing {
//        let photo = UIImage(named: "apples")
//        let description = "This is some text that describes what the listing is but that will hopefully be more useful than this decription specifically"
//        let price = Float(i % 100) * 1.68723
//        let owner = User.createDummy(fromNumber: i)
//        
//        return Listing(id: i, photo: photo, title: "Listing \(i)", description: description, price: price, isFree: false, quantity: i, categoryId: i, isAvailable: true, createdAt: Date(), modifiedAt: nil, owner: owner, pictureURL: "http://placehold.it/500x500", thumbnailPictureURL: "http://placehold.it/100x100", communityId: i)
//    }
}
