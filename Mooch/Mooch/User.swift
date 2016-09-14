//
//  User.swift
//  Mooch
//
//  Created by adam on 9/6/16.
//  Copyright © 2016 cse498. All rights reserved.
//



struct User {
    
    enum JSONMapping: String {
        case Id = "id"
        case Name = "name"
        case Address = "address"
        case Email = "email"
        case Phone = "phone"
        case Rating = "rating"
        case Community = "community"
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
        guard let id = json[JSONMapping.Id.rawValue].int, let name = json[JSONMapping.Name.rawValue].string, let address = json[JSONMapping.Address.rawValue].string, let email = json[JSONMapping.Email.rawValue].string, let phone = json[JSONMapping.Phone.rawValue].string , json[JSONMapping.Community.rawValue].exists() else {
            throw InitializationError.insufficientJSONInformationForInitialization
        }
        
        let rating = json[JSONMapping.Rating.rawValue].float
        
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
