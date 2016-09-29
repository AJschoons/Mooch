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
        let contactInformation = User.ContactInformation(address: "#406", email: "test@wow.com", phone: "123-456-7890")
        let community = Community.init(id: 7, address: "123 LaSalle", name: "123 Big Apartments",pictureURL:"sample pic")
        let loginInformation = User.LoginInformation(password:"birthday",passwordDigest:"digest",authenticationToken:"token")
        let user = User(id: 5, name: "test", contactInformation: contactInformation, currentRating: 4.5, ratingCount: 5, community: community, loginInformation: loginInformation, pictureURL: "sample person pic", thumbnailPictureURL: "small pic")
        let listingTag = ListingTag(id: 4, name: "apple",count: 3)
        let createDate = Date(dateString:"2014-06-06")
        let modifyDate = Date(dateString:"2016-07-06")
        let listing = Listing(id: 4, title: "apple", description: "nice apple", price: 2.0, isFree: false, isAvailable: true, createdAt: createDate as Date, modifiedAt: modifyDate as Date, owner: user, tags: [listingTag], community: community)
        
        //Test that all the variables are correctly initialized
        XCTAssert(listing.id == 4)
        XCTAssert(listing.title == "apple")
        XCTAssert(listing.description == "nice apple")
        XCTAssert(listing.price == 2.0)
        XCTAssert(listing.isFree == false)
        XCTAssert(listing.isAvailable == true)

        
        XCTAssert(listing.owner.id == 5)
        XCTAssert(listing.owner.name == "test")
        XCTAssert(listing.owner.contactInformation.phone == "123-456-7890")
        XCTAssert(listing.owner.contactInformation.address == "#406")
        XCTAssert(listing.owner.contactInformation.email == "test@wow.com")
        
        XCTAssert(listing.community?.id == 7)
        XCTAssert(listing.community?.address == "123 LaSalle")
        XCTAssert(listing.community?.name == "123 Big Apartments")
    }
    
    //Test that a listing is constructed without failing when given JSON with all the data it needs
    func testConvenienceInitSuccess() {
        let communityJSONDict = [Community.JSONMapping.id.rawValue : 1234, Community.JSONMapping.address.rawValue : "1234 address lane", Community.JSONMapping.name.rawValue : "highrise apartments",Community.JSONMapping.pictureURL.rawValue:"sample pic"] as [String : Any]
        let userJSONDict = [User.JSONMapping.id.rawValue : 4132, User.JSONMapping.name.rawValue : "Bob the User",  User.JSONMapping.email.rawValue : "doge@example.com", User.JSONMapping.currentRating.rawValue : 4.5, User.JSONMapping.ratingCount.rawValue : 5, User.JSONMapping.community.rawValue : communityJSONDict] as [String : Any]
//        
        
        let listingTagJSONDict = [ListingTag.JSONMapping.id.rawValue : 4, ListingTag.JSONMapping.name.rawValue : "apple",ListingTag.JSONMapping.count.rawValue : 4] as [String : Any]
        
        let listingJSON: JSON = [Listing.JSONMapping.id.rawValue : 4532, Listing.JSONMapping.title.rawValue : "apple",Listing.JSONMapping.description.rawValue:"good apple", Listing.JSONMapping.price.rawValue : 2, Listing.JSONMapping.isFree.rawValue: true, Listing.JSONMapping.isAvailable.rawValue : true, Listing.JSONMapping.createdAt.rawValue : "2016-09-24T00:12:55.000Z",Listing.JSONMapping.modifiedAt.rawValue : "2016-09-24T00:12:55.000Z", Listing.JSONMapping.owner.rawValue : userJSONDict, Listing.JSONMapping.tags.rawValue : [listingTagJSONDict]]
        


        
        do {
            let listing = try Listing(json: listingJSON)
//            //Test that all the variables are correctly initialized
            XCTAssert(listing.id == 4532)
            XCTAssert(listing.title == "apple")
            XCTAssert(listing.price == 2)
            XCTAssert(listing.isAvailable == true)
            XCTAssert(listing.owner.id == 4132)
            XCTAssert(listing.owner.name == "Bob the User")
            XCTAssert(listing.owner.contactInformation.email == "doge@example.com")
            
//
            XCTAssert(listing.owner.community?.id == 1234)
            XCTAssert(listing.owner.community?.address == "1234 address lane")
            XCTAssert(listing.owner.community?.name == "highrise apartments")
            
            XCTAssert(listing.tags[0].id == 4)
            XCTAssert(listing.tags[0].name == "apple")
        } catch {
            XCTFail()
        }
    }
    
    //Test that a Listing throws the expected error when it doesn't have all the data it needs
    func testConvenienceInitError() {
        let listJSONDict: JSON = ["id" : 41]
        
        var jsonErrorThrown = false
        
        do {
            let _ = try User(json: listJSONDict)
            XCTFail()
        } catch InitializationError.insufficientJSONInformationForInitialization {
            jsonErrorThrown = true
        } catch {
            
        }
        XCTAssert(jsonErrorThrown)
    }
    
    func testGettersSetters() {

        let contactInformation = User.ContactInformation(address: "#406", email: "test@wow.com", phone: "123-456-7890")
        let community = Community(id: 7, address: "123 LaSalle", name: "123 Big Apartments",pictureURL:"sample pic")
        let loginInformation = User.LoginInformation(password:"birthday",passwordDigest:"digest",authenticationToken:"token")

        let user = User(id: 5, name: "test", contactInformation: contactInformation, currentRating: 4.5, ratingCount: 5, community: community, loginInformation: loginInformation, pictureURL: "sample person pic", thumbnailPictureURL: "small pic")
        let listingTag = ListingTag(id: 4, name: "apple",count: 3)
        let createDate = Date(dateString:"2014-06-06")
        let modifyDate = Date(dateString:"2016-07-06")
        var listing = Listing(id: 4, title: "apple", description: "nice apple", price: 2.0, isFree: false, isAvailable: true, createdAt: createDate as Date, modifiedAt: modifyDate as Date, owner: user, tags: [listingTag], community: community)
        
        //Test getter
        XCTAssert(listing.id == 4)
        XCTAssert(listing.title == "apple")
        XCTAssert(listing.price == 2)
        
        XCTAssert(listing.owner.id == 5)
        XCTAssert(listing.owner.name == "test")
        XCTAssert(listing.owner.contactInformation.phone == "123-456-7890")
        XCTAssert(listing.owner.contactInformation.address == "#406")
        XCTAssert(listing.owner.contactInformation.email == "test@wow.com")
        
        XCTAssert(listing.community?.id == 7)
        XCTAssert(listing.community?.address == "123 LaSalle")
        XCTAssert(listing.community?.name == "123 Big Apartments")

        listing.title = "banana"
        _ = User(id: 12, name: "jiang", contactInformation: contactInformation, currentRating: 4.5, ratingCount: 5, community: community, loginInformation: loginInformation, pictureURL: "sample person pic", thumbnailPictureURL: "small pic")
        
        let newList = Listing(id: 2, title: "banana", description: "nice apple", price: 3, isFree: false, isAvailable: true, createdAt: createDate as Date, modifiedAt: modifyDate as Date, owner: user, tags: [listingTag], community: community)
        //Test setters
        XCTAssert(newList.id == 2)
        XCTAssert(newList.title == "banana")
        XCTAssert(newList.price == 3)
        
        XCTAssert(newList.community?.id == 7)
        XCTAssert(newList.community?.address == "123 LaSalle")
        XCTAssert(newList.community?.name == "123 Big Apartments")
        
        
    }
}
