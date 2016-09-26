//
//  User.swift
//  Mooch
//
//  Created by adam on 9/6/16.
//  Copyright © 2016 cse498. All rights reserved.
//

struct User {
    
    enum JSONMapping: String {
        case id = "id"
        case name = "name"
        case address = "address"
        case email = "email"
        case phone = "phone"
        case currentRating = "current_rating"
        case ratingCount = "rating_count"
        case community = "community"
        case password = "password"
        case passwordDigest = "password_digest"
        case authenticationToken = "authentication_token"
        case pictureURL = "profile_pic"
        case thumbnailPictureURL = "profile_pic_small"
    }
    
    struct ContactInformation {
        var address: String?
        let email: String
        var phone: String?
    }
    
    struct LoginInformation {
        var password: String?
        var passwordDigest: String?
        var authenticationToken: String?
    }
    
    let id: Int
    var name: String
    var contactInformation: ContactInformation
    var currentRating: Float
    var ratingCount: Int
    
    //Optional
    var community: Community?
    var loginInformation: LoginInformation?
    var pictureURL: String?
    var thumbnailPictureURL: String?
    
    //Designated initializer
    init(id: Int, name: String, contactInformation: ContactInformation, currentRating: Float, ratingCount: Int, community: Community?, loginInformation: LoginInformation?, pictureURL: String?, thumbnailPictureURL: String?) {
        self.id = id
        self.name = name
        self.contactInformation = contactInformation
        self.currentRating = currentRating
        self.ratingCount = ratingCount
        
        self.community = community
        self.loginInformation = loginInformation
        self.pictureURL = pictureURL
        self.thumbnailPictureURL = thumbnailPictureURL
    }
    
    //Convenience JSON initializer
    init(json: JSON) throws {
        guard let id = json[JSONMapping.id.rawValue].int, let name = json[JSONMapping.name.rawValue].string, let email = json[JSONMapping.email.rawValue].string, let currentRating = json[JSONMapping.currentRating.rawValue].float, let ratingCount = json[JSONMapping.ratingCount.rawValue].int else {
            throw InitializationError.insufficientJSONInformationForInitialization
        }
        
        //Setup contact information
        let address = json[JSONMapping.address.rawValue].string
        let phone = json[JSONMapping.phone.rawValue].string
        let contactInformation = ContactInformation(address: address, email: email, phone: phone)
        
        var community: Community?
        if json[JSONMapping.community.rawValue].exists() {
            community = try Community(json: JSON(json[JSONMapping.community.rawValue].object))
        }
        
        //Setup login information
        var loginInformation: LoginInformation?
        let isLoginInformation = json[JSONMapping.password.rawValue].exists() || json[JSONMapping.passwordDigest.rawValue].exists() || json[JSONMapping.authenticationToken.rawValue].exists()
        if isLoginInformation {
            let password = json[JSONMapping.password.rawValue].string
            let passwordDigest = json[JSONMapping.passwordDigest.rawValue].string
            let authenticationToken = json[JSONMapping.authenticationToken.rawValue].string
            loginInformation = LoginInformation(password: password, passwordDigest: passwordDigest, authenticationToken: authenticationToken)
        }
        
        let pictureURL = json[JSONMapping.pictureURL.rawValue].string
        let thumbnailPictureURL = json[JSONMapping.thumbnailPictureURL.rawValue].string
        
        self.init(id: id, name: name, contactInformation: contactInformation, currentRating: currentRating, ratingCount: ratingCount, community: community, loginInformation: loginInformation, pictureURL: pictureURL, thumbnailPictureURL: thumbnailPictureURL)
    }
    
    static func createDummy(fromNumber i: Int) -> User {
        let phoneString = "555-555-5555"
        let currentRating: Float = 3.5 * 1.2164
        let ratingCount = 23
        let contactInformation = ContactInformation(address: "Apt #\(i)", email: "\(i)@example.com", phone: phoneString)
        let community = Community.createDummy(fromNumber: i)
        return User(id: i, name: "User \(i)", contactInformation: contactInformation, currentRating: currentRating, ratingCount: ratingCount, community: community, loginInformation: nil, pictureURL: "http://placehold.it/500x500", thumbnailPictureURL: "http://placehold.it/100x100")
    }
}
