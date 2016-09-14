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
    static fileprivate let baseURLPath = "http://mooch-test.appspot.com"
    
    static fileprivate var userId: Int?
    static fileprivate var password: String?
    
    static fileprivate let NoParametersDictionary = [String : AnyObject]()
    
    //Unauthorized
    case getUsers
    
    //Authorized
    case getUser(withId: Int)
    
    //Returns the URL request for the route
    var URLRequest: NSMutableURLRequest {
        let result: (path: String, method: Alamofire.Method, parameters: [String: AnyObject]?, requiresAuthorization: Bool) = {
            switch self {
            case .getUsers:
                return ("/user", .GET, nil, false)
            case .getUser(let userId):
                return ("/user/\(userId)", .GET, nil, true)
            }
        }()
        
        let URL = Foundation.URL(string: MoochAPIRouter.baseURLPath)!
        let URLRequest = NSMutableURLRequest(url: URL.appendingPathComponent(result.path))
        URLRequest.httpMethod = result.method.rawValue
        
        if result.requiresAuthorization {
            if let userId = MoochAPIRouter.userId, let userPassword = MoochAPIRouter.password {
                URLRequest.setValue(String(userId), forHTTPHeaderField: "user_id")
                URLRequest.setValue(userPassword, forHTTPHeaderField: "user_password")
            } else {
                print("ERROR: API route that requires authorization has not been given the authorization credentials")
            }
        }
        
        let encoding = Alamofire.ParameterEncoding.json
        return encoding.encode(URLRequest, parameters: result.parameters).0
    }
    
    //Allows the router to perform authorized requests
    static func setAuthorizationCredentials(withUserId userId: Int, andPassword password: String) {
        self.userId = userId
        self.password = password
    }
    
    //Clears the authorization credentials for when a user logs out
    static func clearAuthorizationCredentials() {
        self.userId = nil
        self.password = nil
    }
}
