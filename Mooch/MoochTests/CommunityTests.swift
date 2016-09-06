//
//  CommunityTests.swift
//  Mooch
//
//  Created by adam on 9/6/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import SwiftyJSON
import XCTest
@testable import Mooch

class CommunityTests: XCTestCase {
    
    //Test that a Community is constructed without failing when given JSON with all the data it needs
    func testInitSuccess() {
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
    func testInitError() {
        let communityJSON: JSON = ["id" : 1234, "address" : "1234 address lane"]
        
        var jsonErrorThrown = false
        
        do {
            let _ = try Community(json: communityJSON)
            XCTFail()
        } catch InitializationError.InsufficientJSONInformationForInitialization {
            jsonErrorThrown = true
        } catch {
            
        }
        
        XCTAssert(jsonErrorThrown)
    }
}
