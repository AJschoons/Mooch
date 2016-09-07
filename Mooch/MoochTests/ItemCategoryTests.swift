//
//  ItemCategoryTests.swift
//  Mooch
//
//  Created by adam on 9/7/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import SwiftyJSON
import XCTest
@testable import Mooch

class ItemCategoryTests: XCTestCase {
    
    func testDesignatedInit() {
        let itemCategory = ItemCategory(id: 12, name: "fruit")
        
        //Test that all the variables are correctly initialized
        XCTAssert(itemCategory.id == 12)
        XCTAssert(itemCategory.name == "fruit")
    }
    
    //Test that an ItemCategory is constructed without failing when given JSON with all the data it needs
    func testConvenienceInitSuccess() {
        let itemCategoryJSON: JSON = ["id" : 12, "name" : "fruit"]
        
        do {
            let itemCategory = try ItemCategory(json: itemCategoryJSON)
            
            //Test that all the variables are correctly initialized
            XCTAssert(itemCategory.id == 12)
            XCTAssert(itemCategory.name == "fruit")
        } catch {
            XCTFail()
        }
    }
    
    //Test that an ItemCategory throws the expected error when it doesn't have all the data it needs
    func testConvenienceInitError() {
        let itemCategoryJSON: JSON = ["blahhhh" : "testsssfadsfg"]
        
        var jsonErrorThrown = false
        
        do {
            let _ = try ItemCategory(json: itemCategoryJSON)
            XCTFail()
        } catch InitializationError.InsufficientJSONInformationForInitialization {
            jsonErrorThrown = true
        } catch {
            
        }
        
        XCTAssert(jsonErrorThrown)
    }
}