//
//  User.swift
//  Mooch
//
//  Created by adam on 9/6/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import Foundation
import SwiftyJSON

struct User {
    
    struct ContactInformation {
        let phone: String?
        let address: String?
        let email: String?
    }
    
    let id: Int
    let name: String
    let username: String
    let contact: ContactInformation
    let community: Community
    
    init(json: JSON) throws {
        guard let id = json["id"].int, name = json["name"].string, username = json["username"].string where json["community"].isExists() else {
            throw InitializationError.InsufficientJSONInformationForInitialization
        }
        
        self.id = id
        self.name = name
        self.username = username
        
        self.contact = ContactInformation(phone: json["phone"].string, address: json["address"].string, email: json["email"].string)
        
        let communityJSON = JSON(json["community"].object)
        self.community = try Community(json: communityJSON)
    }
}