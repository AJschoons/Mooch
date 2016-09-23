//
//  MoochRouter.swift
//  Mooch
//
//  Created by adam on 9/7/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import Foundation
import Alamofire

//Class that maps an API route to a URLRequest
enum MoochAPIRouter: URLRequestConvertible {
    static let baseURLString = "https://mooch-rails-api.appspot.com/api/v1"
    
//    static fileprivate var userId: Int?
//    static fileprivate var password: String?
    
    static fileprivate let NoParametersDictionary = [String : AnyObject]()
    
    case getListings
    case getUser(withId: Int)
    
    //Returns the URL request for the route
    func asURLRequest() throws -> URLRequest {
        let result: (path: String, method: Alamofire.HTTPMethod, parameters: [String: AnyObject]?, requiresAuthorization: Bool) = {
            switch self {
            case .getListings:
                return ("/listings", .get, nil, false)
            case .getUser(let userId):
                return ("/users/\(userId)", .get, nil, false)
            }
        }()
        
        let url = try MoochAPIRouter.baseURLString.asURL()
        var urlRequest = URLRequest(url: url.appendingPathComponent(result.path))
        urlRequest.httpMethod = result.method.rawValue
        
//        if result.requiresAuthorization {
//            if let userId = MoochAPIRouter.userId, let userPassword = MoochAPIRouter.password {
//                urlRequest.setValue(String(userId), forHTTPHeaderField: "user_id")
//                urlRequest.setValue(userPassword, forHTTPHeaderField: "user_password")
//            } else {
//                print("ERROR: API route that requires authorization has not been given the authorization credentials")
//            }
//        }
        
        return try JSONEncoding.default.encode(urlRequest, with: result.parameters)
    }
    
//    //Allows the router to perform authorized requests
//    static func setAuthorizationCredentials(withUserId userId: Int, andPassword password: String) {
//        self.userId = userId
//        self.password = password
//    }
//    
//    //Clears the authorization credentials for when a user logs out
//    static func clearAuthorizationCredentials() {
//        self.userId = nil
//        self.password = nil
//    }
}
