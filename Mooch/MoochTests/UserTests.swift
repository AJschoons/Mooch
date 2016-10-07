//
//  UserTests.swift
//  Mooch
//
//  Created by adam on 9/6/16.
//  Copyright © 2016 cse498. All rights reserved.
//


import XCTest
@testable import Mooch

class UserTests: XCTestCase {
    
    func testDesignatedInit() {
        let contactInformation = User.ContactInformation(address: "#406", email: "test@wow.com", phone: "123-456-7890")
        let user = User(id: 5, name: "test", contactInformation: contactInformation, currentRating: 4.5, ratingCount: 5, communityId:4 , pictureURL: "sample person pic", thumbnailPictureURL: "small pic")
        
        //Test that all the variables are correctly initialized
        XCTAssert(user.id == 5)
        XCTAssert(user.name == "test")
        XCTAssert(user.contactInformation.phone == "123-456-7890")
        XCTAssert(user.contactInformation.address == "#406")
        XCTAssert(user.contactInformation.email == "test@wow.com")
    }
    
    //Test that a User is constructed without failing when given JSON with all the data it needs
    func testConvenienceInitSuccess() {
        
        let userJSON: JSON = [User.JSONMapping.id.rawValue : 4132, User.JSONMapping.name.rawValue : "Bob the User",  User.JSONMapping.email.rawValue : "doge@example.com", User.JSONMapping.currentRating.rawValue : 4.5, User.JSONMapping.ratingCount.rawValue : 5, User.JSONMapping.communityId.rawValue : 4]
    
        do {
            let user = try User(json: userJSON)
            
            //Test that all the variables are correctly initialized
            XCTAssert(user.id == 4132)
            XCTAssert(user.name == "Bob the User")
            XCTAssert(user.currentRating == 4.5)
            XCTAssert(user.ratingCount == 5)

            XCTAssert(user.contactInformation.email == "doge@example.com")
            XCTAssert(user.communityId == 4)
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
        } catch User.JSONInitializationError.name{
            jsonErrorThrown = true
        } catch {
            
        }
        
        XCTAssert(jsonErrorThrown)
    }
    
    func testGettersSetters() {
        
        let contactInformation = User.ContactInformation(address: "#406", email: "test@wow.com", phone: "123-456-7890")
        
        var user = User(id: 5, name: "test", contactInformation: contactInformation, currentRating: 4.5, ratingCount: 5, communityId: 7, pictureURL: "sample person pic", thumbnailPictureURL: "small pic")
        //Test getters
        
        
        XCTAssert(user.id == 5)
        XCTAssert(user.name == "test")
        XCTAssert(user.contactInformation.phone == "123-456-7890")
        XCTAssert(user.contactInformation.address == "#406")
        XCTAssert(user.contactInformation.email == "test@wow.com")
        XCTAssert(user.communityId == 7)
        //Test setters
        user.name = "the new guy"
        user.contactInformation.address = "new apt"
        XCTAssert(user.name == "the new guy")
        
        XCTAssert(user.contactInformation.phone == "123-456-7890")
        XCTAssert(user.contactInformation.address == "new apt")

    }
}
