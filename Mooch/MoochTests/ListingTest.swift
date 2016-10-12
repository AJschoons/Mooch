//
//  listingTest.swift
//  Mooch
//
//  Created by Zhiming Jiang on 9/11/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import XCTest
//import UIKit
@testable import Mooch


extension Date
{
    init(dateString:String) {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = "yyyy-MM-dd"
        dateStringFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale!
        let d = dateStringFormatter.date(from: dateString)!
        self.init(timeInterval:0, since:d)    }
}

class ListingTest: XCTestCase {

    
    func testCommunityDesignatedInit() {
        let photoImage = UIImage(named: "apples")

        let contactInformation = User.ContactInformation(address: "#406", email: "test@wow.com", phone: "123-456-7890")
        let user = User(id: 5, name: "test", contactInformation: contactInformation, currentRating: 4.5, ratingCount: 5, communityId:4 , pictureURL: "sample person pic", thumbnailPictureURL: "small pic")
        let createDate = Date(dateString:"2014-06-06")
        let modifyDate = Date(dateString:"2016-07-06")
        
        let listing = Listing(id: 4, photo:photoImage,title: "apple", description: "nice apple", price: 2.0, isFree: false, quantity: 2, categoryId: 3, isAvailable: true, createdAt: createDate as Date, modifiedAt: modifyDate as Date, owner: user, pictureURL: "picture",thumbnailPictureURL: "thumbPic", communityId: 4)
        
        //Test that all the variables are correctly initialized
        XCTAssert(listing.id == 4)
        XCTAssert(listing.title == "apple")
        XCTAssert(listing.description == "nice apple")
        XCTAssert(listing.price == 2.0)
        XCTAssert(listing.isFree == false)
        XCTAssert(listing.isAvailable == true)
        XCTAssert(listing.thumbnailPictureURL == "thumbPic")

        
        XCTAssert(listing.owner.id == 5)
        XCTAssert(listing.owner.name == "test")
        XCTAssert(listing.owner.contactInformation.phone == "123-456-7890")
        XCTAssert(listing.owner.contactInformation.address == "#406")
        XCTAssert(listing.owner.contactInformation.email == "test@wow.com")
        

    }
    
    //Test that a listing is constructed without failing when given JSON with all the data it needs
    func testConvenienceInitSuccess() {
        let userJSONDict = [User.JSONMapping.id.rawValue : 4132, User.JSONMapping.name.rawValue : "Bob the User",  User.JSONMapping.email.rawValue : "doge@example.com", User.JSONMapping.currentRating.rawValue : 4.5, User.JSONMapping.ratingCount.rawValue : 5, User.JSONMapping.communityId.rawValue : 4] as [String : Any]

        let listingJSON: JSON = [
                                 Listing.JSONMapping.id.rawValue : 4532,
                                 Listing.JSONMapping.title.rawValue : "apple",
                                 Listing.JSONMapping.price.rawValue : 2,
                                 Listing.JSONMapping.isFree.rawValue: true,
                                 Listing.JSONMapping.quantity.rawValue : 2,
                                 Listing.JSONMapping.categoryId.rawValue : 4,
                                 Listing.JSONMapping.isAvailable.rawValue : true,
                                 Listing.JSONMapping.createdAt.rawValue : "2016-09-24T00:12:55.000Z",
                                 Listing.JSONMapping.pictureURL.rawValue : "picture",
                                 Listing.JSONMapping.thumbnailPictureURL.rawValue : "thumbPic",
                                 Listing.JSONMapping.communityId.rawValue : 5,
                                 Listing.JSONMapping.owner.rawValue : userJSONDict
                                ]
        


        
        do {
            let listing = try Listing(json: listingJSON)
//            //Test that all the variables are correctly initialized
            XCTAssert(listing.id == 4532)
            XCTAssert(listing.title == "apple")
            XCTAssert(listing.quantity == 2)
            XCTAssert(listing.isAvailable == true)
            XCTAssert(listing.owner.id == 4132)
            XCTAssert(listing.owner.name == "Bob the User")
            XCTAssert(listing.owner.contactInformation.email == "doge@example.com")
            XCTAssert(listing.communityId == 5)

        } catch {
            XCTFail()
        }
    }
    
    //Test that a Listing throws the expected error when it doesn't have all the data it needs
    func testConvenienceIdError() {
        let listJSONDictionTestid: JSON = ["id" : 41]
        
        var jsonErrorThrown = false
        
        do {
            let _ = try Listing(json: listJSONDictionTestid)
            XCTFail()
        } catch Listing.JSONInitializationError.title {
            jsonErrorThrown = true
        } catch {
            
        }
        XCTAssert(jsonErrorThrown)
        
    }
    func testConvenienceTitleError() {

        let listJSONDictionTestName: JSON = [Listing.JSONMapping.id.rawValue : 4532,Listing.JSONMapping.title.rawValue : "apple"]
        
        var jsonErrorThrown = false
        
        do {
            let _ = try Listing(json: listJSONDictionTestName)
            XCTFail()
        } catch Listing.JSONInitializationError.price {
            jsonErrorThrown = true
        } catch {
            
        }
        XCTAssert(jsonErrorThrown)
        
    }
    
    func testConveniencePriceError() {
        let listJSONDictionTestPrice : JSON = [Listing.JSONMapping.id.rawValue : 4532,Listing.JSONMapping.title.rawValue : "apple", Listing.JSONMapping.price.rawValue : 2]
        var jsonErrorThrown = false
        
        do {
            let _ = try Listing(json: listJSONDictionTestPrice)
            XCTFail()
        } catch Listing.JSONInitializationError.isFree {
            jsonErrorThrown = true
        } catch {
            
        }
        XCTAssert(jsonErrorThrown)
        
    }
    
    func testConvenienceIsFreeError() {
        let listJSONDictionTestIsFree : JSON = [Listing.JSONMapping.id.rawValue : 4532,Listing.JSONMapping.title.rawValue : "apple", Listing.JSONMapping.price.rawValue : 2, Listing.JSONMapping.isFree.rawValue : true]
        var jsonErrorThrown = false
        
        do {
            let _ = try Listing(json: listJSONDictionTestIsFree)
            XCTFail()
        } catch Listing.JSONInitializationError.quantity {
            jsonErrorThrown = true
        } catch {
            
        }
        XCTAssert(jsonErrorThrown)
        
    }
    
   
    
    func testConvenienceQuantityError() {
        let listJSONDictionTestQuantity : JSON = [Listing.JSONMapping.id.rawValue : 4532,Listing.JSONMapping.title.rawValue : "apple", Listing.JSONMapping.price.rawValue : 2, Listing.JSONMapping.isFree.rawValue : true, Listing.JSONMapping.quantity.rawValue : 2]
        
        var jsonErrorThrown = false
        
        do {
            let _ = try Listing(json: listJSONDictionTestQuantity)
            XCTFail()
        } catch Listing.JSONInitializationError.categoryId {
            jsonErrorThrown = true
        } catch {
            
        }
        XCTAssert(jsonErrorThrown)
    }
    
    func testConvenienceCategoryIdError() {
        let listJSONDictionTestCategory : JSON = [Listing.JSONMapping.id.rawValue : 4532,Listing.JSONMapping.title.rawValue : "apple", Listing.JSONMapping.price.rawValue : 2, Listing.JSONMapping.isFree.rawValue : true,  Listing.JSONMapping.quantity.rawValue: 2, Listing.JSONMapping.categoryId.rawValue : 4]

        var jsonErrorThrown = false
        
        do {
            let _ = try Listing(json: listJSONDictionTestCategory)
            XCTFail()
        } catch Listing.JSONInitializationError.isAvailable {
            jsonErrorThrown = true
        } catch {
            
        }
        XCTAssert(jsonErrorThrown)
    }
    
    func testConvenienceIsAvailableError() {
        
        let listJSONDictionTestIsAvailable : JSON = [Listing.JSONMapping.id.rawValue : 4532,Listing.JSONMapping.title.rawValue : "apple", Listing.JSONMapping.price.rawValue : 2, Listing.JSONMapping.isFree.rawValue : true,  Listing.JSONMapping.quantity.rawValue: 2, Listing.JSONMapping.categoryId.rawValue : 4, Listing.JSONMapping.isAvailable.rawValue : true]
        
        var jsonErrorThrown = false
        
        do {
            let _ = try Listing(json: listJSONDictionTestIsAvailable)
            XCTFail()
        } catch Listing.JSONInitializationError.createdAt {
            jsonErrorThrown = true
        } catch {
            
        }
        XCTAssert(jsonErrorThrown)
        
    }
    
    
    func testConvenienceCreateAtError() {
        let listJSONDictionTestPictureURL : JSON = [Listing.JSONMapping.id.rawValue : 4532,Listing.JSONMapping.title.rawValue : "apple", Listing.JSONMapping.price.rawValue : 2, Listing.JSONMapping.isFree.rawValue : true,  Listing.JSONMapping.quantity.rawValue: 2, Listing.JSONMapping.categoryId.rawValue : 4, Listing.JSONMapping.isAvailable.rawValue : true, Listing.JSONMapping.createdAt.rawValue : "2016-09-24T00:12:55.000Z"]
        
        var jsonErrorThrown = false
        
        do {
            let _ = try Listing(json: listJSONDictionTestPictureURL)
            XCTFail()
        } catch Listing.JSONInitializationError.pictureURL {
            jsonErrorThrown = true
        } catch {
            
        }
        XCTAssert(jsonErrorThrown)
    }
    
    func testConveniencePictureURLError() {
        let listJSONDictionTestPictureURL : JSON = [Listing.JSONMapping.id.rawValue : 4532,Listing.JSONMapping.title.rawValue : "apple", Listing.JSONMapping.price.rawValue : 2, Listing.JSONMapping.isFree.rawValue : true,  Listing.JSONMapping.quantity.rawValue: 2, Listing.JSONMapping.categoryId.rawValue : 4, Listing.JSONMapping.isAvailable.rawValue : true, Listing.JSONMapping.createdAt.rawValue : "2016-09-24T00:12:55.000Z", Listing.JSONMapping.pictureURL.rawValue : "picture"]
        
        var jsonErrorThrown = false
        
        do {
            let _ = try Listing(json: listJSONDictionTestPictureURL)
            XCTFail()
        } catch Listing.JSONInitializationError.communityId {
            jsonErrorThrown = true
        } catch {
            
        }
        XCTAssert(jsonErrorThrown)
    }
    
    
    func testConvenienceCommunityIdError() {
        let listJSONDictionTestCommunityId : JSON = [Listing.JSONMapping.id.rawValue : 4532,Listing.JSONMapping.title.rawValue : "apple", Listing.JSONMapping.price.rawValue : 2, Listing.JSONMapping.isFree.rawValue : true,  Listing.JSONMapping.quantity.rawValue: 2, Listing.JSONMapping.categoryId.rawValue : 4, Listing.JSONMapping.isAvailable.rawValue : true, Listing.JSONMapping.createdAt.rawValue : "2016-09-24T00:12:55.000Z", Listing.JSONMapping.pictureURL.rawValue : "picture", Listing.JSONMapping.communityId.rawValue : 5]
        
        var jsonErrorThrown = false
        
        do {
            let _ = try Listing(json: listJSONDictionTestCommunityId)
            XCTFail()
        } catch Listing.JSONInitializationError.owner {
            jsonErrorThrown = true
        } catch {
            
        }
        XCTAssert(jsonErrorThrown)
    }
    
    
    func testConvenienceInitError() {
        //let userJSONDict = [User.JSONMapping.id.rawValue : 4132, User.JSONMapping.name.rawValue : "Bob the User",  User.JSONMapping.email.rawValue : "doge@example.com", User.JSONMapping.currentRating.rawValue : 4.5, User.JSONMapping.ratingCount.rawValue : 5, User.JSONMapping.communityId.rawValue : 4] as [String : Any]
        let listJSONDictionTestOwner: JSON = [
            Listing.JSONMapping.id.rawValue : 4532,
            Listing.JSONMapping.title.rawValue : "apple",
            Listing.JSONMapping.price.rawValue : 2,
            Listing.JSONMapping.isFree.rawValue: true,
            Listing.JSONMapping.quantity.rawValue : 2,
            Listing.JSONMapping.categoryId.rawValue : 4,
            Listing.JSONMapping.isAvailable.rawValue : true,
            Listing.JSONMapping.createdAt.rawValue : "2016-09-24T00:12:55.000Z",
            Listing.JSONMapping.pictureURL.rawValue : "picture",
            Listing.JSONMapping.communityId.rawValue : 5,
            //Listing.JSONMapping.owner.rawValue : userJSONDict
        ]
        var jsonErrorThrown = false
        
        do {
            let _ = try Listing(json: listJSONDictionTestOwner)
            XCTFail()
        } catch Listing.JSONInitializationError.owner {
            jsonErrorThrown = true
        } catch {
        }
        XCTAssert(jsonErrorThrown)
    }

    
    func testGettersSetters() {
        let photoImage = UIImage(named: "apples")
        let contactInformation = User.ContactInformation(address: "#406", email: "test@wow.com", phone: "123-456-7890")
        let user = User(id: 5, name: "test", contactInformation: contactInformation, currentRating: 4.5, ratingCount: 5, communityId: 7, pictureURL: "sample person pic", thumbnailPictureURL: "small pic")
       
        let createDate = Date(dateString:"2014-06-06")
        let modifyDate = Date(dateString:"2016-07-06")
        
        var listing = Listing(id: 4, photo:photoImage,title: "apple", description: "nice apple", price: 2.0, isFree: false, quantity: 2, categoryId: 3, isAvailable: true, createdAt: createDate as Date, modifiedAt: modifyDate as Date, owner: user, pictureURL: "picture",thumbnailPictureURL: "thumbPic", communityId: 4)
        
        
        //Test getter
        XCTAssert(listing.id == 4)
        XCTAssert(listing.title == "apple")
        XCTAssert(listing.price == 2)
        XCTAssert(listing.thumbnailPictureURL == "thumbPic")

        XCTAssert(listing.owner.id == 5)
        XCTAssert(listing.owner.name == "test")
        XCTAssert(listing.owner.contactInformation.phone == "123-456-7890")
        XCTAssert(listing.owner.contactInformation.address == "#406")
        XCTAssert(listing.owner.contactInformation.email == "test@wow.com")

        

        listing.title = "banana"
        _ = User(id: 12, name: "jiang", contactInformation: contactInformation,currentRating: 4.5, ratingCount: 9, communityId : 11, pictureURL: "sample person pic", thumbnailPictureURL: "small pic")
        
        let newList = Listing(id: 2, photo: photoImage, title: "banana", description: "nice apple", price: 3, isFree: false, quantity: 2, categoryId: 13, isAvailable: true, createdAt: createDate as Date, modifiedAt: modifyDate as Date, owner: user, pictureURL: "picture",thumbnailPictureURL: "thumbPic", communityId: 11)
        
        //Test setters
        XCTAssert(newList.id == 2)
        XCTAssert(newList.title == "banana")
        XCTAssert(newList.price == 3)
        XCTAssert(newList.pictureURL == "picture")
        XCTAssert(newList.categoryId == 13)

        
    }

}
