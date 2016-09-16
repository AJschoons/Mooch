//
//  listingTest.swift
//  Mooch
//
//  Created by Zhiming Jiang on 9/11/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import XCTest

@testable import Mooch

class ListingTest: XCTestCase {
    
    
    
    func testCommunityDesignatedInit() {
        let contactInformation = User.ContactInformation(address: "#406", email: "test@wow.com", phone: "123-456-7890")
        let community = Community(id: 7, address: "123 LaSalle", name: "123 Big Apartments")
        let user = User(id: 5, name: "test", contactInformation: contactInformation, rating: 4.0, community: community)
        
        let listingTag = ListingTag(id: 4, name: "apple")
        let listing = Listing(id: 4, title: "apple", price: 2, isAvailable: false, owner: user, community: community, tag: listingTag)
        
        
        //Test that all the variables are correctly initialized
        XCTAssert(listing.id == 4)
        XCTAssert(listing.title == "apple")
        XCTAssert(listing.price == 2)
        
        XCTAssert(listing.owner.id == 5)
        XCTAssert(listing.owner.name == "test")
        XCTAssert(listing.owner.contactInformation.phone == "123-456-7890")
        XCTAssert(listing.owner.contactInformation.address == "#406")
        XCTAssert(listing.owner.contactInformation.email == "test@wow.com")
        
        XCTAssert(listing.community.id == 7)
        XCTAssert(listing.community.address == "123 LaSalle")
        XCTAssert(listing.community.name == "123 Big Apartments")
        
        XCTAssert(listing.tag.id == 4)
        XCTAssert(listing.tag.name == "apple")
    }
    
    //
    //rawValue turn in to string.
    func testConvenienceInitSuccess() {
        let communityJSONDict = [Community.JSONMapping.Id.rawValue : 7, Community.JSONMapping.Address.rawValue : "123 LaSalle", Community.JSONMapping.Name.rawValue : "123 Big Apartments"] as [String : Any]
        let userJSONDict = [User.JSONMapping.Id.rawValue : 4132, User.JSONMapping.Name.rawValue : "Bob the User", User.JSONMapping.Phone.rawValue : "123-456-6789", User.JSONMapping.Address.rawValue : "apt #406", User.JSONMapping.Email.rawValue : "doge@example.com", User.JSONMapping.Community.rawValue : communityJSONDict] as [String : Any]
        let listingTagJSON = [ListingTag.JSONMapping.Id.rawValue : 4, ListingTag.JSONMapping.Name.rawValue : "apple"] as [String : Any]
        
        let listingJSON: JSON = [Listing.JSONMapping.Id.rawValue : 4532, Listing.JSONMapping.Title.rawValue : "apple", Listing.JSONMapping.Price.rawValue : 2, Listing.JSONMapping.IsAvailable.rawValue : true, Listing.JSONMapping.Owner.rawValue : userJSONDict, Listing.JSONMapping.Community.rawValue : communityJSONDict, Listing.JSONMapping.Tag.rawValue : listingTagJSON]
        do {
            let listing = try Listing(json: listingJSON)
            
            XCTAssert(listing.id == 4532)
            XCTAssert(listing.title == "apple")
            XCTAssert(listing.price == 2)
            XCTAssert(listing.isAvailable == true)
            XCTAssert(listing.owner.id == 4132)
            XCTAssert(listing.owner.name == "Bob the User")
            XCTAssert(listing.owner.contactInformation.phone == "123-456-6789")
            XCTAssert(listing.owner.contactInformation.address == "apt #406")
            XCTAssert(listing.owner.contactInformation.email == "doge@example.com")
            
            
            XCTAssert(listing.community.id == 7)
            XCTAssert(listing.community.address == "123 LaSalle")
            XCTAssert(listing.community.name == "123 Big Apartments")
            
            XCTAssert(listing.tag.id == 4)
            XCTAssert(listing.tag.name == "apple")
        } catch {
            XCTFail()
        }
    }
    //
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
    //
    func testGettersSetters() {
        let contactInformation = User.ContactInformation(address: "#406", email: "test@wow.com", phone: "123-456-7890")
        let community = Community(id: 7, address: "123 LaSalle", name: "123 Big Apartments")
        
        let user = User(id: 5, name: "test", contactInformation: contactInformation,rating: 4.0, community: community)
        
        let listingTag = ListingTag(id: 4, name: "apple")
        var listing = Listing(id: 4, title: "apple", price: 2, isAvailable: true, owner: user, community: community, tag: listingTag)
        
        //Test getter
        
        XCTAssert(listing.id == 4)
        XCTAssert(listing.title == "apple")
        XCTAssert(listing.price == 2)
        
        
        XCTAssert(listing.owner.id == 5)
        XCTAssert(listing.owner.name == "test")
        XCTAssert(listing.owner.contactInformation.phone == "123-456-7890")
        XCTAssert(listing.owner.contactInformation.address == "#406")
        XCTAssert(listing.owner.contactInformation.email == "test@wow.com")
        
        XCTAssert(listing.community.id == 7)
        XCTAssert(listing.community.address == "123 LaSalle")
        XCTAssert(listing.community.name == "123 Big Apartments")
        
        XCTAssert(listing.tag.id == 4)
        XCTAssert(listing.tag.name == "apple")
        
        //Test setters
        
        //        listing.owner.name = "the new guy"
        //        let newCommunity = Community(id: 9, address: "new place", name: "new name")
        //        listing.owner.community = newCommunity
        
        //listing.id = 1
        //listing.tag.name = "banana"
        //listing.id = 2
        listing.title = "banana"
        let newListtag = ListingTag(id: 33, name: "banana")
        let newUser = User(id: 12, name: "jiang", contactInformation: contactInformation,rating: 4.0, community: community)
        
        let newList = Listing (id : 2, title : "banana", price : 3, isAvailable : true, owner : newUser, community : community, tag : newListtag)
        
        XCTAssert(newList.id == 2)
        XCTAssert(newList.title == "banana")
        XCTAssert(newList.price == 3)
        
        //  XCTAssert(newList.owner.name == "the new guy")
        
        XCTAssert(newList.community.id == 7)
        XCTAssert(newList.community.address == "123 LaSalle")
        XCTAssert(newList.community.name == "123 Big Apartments")
        
        XCTAssert(newList.tag.id == 33)
        XCTAssert(newList.tag.name == "banana")
        
        
    }
}
