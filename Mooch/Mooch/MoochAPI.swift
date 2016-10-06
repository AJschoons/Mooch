//
//  MoochAPI.swift
//  Mooch
//
//  Created by adam on 9/9/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import Alamofire
import Foundation


class MoochAPI {
    
    typealias CompletionClosure = (JSON?, Error?) -> ()
    
    //Allows authorized requests to be performed
    static func setAuthorizationCredentials(email: String, authorizationToken: String) {
        MoochAPIRouter.setAuthorizationCredentials(email: email, authorizationToken: authorizationToken)
    }
    
    //Clears the authorization credentials for when a user logs out
    static func clearAuthorizationCredentials() {
        MoochAPIRouter.clearAuthorizationCredentials()
    }
    
    static func GETUser(withId id: Int, completion: @escaping (User?, Error?) -> Void) {
        perform(MoochAPIRouter.getUser(withId: id)) { json, error in
            guard let json = json else {
                completion(nil, error)
                return
            }
            
            do {
                let user = try User(json: json)
                completion(user, nil)
            } catch let error {
                print("couldn't create user with JSON: \(json)")
                completion(nil, error)
            }
        }
    }
    
    static func GETListings(communityId: Int, completion: @escaping ([Listing]?, Error?) -> Void) {
        perform(MoochAPIRouter.getListings(forCommunityWithId: communityId)) { json, error in
            guard let listingsJSON = json?.array else {
                completion(nil, error)
                return
            }
            
            do {
                let listings = try listingsJSON.map({try Listing(json: $0)})
                completion(listings, nil)
            } catch let error {
                print("couldn't create listings with JSON: \(json)")
                completion(nil, error)
            }
        }
    }
    
    static func POSTLogin(email: String, password: String, completion: @escaping (LocalUser?, Error?) -> Void) {
        perform(MoochAPIRouter.postLogin(withEmail: email, andPassword: password)) { json, error in
            guard let localUserJSON = json else {
                completion(nil, error)
                return
            }
            
            do {
                let localUser = try LocalUser(json: localUserJSON)
                completion(localUser, nil)
            } catch let error {
                print("couldn't create local user with JSON: \(json)")
                completion(nil, error)
            }
        }
    }

    //This method does all the same redundant work that would be shared between calls
    fileprivate static func perform(_ request: URLRequestConvertible, withCompletion completion: @escaping CompletionClosure) {
        Alamofire.request(request).validate().responseJSON { response in
            guard response.result.isSuccess else {
                completion(nil, response.result.error)
                return
            }
            
            guard let responseResultValue = response.result.value else {
                completion(nil, MoochAPIError.noResponseValueForJSONMapping)
                return
            }
            
            let responseJSON = JSON(responseResultValue)
            guard responseJSON.error == nil else {
                completion(nil, MoochAPIError.swiftyJSONConversionFailed)
                return
            }
            
            completion(responseJSON, nil)
        }
    }
}
