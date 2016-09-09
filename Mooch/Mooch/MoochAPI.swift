//
//  MoochAPI.swift
//  Mooch
//
//  Created by adam on 9/9/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import Alamofire
import Foundation
import SwiftyJSON

class MoochAPI {
    
    typealias MoochAPICompletionBlock = (JSON?, NSError?) -> ()
    
    static let NoResponseValueForJSONErrorCode = 7836
    static let CouldNotConvertToSwiftyJSONErrorCode = 8263
    
    //Allows authorized requests to be performed
    static func setAuthorizationCredentials(withUserId userId: Int, andPassword password: String) {
        MoochAPIRouter.setAuthorizationCredentials(withUserId: userId, andPassword: password)
    }
    
    //Clears the authorization credentials for when a user logs out
    static func clearAuthorizationCredentials() {
        MoochAPIRouter.clearAuthorizationCredentials()
    }
    
    static func GETUsers(completion: [User]? -> Void) {
        perform(MoochAPIRouter.GETUsers) { json, error in
            guard let json = json else {
                completion(nil)
                return
            }
            
            let usersArray = json.arrayValue
            var users = [User]()
            for userJSON in usersArray {
                do {
                    users.append(try User(json: userJSON))
                } catch {
                    print("couldn't create user with JSON: \(userJSON)")
                }
            }
            completion(users)
        }
    }
    
    private static func perform(request: URLRequestConvertible, withCompletion completion: MoochAPICompletionBlock) {
        Alamofire.request(request).validate().responseJSON { response in
            guard response.result.isSuccess else {
                completion(nil, response.result.error)
                return
            }
            
            guard let responseResultValue = response.result.value else {
                completion(nil, NSError(domain: "MoochAPI response did not have a value to convert to JSON", code: MoochAPI.NoResponseValueForJSONErrorCode, userInfo: nil))
                return
            }
            
            let responseJSON = JSON(responseResultValue)
            guard responseJSON.error == nil else {
                completion(nil, NSError(domain: "MoochAPI response could not be converted to SwiftyJSON", code: MoochAPI.CouldNotConvertToSwiftyJSONErrorCode, userInfo: nil))
                return
            }
            
            completion(responseJSON, nil)
        }
    }
}