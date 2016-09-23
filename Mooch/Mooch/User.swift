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
        case rating = "rating"
        case community = "community"
    }
    
    struct ContactInformation {
        var address: String?
        let email: String
        var phone: String?
    }
    
    let id: Int
    var name: String
    var contactInformation: ContactInformation
    var rating: Float?
    
    var community: Community
    
    //Designated initializer
    init(id: Int, name: String, contactInformation: ContactInformation, rating: Float?, community: Community) {
        self.id = id
        self.name = name
        self.contactInformation = contactInformation
        self.community = community
    }
    
    //Convenience JSON initializer
    init(json: JSON) throws {
        guard let id = json[JSONMapping.id.rawValue].int, let name = json[JSONMapping.name.rawValue].string, let email = json[JSONMapping.email.rawValue].string, json[JSONMapping.community.rawValue].exists() else {
            throw InitializationError.insufficientJSONInformationForInitialization
        }
        
        let rating = json[JSONMapping.rating.rawValue].float
        
        let address = json[JSONMapping.address.rawValue].string
        let phone = json[JSONMapping.phone.rawValue].string
        let contactInformation = ContactInformation(address: address, email: email, phone: phone)
        let community = try Community(json: JSON(json["community"].object))
        
        self.init(id: id, name: name, contactInformation: contactInformation, rating: rating, community: community)
    }
    
    static func createDummy(fromNumber i: Int) -> User {
        let phoneString = "555-555-5555"
        let rating: Float = 3.5 * 1.2164
        let contactInformation = ContactInformation(address: "Apt #\(i)", email: "\(i)@example.com", phone: phoneString)
        let community = Community.createDummy(fromNumber: i)
        return User(id: i, name: "User \(i)", contactInformation: contactInformation, rating: rating, community: community)
    }
}
