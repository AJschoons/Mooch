//
//  MoochAPITests.swift
//  Mooch
//
//  Created by adam on 9/22/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import XCTest
//@testable import Mooch

import OHHTTPStubs

class MoochAPITests: XCTestCase {
    
    let host = "mooch-rails-api.appspot.com"
    let startOfPath = "/api/v1"
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        // Reset all the networking stubs between each test
        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }
//    GETUser
    
    
    func testGETCategories_success() {
        guard let path = OHPathForFile("GETCategories.json", type(of: self)) else {
            preconditionFailure("Could not find expected file in test bundle")
        }
        _ = stub(condition: isHost(host) && isPath("\(startOfPath)/categories"))
        { request in
            print("\nRequest: \(request)\n")
            return OHHTTPStubsResponse(
                fileAtPath:path,
                statusCode: 200,
                headers: [
                    "ContentType": "application/json"
                ]
            )
        }
        let asynchronousTestExpectation = expectation(description: "the completion closure returns the correct Listings with no error")
        var returnedListings: [ListingCategory]?
        var returnedError: Error?
        MoochAPI.GETListingCategories { categories, error in
            print(categories?.count)
            returnedListings = categories
            returnedError = error
            asynchronousTestExpectation.fulfill()
        }
        waitForExpectations(timeout: 10) { error in
            //Are the listings returned with no error?
            XCTAssert(returnedError == nil)
            guard let listings = returnedListings else {
                XCTFail()
                return
            }
            //Are the listings information correct?
            XCTAssert(listings.count == 18)
        }
    }
    
    
    
    
    func testGETListings_success() {
        guard let path = OHPathForFile("GETListings.json", type(of: self)) else {
            preconditionFailure("Could not find expected file in test bundle")
        }
        print(path," <-")

        _ = stub(condition: isHost(host) && isPath("\(startOfPath)/communities/1/listings")) { request in
            print("\nRequest: \(request)\n")
            return OHHTTPStubsResponse(
                fileAtPath:path,
                statusCode: 200,
                headers: [
                    "ContentType": "application/json"
                ]
            )
        }
        let asynchronousTestExpectation = expectation(description: "the completion closure returns the correct Listings with no error")
        var returnedListings: [Listing]?
        var returnedError: Error?
        let community_id = 1
        MoochAPI.GETListings(communityId:community_id) { listings, error in
            returnedListings = listings
            returnedError = error
            asynchronousTestExpectation.fulfill()
        }
        waitForExpectations(timeout: 10) { error in
            //Are the listings returned with no error?
            XCTAssert(returnedError == nil)
            guard let listings = returnedListings else {
                XCTFail()
                return
            }
            //Are the listings information correct?
            XCTAssert(listings.count == 10)
        }
    }
    
    
    
    

}
