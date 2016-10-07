//
//  MoochAPIRouterTests.swift
//  Mooch
//
//  Created by adam on 9/22/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import XCTest
@testable import Mooch

import Foundation

class MoochAPIRouterTests: XCTestCase {
    
    let GETHttpMethodString = "GET"
    let PUTHttpMethodString = "PUT"
    let POSTHttpMethodString = "POST"
    let DELETEHttpMethodString = "DELETE"
    
    //Use this to convert the Http body data into SwiftyJSON
    private func convertToJSON(fromHTTPBodyData jsonData: Data) throws -> JSON {
        let json = try JSONSerialization.jsonObject(with: jsonData, options: [])
        return JSON(json)
    }
    
    private func headersContainJSONContentType(headers: [String : String]) -> Bool {
        guard let contentType = headers["Content-Type"] else { return false }
        return contentType == "application/json"
    }
    
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
            //(in this case there are no headers because the route does not require authorization AND there are no JSON parameters sent)
            XCTAssert(urlRequest.allHTTPHeaderFields!.count == 0)
        } catch {
            XCTFail()
        }
    }
    
    func testGetListingRoute() {
        
        let communityId = 12
        
        do {
            let urlRequest = try MoochAPIRouter.getListings(forCommunityWithId: communityId).asURLRequest()
            
            //Does the correct URL get created?
            print(urlRequest ,"   <----")
            XCTAssert(urlRequest.url!.absoluteString == "\(MoochAPIRouter.baseURLString)/communities/\(communityId)/listings")
            
            //Does the correct URL method get used?
            XCTAssert(urlRequest.httpMethod == GETHttpMethodString)
            
            //Are the correct parameters getting put into the HTTP body?
            //Note: these parameters will be JSON encoded in Mooch if there are any
            //(in this case there shouldn't be any)
            XCTAssert(urlRequest.httpBody == nil)
            
            //Are the correct key-value pairs being put into the HTTP headers?
            //(in this case there are no headers because the route does not require authorization AND there are no JSON parameters sent)
            XCTAssert(urlRequest.allHTTPHeaderFields!.count == 0)
        } catch {
            XCTFail()
        }
    }
    
    func testPostLoginRoute() {
        
        let email = "email@example.com"
        let password = "not a real password"
        
        do {
            let urlRequest = try MoochAPIRouter.postLogin(withEmail: email, andPassword: password).asURLRequest()
            
            //Does the correct URL get created?
            XCTAssert(urlRequest.url!.absoluteString == "\(MoochAPIRouter.baseURLString)/sessions")
            
            //Does the correct URL method get used?
            XCTAssert(urlRequest.httpMethod == POSTHttpMethodString)
            
            //Are the correct parameters getting put into the HTTP body?
            //Note: these parameters will be JSON encoded in Mooch if there are any
            XCTAssert(urlRequest.httpBody != nil)
            do {
                let httpBodyJSON = try convertToJSON(fromHTTPBodyData: urlRequest.httpBody!)
                XCTAssert(httpBodyJSON[MoochAPIRouter.JSONMapping.email.rawValue].stringValue == email)
                XCTAssert(httpBodyJSON[MoochAPIRouter.JSONMapping.password.rawValue].stringValue == password)
            } catch {
                //If there was an error then that means the HTTP body could not be converted to JSON,
                //so the test should fail because it needs to be valid JSON
                XCTFail()
            }
            
            //Are the correct key-value pairs being put into the HTTP headers?
            //Since we are sending parameters in JSON, there must be a JSON header
            XCTAssert(urlRequest.allHTTPHeaderFields!.count == 1)
            XCTAssert(headersContainJSONContentType(headers: urlRequest.allHTTPHeaderFields!))
        } catch {
            XCTFail()
        }
    }
}
