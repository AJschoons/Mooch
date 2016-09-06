//
//  UserTests.swift
//  Mooch
//
//  Created by adam on 9/6/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import Foundation

import SwiftyJSON
import XCTest
@testable import Mooch

class UserTests: XCTestCase {
    
    //Test that a User is constructed without failing when given JSON with all the data it needs
    func testInitSuccess() {
        let communityJSONDict = ["id" : 1234, "address" : "1234 address lane", "name" : "highrise apartments"]
        let userJSON: JSON = ["id" : 4132, "name" : "Bob the User", "username" : "Secret life of bob", "phone" : "123-456-6789", "address" : "apt #406", "email" : "doge@example.com", "community" : communityJSONDict]
        
        do {
            let user = try User(json: userJSON)
            
            //Test that all the variables are correctly initialized
            XCTAssert(user.id == 4132)
            XCTAssert(user.name == "Bob the User")
            XCTAssert(user.username == "Secret life of bob")
            XCTAssert(user.contact.phone == "123-456-6789")
            XCTAssert(user.contact.address == "apt #406")
            XCTAssert(user.contact.email == "doge@example.com")
            XCTAssert(user.community.id == 1234)
            XCTAssert(user.community.address == "1234 address lane")
            XCTAssert(user.community.name == "highrise apartments")
        } catch {
            XCTFail()
        }
    }
    
//    //Test that a User throws the expected error when it doesn't have all the data it needs
    func testInitError() {
        let userJSON: JSON = ["id" : 4132]
        
        var jsonErrorThrown = false
        
        do {
            let _ = try User(json: userJSON)
            XCTFail()
        } catch InitializationError.InsufficientJSONInformationForInitialization {
            jsonErrorThrown = true
        } catch {
            
        }
        
        XCTAssert(jsonErrorThrown)
    }
}