//
//  MoochAPIRouterTests.swift
//  Mooch
//
//  Created by adam on 9/22/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import XCTest
@testable import Mooch

class MoochAPIRouterTests: XCTestCase {
    
    let GETHttpMethodString = "GET"
    let PUTHttpMethodString = "PUT"
    let POSTHttpMethodString = "POST"
    let DELETEHttpMethodString = "DELETE"
    
    //Make sure we have the expected base url string
    func testBaseURLString() {
        XCTAssert(MoochAPIRouter.baseURLString == "https://mooch-rails-api.appspot.com/api/v1")
    }
    
    func testGetUserRoute() {
        let userId = 734
        
        do {
            let urlRequest = try MoochAPIRouter.getUser(withId: userId).asURLRequest()
            
            //Does the correct URL get created?
            XCTAssert(urlRequest.url!.absoluteString == "\(MoochAPIRouter.baseURLString)/users/\(userId)")
            
            //Does the correct URL method get used?
            XCTAssert(urlRequest.httpMethod == GETHttpMethodString)
            
            //Are the correct parameters getting put into the HTTP body? 
            //Note: these parameters will be JSON encoded in Mooch if there are any
            //(in this case there shouldn't be any)
            XCTAssert(urlRequest.httpBody == nil)
            
            //Are the correct key-value pairs being put into the HTTP headers?
            //(in this case there are no headers)
            XCTAssert(urlRequest.allHTTPHeaderFields!.count == 0)
        } catch {
            XCTFail()
        }
    }
}
