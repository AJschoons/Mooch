//
//  MoochRouter.swift
//  Mooch
//
//  Created by adam on 9/7/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import Alamofire

//Class that maps an API route to a URLRequest. Should only be used through MoochAPI or in tests
enum MoochAPIRouter: URLRequestConvertible {
    
    typealias RoutingInformation = (path: String, method: Alamofire.HTTPMethod, parameters: [String: Any]?, requiresAuthorization: Bool)
    
    static let baseURLString = Strings.MoochAPIRouter.baseURL.rawValue
    
    static fileprivate var email: String?
    static fileprivate var authorizationToken: String?
    
    static fileprivate let NoParametersDictionary = [String : AnyObject]()
    
    static private let AuthorizationHeaderKey = "Authorization"
    
    case getListingCategories
    case getListings(forCommunityWithId: Int)
    case getUser(withId: Int)
    
    case postListing(userId: Int, title: String, description: String?, price: Float, isFree: Bool, categoryId: Int)
    case postLogin(withEmail: String, andPassword: String)
    case postUser(communityId: Int, name: String, email: String, phone: String, password: String, address: String?)
    
    //The keys to pass in as parameters mapped to strings
    enum ParameterMapping {
        enum PostLogin: String {
            case email = "email"
            case password = "password"
        }
        
        enum PostListing: String {
            case photo = "image"
            case title = "title"
            case description = "detail"
            case price = "price"
            case isFree = "free"
            case categoryId = "category_id"
        }
        
        enum PostUser: String {
            //Required
            case communityId = "community_id"
            case photo = "image"
            case name = "name"
            case email = "email"
            case phone = "phone"
            case password = "password"
            
            //Optional
            case address = "address"
        }
    }
    
    //Returns the URL request for the route
    func asURLRequest() throws -> URLRequest {
        let routingInformation = getRoutingInformation()
        
        let url = try MoochAPIRouter.baseURLString.asURL()
        var urlRequest = URLRequest(url: url.appendingPathComponent(routingInformation.path))
        urlRequest.httpMethod = routingInformation.method.rawValue
        
        if routingInformation.requiresAuthorization {
            if let email = MoochAPIRouter.email, let authorizationToken = MoochAPIRouter.authorizationToken {
                let authorizationHeaderValue = self.authorizationHeaderValue(email: email, authorizationToken: authorizationToken)
                urlRequest.setValue(authorizationHeaderValue, forHTTPHeaderField: MoochAPIRouter.AuthorizationHeaderKey)
            } else {
                print("ERROR: API route that requires authorization has not been given the authorization credentials")
            }
        }
        
        return try JSONEncoding.default.encode(urlRequest, with: routingInformation.parameters)
    }
    
    //Returns the routing information needed to create a url request for each route
    func getRoutingInformation() -> RoutingInformation {
        switch self {
        case .getListingCategories:
            return ("/categories", .get, nil, false)
            
        case .getListings(let communityId):
            return ("/communities/\(communityId)/listings", .get, nil, false)
            
        case .getUser(let userId):
            return ("/users/\(userId)", .get, nil, false)
            
        case .postListing(let userId, let title, let description, let price, let isFree, let categoryId):
            var parameters: [String : Any] = [ParameterMapping.PostListing.title.rawValue : title, ParameterMapping.PostListing.price.rawValue : price, ParameterMapping.PostListing.isFree.rawValue : isFree, ParameterMapping.PostListing.categoryId.rawValue : categoryId]
            if description != nil { parameters[ParameterMapping.PostListing.description.rawValue] = description! }
            return ("/users/\(userId)/listings", .post, parameters, true)
            
        case .postLogin(let email, let password):
            let parameters = [ParameterMapping.PostLogin.email.rawValue : email, ParameterMapping.PostLogin.password.rawValue : password]
            return ("/sessions", .post, parameters, false)
        
        case .postUser(let communityId, let name, let email, let phone, let password, let address):
            typealias mapping = ParameterMapping.PostUser
            var parameters: [String : Any] = [mapping.communityId.rawValue : communityId, mapping.name.rawValue : name, mapping.email.rawValue : email, mapping.phone.rawValue : phone, mapping.password.rawValue : password]
            if address != nil { parameters[mapping.address.rawValue] =  address! }
            return ("/users", .post, parameters, false)
        }
        
        
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
    
    func authorizationHeaders() -> [String : String]? {
        if let email = MoochAPIRouter.email, let authorizationToken = MoochAPIRouter.authorizationToken {
            let authorizationHeaderValue = self.authorizationHeaderValue(email: email, authorizationToken: authorizationToken)
            return [MoochAPIRouter.AuthorizationHeaderKey : authorizationHeaderValue]
        } else {
            return nil
        }
    }
    
    fileprivate func authorizationHeaderValue(email: String, authorizationToken: String) -> String {
        return "Token token=\"\(authorizationToken)\", email=\"\(email)\""
    }
}
