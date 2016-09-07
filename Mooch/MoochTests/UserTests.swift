//
//  UserTests.swift
//  Mooch
//
//  Created by adam on 9/6/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import SwiftyJSON
import XCTest
@testable import Mooch

class UserTests: XCTestCase {
    
    func testDesignatedInit() {
        let contactInformation = User.ContactInformation(address: "#406", email: "test@wow.com", phone: "123-456-7890")
        let community = Community(id: 7, address: "123 LaSalle", name: "123 Big Apartments")
        let user = User(id: 5, name: "test", contactInformation: contactInformation, community: community)
        
        //Test that all the variables are correctly initialized
        XCTAssert(user.id == 5)
        XCTAssert(user.name == "test")
        XCTAssert(user.contactInformation.phone == "123-456-7890")
        XCTAssert(user.contactInformation.address == "#406")
        XCTAssert(user.contactInformation.email == "test@wow.com")
        XCTAssert(user.community.id == 7)
        XCTAssert(user.community.address == "123 LaSalle")
        XCTAssert(user.community.name == "123 Big Apartments")
    }
    
    //Test that a User is constructed without failing when given JSON with all the data it needs
    func testConvenienceInitSuccess() {
        let communityJSONDict = ["id" : 1234, "address" : "1234 address lane", "name" : "highrise apartments"]
        let userJSON: JSON = ["id" : 4132, "name" : "Bob the User", "phone" : "123-456-6789", "address" : "apt #406", "email" : "doge@example.com", "community" : communityJSONDict]
        
        do {
            let user = try User(json: userJSON)
            
            //Test that all the variables are correctly initialized
            XCTAssert(user.id == 4132)
            XCTAssert(user.name == "Bob the User")
            XCTAssert(user.contactInformation.phone == "123-456-6789")
            XCTAssert(user.contactInformation.address == "apt #406")
            XCTAssert(user.contactInformation.email == "doge@example.com")
            XCTAssert(user.community.id == 1234)
            XCTAssert(user.community.address == "1234 address lane")
            XCTAssert(user.community.name == "highrise apartments")
        } catch {
            XCTFail()
        }
    }
    
    //Test that a User throws the expected error when it doesn't have all the data it needs
    func testConvenienceInitError() {
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
    
    func testGettersSetters() {
        let contactInformation = User.ContactInformation(address: "#406", email: "test@wow.com", phone: "123-456-7890")
        let community = Community(id: 7, address: "123 LaSalle", name: "123 Big Apartments")
        var user = User(id: 5, name: "test", contactInformation: contactInformation, community: community)
        
        //Test getters
        XCTAssert(user.id == 5)
        XCTAssert(user.name == "test")
        XCTAssert(user.contactInformation.phone == "123-456-7890")
        XCTAssert(user.contactInformation.address == "#406")
        XCTAssert(user.contactInformation.email == "test@wow.com")
        XCTAssert(user.community.id == 7)
        XCTAssert(user.community.address == "123 LaSalle")
        XCTAssert(user.community.name == "123 Big Apartments")
        
        //Test setters
        user.name = "the new guy"
        user.contactInformation.address = "new apt"
        user.contactInformation.phone = nil
        let newCommunity = Community(id: 9, address: "new place", name: "new name")
        user.community = newCommunity
        
        XCTAssert(user.name == "the new guy")
        XCTAssert(user.contactInformation.phone == nil)
        XCTAssert(user.contactInformation.address == "new apt")
        XCTAssert(user.community.id == 9)
        XCTAssert(user.community.address == "new place")
        XCTAssert(user.community.name == "new name")
    }
}