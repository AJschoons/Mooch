//
//  User.swift
//  Mooch
//
//  Created by adam on 9/6/16.
//  Copyright © 2016 cse498. All rights reserved.
//

struct User {
    
    //The required data for JSON initialization
    enum JSONInitializationError: Error {
        case id
        case name
        case email
        case currentRating
        case ratingCount
        case communityId
    }
    
    enum JSONMapping: String {
        case id = "id"
        case name = "name"
        case address = "address"
        case email = "email"
        case phone = "phone"
        case currentRating = "current_rating"
        case ratingCount = "rating_count"
        case communityId = "community_id"
        case pictureURL = "profile_pic"
        case thumbnailPictureURL = "profile_pic_small"
    }
    
    struct ContactInformation {
        var address: String?
        let email: String
        var phone: String?
    }
    
    let id: Int
    var name: String
    var contactInformation: ContactInformation
    var currentRating: Float
    var ratingCount: Int
    let communityId: Int
    
    //Optional
    var pictureURL: String?
    var thumbnailPictureURL: String?
    
    //Designated initializer
    init(id: Int, name: String, contactInformation: ContactInformation, currentRating: Float, ratingCount: Int, communityId: Int, pictureURL: String?, thumbnailPictureURL: String?) {
        self.id = id
        self.name = name
        self.contactInformation = contactInformation
        self.currentRating = currentRating
        self.ratingCount = ratingCount
        self.communityId = communityId
        
        self.pictureURL = pictureURL
        self.thumbnailPictureURL = thumbnailPictureURL
    }
    
    //Convenience JSON initializer
    init(json: JSON) throws {
        
        //
        //Required variables
        //
        
        guard let id = json[JSONMapping.id.rawValue].int else { throw JSONInitializationError.id }
        guard let name = json[JSONMapping.name.rawValue].string else { throw JSONInitializationError.name }
        guard let email = json[JSONMapping.email.rawValue].string else { throw JSONInitializationError.email }
        guard let currentRating = json[JSONMapping.currentRating.rawValue].float else { throw JSONInitializationError.currentRating }
        guard let ratingCount = json[JSONMapping.ratingCount.rawValue].int else { throw JSONInitializationError.ratingCount }
        guard let communityId = json[JSONMapping.communityId.rawValue].int else { throw JSONInitializationError.communityId }
        
        
        //
        //Optional variables
        //
        
        let pictureURL = json[JSONMapping.pictureURL.rawValue].string
        let thumbnailPictureURL = json[JSONMapping.thumbnailPictureURL.rawValue].string
        
        //Setup contact information
        let address = json[JSONMapping.address.rawValue].string
        let phone = json[JSONMapping.phone.rawValue].string
        let contactInformation = ContactInformation(address: address, email: email, phone: phone)
        
        
        //
        //Initializtion
        //
        
        self.init(id: id, name: name, contactInformation: contactInformation, currentRating: currentRating, ratingCount: ratingCount, communityId: communityId, pictureURL: pictureURL, thumbnailPictureURL: thumbnailPictureURL)
    }
    
    static func createDummy(fromNumber i: Int) -> User {
        let phoneString = "555-555-5555"
        let currentRating: Float = 3.5 * 1.2164
        let ratingCount = 23
        let contactInformation = ContactInformation(address: "Apt #\(i)", email: "\(i)@example.com", phone: phoneString)
        return User(id: i, name: "User \(i)", contactInformation: contactInformation, currentRating: currentRating, ratingCount: ratingCount, communityId: i, pictureURL: "http://placehold.it/500x500", thumbnailPictureURL: "http://placehold.it/100x100")
    }
}
