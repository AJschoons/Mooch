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
        let community = Community(id: 7, address: "123 LaSalle", name: "123 Big Apartments")
        
        //Test that all the variables are correctly initialized
        XCTAssert(community.id == 7)
        XCTAssert(community.address == "123 LaSalle")
        XCTAssert(community.name == "123 Big Apartments")
    }
    
    //Test that a Community is constructed without failing when given JSON with all the data it needs
    func testConvenienceInitSuccess() {
        let communityJSON: JSON = ["id" : 1234, "address" : "1234 address lane", "name" : "highrise apartments"]
        
        do {
            let community = try Community(json: communityJSON)
            
            //Test that all the variables are correctly initialized
            XCTAssert(community.id == 1234)
            XCTAssert(community.address == "1234 address lane")
            XCTAssert(community.name == "highrise apartments")
        } catch {
            XCTFail()
        }
    }
    
    //Test that a Community throws the expected error when it doesn't have all the data it needs
    func testConvenienceInitError() {
        let communityJSON: JSON = ["id" : 1234, "address" : "1234 address lane"]
        
        var jsonErrorThrown = false
        
        do {
            let _ = try Community(json: communityJSON)
            XCTFail()
        } catch InitializationError.insufficientJSONInformationForInitialization {
            jsonErrorThrown = true
        } catch {
            
        }
        
        XCTAssert(jsonErrorThrown)
    }
}
