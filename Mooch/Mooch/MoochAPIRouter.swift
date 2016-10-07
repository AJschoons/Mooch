//
//  MoochRouter.swift
//  Mooch
//
//  Created by adam on 9/7/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import Foundation
import Alamofire

//Class that maps an API route to a URLRequest. Should only be used through MoochAPI or in tests
enum MoochAPIRouter: URLRequestConvertible {
    static let baseURLString = "https://mooch-rails-api.appspot.com/api/v1"
    
    static fileprivate var email: String?
    static fileprivate var authorizationToken: String?
    
    static fileprivate let NoParametersDictionary = [String : AnyObject]()
    
    static private let AuthorizationHeaderKey = "Authorization"
    
    case getListingCategories
    case getListings(forCommunityWithId: Int)
    case getUser(withId: Int)
    
    case postListing(userId: Int, title: String, description: String?, price: Float, isFree: Bool, categoryId: Int)
    case postLogin(withEmail: String, andPassword: String)
    
    //The keys to pass in as parameters mapped to strings
    enum JSONMapping {
        enum PostLogin: String {
            case email = "email"
            case password = "password"
        }
        
        enum PostListing: String {
            case title = "title"
            case description = "detail"
            case price = "price"
            case isFree = "free"
            case categoryId = "category_id"
        }
    }
    
    //Returns the URL request for the route
    func asURLRequest() throws -> URLRequest {
        let result: (path: String, method: Alamofire.HTTPMethod, parameters: [String: Any]?, requiresAuthorization: Bool) = {
            switch self {
            case .getListingCategories:
                return ("/categories", .get, nil, false)
                
            case .getListings(let communityId):
                return ("/communities/\(communityId)/listings", .get, nil, false)
                
            case .getUser(let userId):
                return ("/users/\(userId)", .get, nil, false)
                
            case .postListing(let userId, let title, let description, let price, let isFree, let categoryId):
                var parameters: [String : Any] = [JSONMapping.PostListing.title.rawValue : title, JSONMapping.PostListing.price.rawValue : price, JSONMapping.PostListing.isFree.rawValue : isFree, JSONMapping.PostListing.categoryId.rawValue : categoryId]
                if description != nil { parameters[JSONMapping.PostListing.description.rawValue] = description! }
                return ("/users/\(userId)/listings", .post, parameters, true)
                
            case .postLogin(let email, let password):
                let parameters = [JSONMapping.PostLogin.email.rawValue : email, JSONMapping.PostLogin.password.rawValue : password]
                return ("/sessions", .post, parameters, false)
            }
        }()
        
        let url = try MoochAPIRouter.baseURLString.asURL()
        var urlRequest = URLRequest(url: url.appendingPathComponent(result.path))
        urlRequest.httpMethod = result.method.rawValue
        
        if result.requiresAuthorization {
            if let email = MoochAPIRouter.email, let authorizationToken = MoochAPIRouter.authorizationToken {
                let authorizationHeaderValue = self.authorizationHeaderValue(email: email, authorizationToken: authorizationToken)
                urlRequest.setValue(authorizationHeaderValue, forHTTPHeaderField: MoochAPIRouter.AuthorizationHeaderKey)
            } else {
                print("ERROR: API route that requires authorization has not been given the authorization credentials")
            }
        }
        
        return try JSONEncoding.default.encode(urlRequest, with: result.parameters)
    }
    
    //Allows the router to perform authorized requests
    static func setAuthorizationCredentials(email: String, authorizationToken: String) {
        self.email = email
        self.authorizationToken = authorizationToken
    }
    
    //Clears the authorization credentials for when a user logs out
    static func clearAuthorizationCredentials() {
        email = nil
        authorizationToken = nil
    }
    
    fileprivate func authorizationHeaderValue(email: String, authorizationToken: String) -> String {
        return "Token token=\"\(authorizationToken)\", email=\"\(email)\""
    }
}
