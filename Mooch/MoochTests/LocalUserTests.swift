//
//  LocalUserTests.swift
//  Mooch
//
//  Created by adam on 9/7/16.
//  Copyright © 2016 cse498. All rights reserved.
//


import XCTest
@testable import Mooch

class LocalUserTests: XCTestCase {
    
    func testDesignatedInitAndGetterSetters() {
        let contactInformation = User.ContactInformation(address: "#406", email: "test@wow.com", phone: "123-456-7890")
        let community = Community(id: 7, address: "123 LaSalle", name: "123 Big Apartments")
        let user = User(id: 5, name: "test", contactInformation: contactInformation, community: community)
        var localUser = LocalUser(user: user, password: "password")
        
        //Test the getters and that all the variables are correctly initialized
        XCTAssert(localUser.user.id == 5)
        XCTAssert(localUser.user.name == "test")
        XCTAssert(localUser.user.contactInformation.phone == "123-456-7890")
        XCTAssert(localUser.user.contactInformation.address == "#406")
        XCTAssert(localUser.user.contactInformation.email == "test@wow.com")
        XCTAssert(localUser.user.community.id == 7)
        XCTAssert(localUser.user.community.address == "123 LaSalle")
        XCTAssert(localUser.user.community.name == "123 Big Apartments")
        XCTAssert(localUser.password == "password")
        
        //Test setters and proper modifiability
        localUser.user.name = "the new guy"
        localUser.user.contactInformation.address = "new apt"
        localUser.user.contactInformation.phone = nil
        let newCommunity = Community(id: 9, address: "new place", name: "new name")
        localUser.user.community = newCommunity
        
        XCTAssert(localUser.user.name == "the new guy")
        XCTAssert(localUser.user.contactInformation.phone == nil)
        XCTAssert(localUser.user.contactInformation.address == "new apt")
        XCTAssert(localUser.user.community.id == 9)
        XCTAssert(localUser.user.community.address == "new place")
        XCTAssert(localUser.user.community.name == "new name")
    }
    
    //Test that a LocalUser is constructed without failing when given JSON with all the data it needs
    func testConvenienceInitSuccess() {
        let communityJSONDict = ["id" : 1234, "address" : "1234 address lane", "name" : "highrise apartments"] as [String : Any]
        let userJSON: JSON = ["id" : 4132, "name" : "Bob the User", "phone" : "123-456-6789", "address" : "apt #406", "email" : "doge@example.com", "community" : communityJSONDict]
        
        do {
            let localUser = try LocalUser(userJSON: userJSON, password: "password")
            
            //Test that all the variables are correctly initialized
            XCTAssert(localUser.user.id == 4132)
            XCTAssert(localUser.user.name == "Bob the User")
            XCTAssert(localUser.user.contactInformation.phone == "123-456-6789")
            XCTAssert(localUser.user.contactInformation.address == "apt #406")
            XCTAssert(localUser.user.contactInformation.email == "doge@example.com")
            XCTAssert(localUser.user.community.id == 1234)
            XCTAssert(localUser.user.community.address == "1234 address lane")
            XCTAssert(localUser.user.community.name == "highrise apartments")
            XCTAssert(localUser.password == "password")
        } catch {
            XCTFail()
        }
    }
    
    //Test that a LocalUser throws the expected error when it doesn't have all the data it needs
    func testConvenienceInitError() {
        let userJSON: JSON = ["id" : 4132]
        
        var jsonErrorThrown = false
        
        do {
            let _ = try LocalUser(userJSON: userJSON, password: "")
            XCTFail()
        } catch InitializationError.insufficientJSONInformationForInitialization {
            jsonErrorThrown = true
        } catch {
            
        }
        
        XCTAssert(jsonErrorThrown)
    }
}
