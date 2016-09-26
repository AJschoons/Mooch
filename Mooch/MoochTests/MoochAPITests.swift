//
//  MoochAPITests.swift
//  Mooch
//
//  Created by adam on 9/22/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import XCTest
@testable import Mooch

import OHHTTPStubs

class MoochAPITests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        // Reset all the networking stubs between each test
        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }
    
//    func testGETUser_success() {
//        
//        let userId = 2
//        
//        let asynchronousTestExpectation = expectation(description: "the completion closure returns the correct User with no error")
//        var returnedUser: User?
//        var returnedError: Error?
//        
//        MoochAPI.GETUser(withId: userId) { user, error in
//            returnedUser = user
//            returnedError = error
//            asynchronousTestExpectation.fulfill()
//        }
//        
//        waitForExpectations(timeout: 5) { error in
//            //Is a user returned with no error?
//            XCTAssert(returnedError == nil)
//            guard let user = returnedUser else {
//                XCTFail()
//                return
//            }
//            
//            //Is the user's information correct?
//            XCTAssert(user.id == userId)
//        }
//    }
    
    func testGETListings_success() {
        
        let _ = stub(isHost(MoochAPIRouter.baseURLString) && isPath("/listings")) { request in
            return OHHTTPStubsResponse(
                fileAtPath: OHPathForFile("json_response/GETListings.json", type(of: self))!,
                statusCode: 200,
                headers: [
                    "ContentType": "application/json"
                ]
            )
        }

        let asynchronousTestExpectation = expectation(description: "the completion closure returns the correct Listings with no error")
        var returnedListings: [Listing]?
        var returnedError: Error?
        
        MoochAPI.GETListings { listings, error in
            returnedListings = listings
            returnedError = error
            asynchronousTestExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 5) { error in
            //Are the listings returned with no error?
            XCTAssert(returnedError == nil)
            guard let listings = returnedListings else {
                XCTFail()
                return
            }
            
            //Are the listings information correct?
            XCTAssert(listings.count == 2)
        }
    }
}
