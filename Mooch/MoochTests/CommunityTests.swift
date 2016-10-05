//
//  CommunityTests.swift
//  Mooch
//
//  Created by adam on 9/6/16.
//  Copyright © 2016 cse498. All rights reserved.
//


import XCTest
@testable import Mooch

class CommunityTests: XCTestCase {
    
    func testDesignatedInit() {
        let community = Community(id: 7, address: "123 LaSalle", name: "123 Big Apartments", pictureURL:"I am a sample pic")
        
        //Test that all the variables are correctly initialized
        XCTAssert(community.id == 7)
        XCTAssert(community.address == "123 LaSalle")
        XCTAssert(community.name == "123 Big Apartments")
        XCTAssert(community.pictureURL == "I am a sample pic")
    }
    
    //Test that a Community is constructed without failing when given JSON with all the data it needs
    func testConvenienceInitSuccess() {
        let communityJSON: JSON = [Community.JSONMapping.id.rawValue : 1234,  Community.JSONMapping.address.rawValue : "1234 address lane", Community.JSONMapping.name.rawValue : "highrise apartments", Community.JSONMapping.pictureURL.rawValue :"I am a sample pic"]
        
        do {
            let community = try Community(json: communityJSON)
            
            //Test that all the variables are correctly initialized
            XCTAssert(community.id == 1234)
            XCTAssert(community.address == "1234 address lane")
            XCTAssert(community.name == "highrise apartments")
            XCTAssert(community.pictureURL == "I am a sample pic")
        } catch {
            XCTFail()
        }
    }
    
    //Test that a Community throws the expected error when it doesn't have all the data it needs
    func testConvenienceInitError() {
        let communityJSON: JSON = ["id" : 1234,"name":"jiang","pictureURL":"sample Pic"]
        
        var jsonErrorThrown = false
        
        do {
            let _ = try Community(json: communityJSON)
            XCTFail()
        } catch Community.JSONInitializationError.address {
            jsonErrorThrown = true
        } catch {
            
        }
        
        XCTAssert(jsonErrorThrown)
    }
}
