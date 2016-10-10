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
    
    static let MaxImageSize = CGSize(width: 540, height: 540)
    
    typealias ExpectingResponseCompletionClosure = (JSON?, Error?) -> ()
    typealias NotExpectingResponseCompletionClosure = (Bool, JSON?, Error?) -> () //Bool: Success/Fail
    
    //Allows authorized requests to be performed
    static func setAuthorizationCredentials(email: String, authorizationToken: String) {
        MoochAPIRouter.setAuthorizationCredentials(email: email, authorizationToken: authorizationToken)
    }
    
    //Clears the authorization credentials for when a user logs out
    static func clearAuthorizationCredentials() {
        MoochAPIRouter.clearAuthorizationCredentials()
    }
    
    static func GETListingCategories(completion: @escaping ([ListingCategory]?, Error?) -> Void) {
        perform(requestExpectingResponse: MoochAPIRouter.getListingCategories) { json, error in
            guard let listingCategoriesJSON = json?.array else {
                completion(nil, error)
                return
            }
            
            do {
                let listingCategories = try listingCategoriesJSON.map({try ListingCategory(json: $0)})
                completion(listingCategories, nil)
            } catch let error {
                print("couldn't create listing categories with JSON: \(json)")
                completion(nil, error)
            }
        }
    }
    
    static func GETListings(communityId: Int, completion: @escaping ([Listing]?, Error?) -> Void) {
        perform(requestExpectingResponse: MoochAPIRouter.getListings(forCommunityWithId: communityId)) { json, error in
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
    
    static func GETUser(withId id: Int, completion: @escaping (User?, Error?) -> Void) {
        perform(requestExpectingResponse: MoochAPIRouter.getUser(withId: id)) { json, error in
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
    
    //The completion Bool will be true on success, false on failure/error
    static func POSTListing(userId: Int, photo: UIImage, title: String, description: String?, price: Float, isFree: Bool, categoryId: Int, uploadProgressHandler: @escaping Request.ProgressHandler, completion: @escaping (Bool, JSON?, Error?) -> Void) {
        
        let route = MoochAPIRouter.postListing(userId: userId, title: title, description: description, price: price, isFree: isFree, categoryId: categoryId)
        let routingInformation = route.getRoutingInformation()
        
        var urlRequest: URLRequest!
        do {
            urlRequest = try route.asURLRequest()
        } catch(let error) {
            completion(false, nil, error)
            return
        }
        
        let authorizationHeaders = route.authorizationHeaders()
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                
                //Add image
                let resizedPhoto = photo.af_imageAspectScaled(toFit: MaxImageSize)
                if let imageData = UIImageJPEGRepresentation(resizedPhoto, 0.5)
                {
                    multipartFormData.append(imageData, withName: MoochAPIRouter.ParameterMapping.PostListing.photo.rawValue, fileName: "listing_image.jpeg", mimeType: "image/jpeg")
                }
                
                //Add the non-image parameters
                for (key, value) in routingInformation.parameters! {
                    let data = String(describing: value)
                    multipartFormData.append(data.data(using: .utf8)!, withName: key)
                }
            },
            usingThreshold: SessionManager.multipartFormDataEncodingMemoryThreshold,
            to: urlRequest.url!,
            method: routingInformation.method,
            headers: authorizationHeaders,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.uploadProgress(closure: uploadProgressHandler)
                    validate(dataRequestNotExpectingResponse: upload) { success, json, error in
                        completion(success, json, error)
                    }
                case .failure(let error):
                    completion(false, nil, error)
                }
            }
        )
    }
    
    static func POSTLogin(email: String, password: String, completion: @escaping (LocalUser?, Error?) -> Void) {
        perform(requestExpectingResponse: MoochAPIRouter.postLogin(withEmail: email, andPassword: password)) { json, error in
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

    //This method does all the same redundant work that would be shared between calls relying on a JSON response
    fileprivate static func perform(requestExpectingResponse: URLRequestConvertible, withCompletion completion: @escaping ExpectingResponseCompletionClosure) {
        let request = Alamofire.request(requestExpectingResponse)
        validate(dataRequestExpectingResponse: request, withCompletion: completion)
    }
    
    //This method does all the same redundant work that would be shared between calls NOT relying on a JSON response
    fileprivate static func perform(requestNotExpectingResponse: URLRequestConvertible, withCompletion completion: @escaping NotExpectingResponseCompletionClosure) {
        let request = Alamofire.request(requestNotExpectingResponse)
        validate(dataRequestNotExpectingResponse: request, withCompletion: completion)
    }
    
    //When EXPECTING a response, validates that a data request response status code is in the 200-299 range and returns the response into a success/fail bool, json, and error
    fileprivate static func validate(dataRequestExpectingResponse: DataRequest, withCompletion completion: @escaping ExpectingResponseCompletionClosure) {
        dataRequestExpectingResponse.validate().responseJSON { response in
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
    
    //When NOT expecting a response, validates that a data request response status code is in the 200-299 range and returns the response into a success/fail bool, json, and error
    fileprivate static func validate(dataRequestNotExpectingResponse: DataRequest, withCompletion completion: @escaping NotExpectingResponseCompletionClosure) {
        dataRequestNotExpectingResponse.validate().responseJSON { response in
            let error: Error? = response.result.error
            
            var json: JSON?
            if let responseResultValue = response.result.value {
                let responseJSON = JSON(responseResultValue)
                if responseJSON.error == nil {
                    json = responseJSON
                }
            }
            
            switch response.result {
            case .success:
                completion(true, json, error)
            case .failure(let error):
                completion(false, json, error)
            }
        }
    }
    
}
