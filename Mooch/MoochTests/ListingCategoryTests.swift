//
//  ListingTagTests.swift
//  Mooch
//
//  Created by adam on 9/7/16.
//  Copyright © 2016 cse498. All rights reserved.
//


import XCTest
@testable import Mooch

class ListingCategoryTests: XCTestCase {
    
    func testDesignatedInit() {
        let listingCategory = ListingCategory(id: 12, name: "fruit")
        
        //Test that all the variables are correctly initialized
        XCTAssert(listingCategory.id == 12)
        XCTAssert(listingCategory.name == "fruit")
    }
    
    //    Test that an ListingTag is constructed without failing when given JSON with all the data it needs
    func testConvenienceInitSuccess() {
        let listingCategoryJSON: JSON = [ListingCategory.JSONMapping.id.rawValue : 12, ListingCategory.JSONMapping.name.rawValue : "fruit"]
        
        do {
            let listingCategory = try ListingCategory(json: listingCategoryJSON)
            
            //Test that all the variables are correctly initialized
            XCTAssert(listingCategory.id == 12)
            XCTAssert(listingCategory.name == "fruit")
        } catch {
            XCTFail()
        }
    }
    
    //Test that an ListingTag throws the expected error when it doesn't have all the data it needs
    func testConvenienceInitError() {
        let listingCategoryJSON: JSON = ["id" : 5]
        
        var jsonErrorThrown = false
        
        do {
            let _ = try ListingCategory(json: listingCategoryJSON)
            XCTFail()
        } catch ListingCategory.JSONInitializationError.name {
            jsonErrorThrown = true
        } catch {
            
        }
        
        XCTAssert(jsonErrorThrown)
    }

}
