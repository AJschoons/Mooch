//
//  User.swift
//  Mooch
//
//  Created by adam on 9/6/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import SwiftyJSON

struct User {
    
    struct ContactInformation {
        var address: String?
        let email: String
        var phone: String?
    }
    
    let id: Int
    var name: String
    var contactInformation: ContactInformation
    
    var community: Community
    
    //Designated initializer
    init(id: Int, name: String, contactInformation: ContactInformation, community: Community) {
        self.id = id
        self.name = name
        self.contactInformation = contactInformation
        self.community = community
    }
    
    //Convenience JSON initializer
    init(json: JSON) throws {
        guard let id = json["id"].int, name = json["name"].string, email = json["email"].string where json["community"].isExists() else {
            throw InitializationError.InsufficientJSONInformationForInitialization
        }
        
        let contactInformation = ContactInformation(address: json["address"].string, email: email, phone: json["phone"].string)
        let community = try Community(json: JSON(json["community"].object))
        
        self.init(id: id, name: name, contactInformation: contactInformation, community: community)
    }
}