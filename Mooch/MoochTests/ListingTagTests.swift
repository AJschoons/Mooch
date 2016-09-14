//
//  ListingTagTests.swift
//  Mooch
//
//  Created by adam on 9/7/16.
//  Copyright © 2016 cse498. All rights reserved.
//


import XCTest
@testable import Mooch

class ListingTagTests: XCTestCase {
    
    func testDesignatedInit() {
        let listingTag = ListingTag(id: 12, name: "fruit")
        
        //Test that all the variables are correctly initialized
        XCTAssert(listingTag.id == 12)
        XCTAssert(listingTag.name == "fruit")
    }
    
    //Test that an ListingTag is constructed without failing when given JSON with all the data it needs
    func testConvenienceInitSuccess() {
        let listingTagJSON: JSON = ["id" : 12, "name" : "fruit"]
        
        do {
            let listingTag = try ListingTag(json: listingTagJSON)
            
            //Test that all the variables are correctly initialized
            XCTAssert(listingTag.id == 12)
            XCTAssert(listingTag.name == "fruit")
        } catch {
            XCTFail()
        }
    }
    
    //Test that an ListingTag throws the expected error when it doesn't have all the data it needs
    func testConvenienceInitError() {
        let listingTagJSON: JSON = ["blahhhh" : "testsssfadsfg"]
        
        var jsonErrorThrown = false
        
        do {
            let _ = try ListingTag(json: listingTagJSON)
            XCTFail()
        } catch InitializationError.insufficientJSONInformationForInitialization {
            jsonErrorThrown = true
        } catch {
            
        }
        
        XCTAssert(jsonErrorThrown)
    }
}
