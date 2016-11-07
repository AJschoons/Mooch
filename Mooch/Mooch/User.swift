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
        case communityId
    }
    
    enum JSONMapping: String {
        case id = "id"
        case name = "name"
        case address = "address"
        case email = "email"
        case phone = "phone"
        case communityId = "community_id"
        case pictureURL = "profile_image_url"
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
    private(set) var communityId: Int
    
    //Optional
    var pictureURL: String?
    var thumbnailPictureURL: String?
    
    mutating func changeCommunityId(to id: Int) {
        self.communityId = id
    }
    
    //Designated initializer
    init(id: Int, name: String, contactInformation: ContactInformation, communityId: Int, pictureURL: String?, thumbnailPictureURL: String?) {
        self.id = id
        self.name = name
        self.contactInformation = contactInformation
        self.communityId = communityId
        
        //If either of the URLs provided are nil, then default it to the non-nil one
        if pictureURL == nil || thumbnailPictureURL == nil {
            var urlToUse: String?
            if pictureURL != nil {
                urlToUse = pictureURL
            } else if thumbnailPictureURL != nil {
                urlToUse = thumbnailPictureURL
            }
            self.pictureURL = urlToUse
            self.thumbnailPictureURL = urlToUse
        } else {
            self.pictureURL = pictureURL
            self.thumbnailPictureURL = thumbnailPictureURL
        }
    }
    
    //Convenience JSON initializer
    init(json: JSON) throws {
        
        //
        //Required variables
        //
        
        guard let id = json[JSONMapping.id.rawValue].int else { throw JSONInitializationError.id }
        guard let name = json[JSONMapping.name.rawValue].string else { throw JSONInitializationError.name }
        guard let email = json[JSONMapping.email.rawValue].string else { throw JSONInitializationError.email }
        guard let communityId = json[JSONMapping.communityId.rawValue].int else { throw JSONInitializationError.communityId }
        
        
        //
        //Optional variables
        //
        
        var pictureURL = json[JSONMapping.pictureURL.rawValue].string
        if pictureURL != nil && pictureURL!.isEmpty {
            pictureURL = nil
        }
        
        var thumbnailPictureURL = json[JSONMapping.thumbnailPictureURL.rawValue].string
        if thumbnailPictureURL != nil && thumbnailPictureURL!.isEmpty {
            thumbnailPictureURL = nil
        }
        
        
        //
        //Setup contact information
        //
        
        var address = json[JSONMapping.address.rawValue].string
        if address != nil && address!.isEmpty {
            address = nil
        }
        
        var phone = json[JSONMapping.phone.rawValue].string
        if phone != nil && phone!.isEmpty {
            phone = nil
        }
        
        let contactInformation = ContactInformation(address: address, email: email, phone: phone)
        
        
        //
        //Initializtion
        //
        
        self.init(id: id, name: name, contactInformation: contactInformation, communityId: communityId, pictureURL: pictureURL, thumbnailPictureURL: thumbnailPictureURL)
    }
    
    static func createDummy(fromNumber i: Int) -> User {
        let phoneString = "555-555-5555"
        let contactInformation = ContactInformation(address: "Apt #\(i)", email: "\(i)@example.com", phone: phoneString)
        return User(id: i, name: "User \(i)", contactInformation: contactInformation, communityId: i, pictureURL: "http://placehold.it/500x500", thumbnailPictureURL: "http://placehold.it/100x100")
    }
}
