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
        
        let user = User(id: 5, name: "test", contactInformation: contactInformation, currentRating: 4.5, ratingCount: 5, communityId: 4, pictureURL: "sample person pic", thumbnailPictureURL: "small pic")
        
        var localUser = LocalUser(user: user, authenticationToken: "CorrectPassword")
        
        //Test the getters and that all the variables are correctly initialized
        XCTAssert(localUser.user.id == 5)
        XCTAssert(localUser.user.name == "test")
        XCTAssert(localUser.user.contactInformation.phone == "123-456-7890")
        XCTAssert(localUser.user.contactInformation.address == "#406")
        XCTAssert(localUser.user.contactInformation.email == "test@wow.com")
        XCTAssert(localUser.user.communityId == 4)
        XCTAssert(localUser.authenticationToken == "CorrectPassword")
        
        //Test setters and proper modifiability
        localUser.user.name = "the new guy"
        localUser.user.contactInformation.address = "new apt"
        localUser.user.contactInformation.phone = nil

        XCTAssert(localUser.user.name == "the new guy")
        XCTAssert(localUser.user.contactInformation.phone == nil)
        XCTAssert(localUser.user.contactInformation.address == "new apt")
    }
    
    //Test that a LocalUser is constructed without failing when given JSON with all the data it needs
    func testConvenienceInitSuccess() {

        
        let localUserJSON: JSON = [User.JSONMapping.id.rawValue : 4132, User.JSONMapping.name.rawValue : "Bob the User",  User.JSONMapping.email.rawValue : "doge@example.com", User.JSONMapping.currentRating.rawValue : 4.5, User.JSONMapping.ratingCount.rawValue : 5, User.JSONMapping.communityId.rawValue : 4,LocalUser.JSONMapping.authenticationToken.rawValue : "authToken"]
        
        do {
            let localUser = try LocalUser(json: localUserJSON)

            
            //Test that all the variables are correctly initialized
            XCTAssert(localUser.user.id == 4132)
            XCTAssert(localUser.user.name == "Bob the User")
            XCTAssert(localUser.user.contactInformation.email == "doge@example.com")
            XCTAssert(localUser.user.communityId == 4)
            XCTAssert(localUser.authenticationToken  == "authToken")
        } catch {
            XCTFail()
        }
    }
}
