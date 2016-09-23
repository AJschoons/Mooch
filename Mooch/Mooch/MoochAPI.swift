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
    
    static let NoResponseValueForJSONErrorCode = 7836
    static let CouldNotConvertToSwiftyJSONErrorCode = 8263
    
//    //Allows authorized requests to be performed
//    static func setAuthorizationCredentials(withUserId userId: Int, andPassword password: String) {
//        MoochAPIRouter.setAuthorizationCredentials(withUserId: userId, andPassword: password)
//    }
//    
//    //Clears the authorization credentials for when a user logs out
//    static func clearAuthorizationCredentials() {
//        MoochAPIRouter.clearAuthorizationCredentials()
//    }
    
    static func GETUser(withId id: Int, completion: @escaping (User?, Error?) -> Void) {
        perform(MoochAPIRouter.getUser(withId: id)) { json, error in
            guard let json = json else {
                completion(nil, error)
                return
            }
            
            do {
                let user = try User(json: json)
                completion(user, nil)
            } catch {
                print("couldn't create user with JSON: \(json)")
                completion(nil, InitializationError.insufficientJSONInformationForInitialization)
            }
        }
    }
    
    fileprivate static func perform(_ request: URLRequestConvertible, withCompletion completion: @escaping CompletionClosure) {
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
