//
//  Exchange.swift
//  Mooch
//
//  Created by adam on 10/26/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import Foundation

struct Exchange {
    
    //The required data for JSON initialization
    enum JSONInitializationError: Error {
        case id
        case listingId
        case sellerUserId
        case buyerUserId
        case sellerAccepted
        case buyer
        case createdAt
    }
    
    enum JSONMapping: String {
        case id = "id"
        case listingId = "listing_id"
        case sellerUserId = "user_id"
        case buyerUserId = "buyer_id"
        case sellerAccepted = "completed"
        case buyer = "buyer"
        case createdAt = "created_at"
    }
    
    let id: Int
    let listingId: Int
    let sellerUserId: Int
    let buyerUserId: Int
    let createdAt: Date
    
    var sellerAccepted: Bool
    let buyer: User
    
    //Designated initializer
    init(id: Int, listingId: Int, sellerUserId: Int, buyerUserId: Int, sellerAccepted: Bool, buyer: User, createdAt: Date) {
        self.id = id
        self.listingId = listingId
        self.sellerUserId = sellerUserId
        self.buyerUserId = buyerUserId
        self.sellerAccepted = sellerAccepted
        self.buyer = buyer
        self.createdAt = createdAt
    }
    
    //Convenience JSON initializer
    init(json: JSON) throws {
        guard let id = json[JSONMapping.id.rawValue].int else { throw JSONInitializationError.id }
        guard let listingId = json[JSONMapping.listingId.rawValue].int else { throw JSONInitializationError.listingId }
        guard let sellerUserId = json[JSONMapping.sellerUserId.rawValue].int else { throw JSONInitializationError.sellerUserId }
        guard let buyerUserId = json[JSONMapping.buyerUserId.rawValue].int else { throw JSONInitializationError.buyerUserId }
        guard let sellerAccepted = json[JSONMapping.sellerAccepted.rawValue].bool else { throw JSONInitializationError.sellerAccepted }
        guard let createdAtString = json[JSONMapping.createdAt.rawValue].string else { throw JSONInitializationError.createdAt }
        guard json[JSONMapping.buyer.rawValue].exists() else { throw JSONInitializationError.buyer }
        
        let createdAt = date(fromAPITimespamp: createdAtString)
        
        let buyer = try User(json: JSON(json[JSONMapping.buyer.rawValue].object))
        
        self.init(id: id, listingId: listingId, sellerUserId: sellerUserId, buyerUserId: buyerUserId, sellerAccepted: sellerAccepted, buyer: buyer, createdAt: createdAt)
    }
}
