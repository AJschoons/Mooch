//
//  MoochAPI.swift
//  Mooch
//
//  Created by adam on 9/9/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import Alamofire
import AVFoundation
import Foundation

class MoochAPI {
    
    static let MaxImageSizeRect = CGRect(x: 0, y: 0, width: 540, height: 540)
    static let ImageCompressionFactor = CGFloat(0.5)
    
    typealias ExpectingResponseCompletionClosure = (JSON?, Error?) -> ()
    typealias NotExpectingResponseCompletionClosure = (Bool, JSON?, Error?) -> () //Bool: Success/Fail
    typealias UploadRequestCompletion = (UploadRequest?, Error?) -> ()
    
    //Allows authorized requests to be performed
    static func setAuthorizationCredentials(email: String, authorizationToken: String) {
        MoochAPIRouter.setAuthorizationCredentials(email: email, authorizationToken: authorizationToken)
    }
    
    //Clears the authorization credentials for when a user logs out
    static func clearAuthorizationCredentials() {
        MoochAPIRouter.clearAuthorizationCredentials()
    }
    
    //
    // MARK: API Routes
    //
    
    static func DELETEListing(ownerId: Int, listingId: Int, completion: @escaping (Bool, Error?) -> Void) {
        perform(requestNotExpectingResponse: MoochAPIRouter.deleteListing(ownerId: ownerId, listingId: listingId)) { success, json, error in
            completion(success, error)
        }
    }
    
    static func GETCommunities(completion: @escaping ([Community]?, Error?) -> Void) {
        perform(requestExpectingResponse: MoochAPIRouter.getCommunities) { json, error in
            guard let communitiesJSON = json?.array else {
                completion(nil, error)
                return
            }
            
            do {
                let communities = try communitiesJSON.map({try Community(json: $0)})
                completion(communities, nil)
            } catch let error {
                print("couldn't create communities with JSON: \(json)")
                completion(nil, error)
            }
        }
    }
    
    static func GETExchangeAccept(listingOwnerId: Int, listingId: Int, exchangeId: Int, completion: @escaping (Bool, Error?) -> Void) {
        perform(requestNotExpectingResponse: MoochAPIRouter.getExchangeAccept(listingOwnerId: listingOwnerId, listingId: listingId, exchangeId: exchangeId)) { success, json, error in
            completion(success, error)
        }
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
            let processedResult = processUser(fromJSON: json, withError: error)
            let user = processedResult.0
            let error = processedResult.1
            completion(user, error)
        }
    }
    
    //This will clear the authorization of the API Router; should only be used when there isn't already authorization
    //Example: when the app first opens and we need to log in a saved user
    static func GETUserOnce(withId id: Int, email: String, authorizationToken: String, completion: @escaping (User?, Error?) -> Void) {
        perform(requestExpectingResponse: MoochAPIRouter.getUserOnce(withId: id, email: email, authorizationToken: authorizationToken)) { json, error in
            let processedResult = processUser(fromJSON: json, withError: error)
            let user = processedResult.0
            let error = processedResult.1
            completion(user, error)
        }
    }
    
    static func GETListingVisit(listingId: Int, completion: @escaping (Bool, Error?) -> Void) {
        perform(requestNotExpectingResponse: MoochAPIRouter.getVisit(listingId: listingId)) { success, json, error in
            completion(success, error)
        }
    }
    
    static func POSTExchange(listingOwnerId: Int, listingId: Int, completion: @escaping (Bool, Error?) -> Void) {
        perform(requestNotExpectingResponse: MoochAPIRouter.postExchange(listingOwnerId: listingOwnerId, listingId: listingId)) { success, json, error in
            completion(success, error)
        }
    }
    
    //The completion Bool will be true on success, false on failure/error
    static func POSTListing(userId: Int, photo: UIImage, title: String, description: String?, price: Float, isFree: Bool, quantity: Int, categoryId: Int, uploadProgressHandler: @escaping Request.ProgressHandler, completion: @escaping (Bool, JSON?, Error?) -> Void) {
        
        let route = MoochAPIRouter.postListing(userId: userId, title: title, description: description, price: price, isFree: isFree, quantity: quantity, categoryId: categoryId)
        
        performMultipartFormUpload(forRoute: route, withImage: photo, imageFormParameterName: MoochAPIRouter.ParameterMapping.PostListing.photo.rawValue, imageFileName: Strings.MoochAPI.listingImageFilename.rawValue) { uploadRequest, error in
            
            guard let uploadRequest = uploadRequest else {
                completion(false, nil, error)
                return
            }
            
            uploadRequest.uploadProgress(closure: uploadProgressHandler)
            validate(dataRequestNotExpectingResponse: uploadRequest) { success, json, error in
                completion(success, json, error)
            }
        }
    }
    
    static func POSTLogin(email: String, password: String, completion: @escaping (LocalUser?, Error?) -> Void) {
        perform(requestExpectingResponse: MoochAPIRouter.postLogin(withEmail: email, andPassword: password)) { json, error in
            let processedResult = processLocalUser(fromJSON: json, withError: error)
            let localUser = processedResult.0
            let error = processedResult.1
            completion(localUser, error)
        }
    }
    
    //The completion Bool will be true on success, false on failure/error
    static func POSTUser(communityId: Int, photo: UIImage, name: String, email: String, phone: String, password: String, address: String?, uploadProgressHandler: @escaping Request.ProgressHandler, completion: @escaping (LocalUser?, Error?) -> Void) {
        
        let route = MoochAPIRouter.postUser(communityId: communityId, name: name, email: email, phone: phone, password: password, address: address)
        
        performMultipartFormUpload(forRoute: route, withImage: photo, imageFormParameterName: MoochAPIRouter.ParameterMapping.PostUser.photo.rawValue, imageFileName: Strings.MoochAPI.userImageFilename.rawValue) { uploadRequest, error in
            
            guard let uploadRequest = uploadRequest else {
                completion(nil, error)
                return
            }
            
            uploadRequest.uploadProgress(closure: uploadProgressHandler)
            validate(dataRequestExpectingResponse: uploadRequest) { json, error in
                let processedResult = processLocalUser(fromJSON: json, withError: error)
                let localUser = processedResult.0
                let error = processedResult.1
                completion(localUser, error)
            }
        }
    }

    
    //
    // MARK: Helpers
    //
    
    fileprivate static func processUser(fromJSON json: JSON?, withError error: Error?) -> (User?, Error?) {
        guard let json = json else {
            return (nil, error)
        }
        
        do {
            let user = try User(json: json)
            return (user, nil)
        } catch let error {
            print("couldn't create user with JSON: \(json)")
            return (nil, error)
        }
    }
    
    fileprivate static func processLocalUser(fromJSON json: JSON?, withError error: Error?) -> (LocalUser?, Error?) {
        guard let localUserJSON = json else {
            return (nil, error)
        }
        
        do {
            let localUser = try LocalUser(json: localUserJSON)
            return (localUser, nil)
        } catch let error {
            print("couldn't create local user with JSON: \(json)")
            return (nil, error)
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
    
    //Takes the parameters from the route and the image and encodes them into an UploadRequest
    fileprivate static func performMultipartFormUpload(forRoute route: MoochAPIRouter, withImage image: UIImage, imageFormParameterName: String, imageFileName: String, completion: @escaping UploadRequestCompletion) {
        let routingInformation = route.getRoutingInformation()
        
        var urlRequest: URLRequest!
        do {
            urlRequest = try route.asURLRequest()
        } catch(let error) {
            completion(nil, error)
            return
        }
        
        let authorizationHeaders = route.authorizationHeaders()
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                
                //Add image
                let aspectRatioRect = AVMakeRect(aspectRatio: image.size, insideRect: MaxImageSizeRect)
                let resizedImage = image.af_imageAspectScaled(toFit: aspectRatioRect.size)
                if let imageData = UIImageJPEGRepresentation(resizedImage, ImageCompressionFactor)
                {
                    multipartFormData.append(imageData, withName: imageFormParameterName, fileName: imageFileName, mimeType: "image/jpeg")
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
                    completion(upload, nil)
                case .failure(let error):
                    completion(nil, error)
                }
            }
        )
    }
}
