//
//  searchFilterTest.swift
//  Mooch
//
//  Created by Zhiming Jiang on 10/21/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import XCTest

class SearchFilterTest: XCTestCase {

    func testSortOrderByPrice() {
        let contactInformation = User.ContactInformation(address: "#406", email: "test@wow.com", phone: "123-456-7890")
        let photoImage1 = UIImage(named: "apples")
        let photoImage2 = UIImage(named: "banana")
        let photoImage3 = UIImage(named: "banana")
        let user = User(id: 5, name: "test", contactInformation: contactInformation, communityId:4 , pictureURL: "sample person pic", thumbnailPictureURL: "small pic")
        
        let createDate = Date(dateString:"2015-06-06")
        
        let modifyDate = Date(dateString:"2015-07-06")
        
        let createDate1 = Date(dateString:"2014-07-06")
        
        let modifyDate1 = Date(dateString:"2016-08-06")
        
        let createDate2 = Date(dateString:"2014-09-06")
        
        let modifyDate2 = Date(dateString:"2014-10-06")
        
        let listingApple = Listing(id: 1, photo:photoImage1,title: "apple", description: "nice apple", price: 1.0, isFree: false, quantity: 2, categoryId: 3, isAvailable: true, createdAt: createDate as Date, modifiedAt: modifyDate as Date, owner: user, pictureURL: "picture",thumbnailPictureURL: "thumbPic", communityId: 4)
    
        let listingBanana = Listing(id: 2, photo:photoImage2,title: "banana", description: "nice banana", price: 2.0, isFree: false, quantity: 2, categoryId: 3, isAvailable: true, createdAt: createDate1 as Date, modifiedAt: modifyDate1 as Date, owner: user, pictureURL: "picture",thumbnailPictureURL: "thumbPic", communityId: 4)
    
        
        let listingPair = Listing(id: 3, photo:photoImage3,title: "Pair", description: "nice Pair", price: 3.0, isFree: false, quantity: 2, categoryId: 3, isAvailable: true, createdAt: createDate2 as Date, modifiedAt: modifyDate2 as Date, owner: user, pictureURL: "picture",thumbnailPictureURL: "thumbPic", communityId: 4)
        
        var lists : [Listing] = []
        lists.append(listingApple)
        lists.append(listingBanana)
        lists.append(listingPair)

        var filter = ListingFilter()
        //let sortOrder = SortOrder()
        filter.sortByOption = .lowestPrice
        var sortedLists : [Listing]
        sortedLists = ListingProcessingHandler.sortPriceLowerToHigh(listings: lists)

        XCTAssert(sortedLists[0].price == 1.0)
        XCTAssert(sortedLists[2].price == 3.0)
        sortedLists = ListingProcessingHandler.sortPriceHighToLower(listings: lists)
        XCTAssert(sortedLists[0].price == 3.0)
        XCTAssert(sortedLists[2].price == 1.0)
        sortedLists = ListingProcessingHandler.newest(listings: lists)
        
        //create order 132 (apple, pair, banana)
        XCTAssert(sortedLists[0].id == 1)
        XCTAssert(sortedLists[1].id == 3)
        XCTAssert(sortedLists[2].id == 2)
    }
    
    func testSortByCategory() {
        let contactInformation = User.ContactInformation(address: "#406", email: "test@wow.com", phone: "123-456-7890")
        let photoImage1 = UIImage(named: "apples")
        let photoImage2 = UIImage(named: "banana")
        let photoImage3 = UIImage(named: "banana")
        let user = User(id: 5, name: "test", contactInformation: contactInformation, communityId:4 , pictureURL: "sample person pic", thumbnailPictureURL: "small pic")
        
        let createDate = Date(dateString:"2015-06-06")
        let modifyDate = Date(dateString:"2015-07-06")
        let createDate1 = Date(dateString:"2014-07-06")
        let modifyDate1 = Date(dateString:"2016-08-06")
        let createDate2 = Date(dateString:"2014-09-06")
        let modifyDate2 = Date(dateString:"2014-10-06")
        
        let listingApple = Listing(id: 1, photo:photoImage1,title: "apple", description: "nice apple", price: 1.0, isFree: false, quantity: 2, categoryId: 3, isAvailable: true, createdAt: createDate as Date, modifiedAt: modifyDate as Date, owner: user, pictureURL: "picture",thumbnailPictureURL: "thumbPic", communityId: 4)
        
        let listingBanana = Listing(id: 2, photo:photoImage2,title: "banana", description: "nice banana", price: 2.0, isFree: false, quantity: 2, categoryId: 3, isAvailable: true, createdAt: createDate1 as Date, modifiedAt: modifyDate1 as Date, owner: user, pictureURL: "picture",thumbnailPictureURL: "thumbPic", communityId: 4)
        
        
        let listingPair = Listing(id: 3, photo:photoImage3,title: "Pair", description: "nice Pair", price: 3.0, isFree: false, quantity: 2, categoryId: 3, isAvailable: true, createdAt: createDate2 as Date, modifiedAt: modifyDate2 as Date, owner: user, pictureURL: "picture",thumbnailPictureURL: "thumbPic", communityId: 4)
        
        let listingChips = Listing(id: 3, photo:photoImage3,title: "Chips", description: "nice Chips", price: 3.0, isFree: false, quantity: 2, categoryId: 2, isAvailable: true, createdAt: createDate2 as Date, modifiedAt: modifyDate2 as Date, owner: user, pictureURL: "picture",thumbnailPictureURL: "thumbPic", communityId: 4)
        
        let listingEnergyBar = Listing(id: 3, photo:photoImage3,title: "EnergyBar", description: "nice EnergyBar", price: 3.0, isFree: false, quantity: 2, categoryId: 2, isAvailable: true, createdAt: createDate2 as Date, modifiedAt: modifyDate2 as Date, owner: user, pictureURL: "picture",thumbnailPictureURL: "thumbPic", communityId: 4)

        var lists : [Listing] = []
        lists.append(listingApple)
        lists.append(listingBanana)
        lists.append(listingPair)
        lists.append(listingEnergyBar)
        lists.append(listingChips)

        let categoryFruit = ListingCategory.init(id: 3, name: "fruit")
        var filter = ListingFilter()
        filter.category = categoryFruit
        //let sortCategory = SortCategory()
        
        var sortedLists : [Listing]
        sortedLists = ListingProcessingHandler.sortByCategory(listings: lists,with: filter)
        XCTAssert(sortedLists.count == 3)// three fruit
        
        let categorySnack = ListingCategory.init(id: 2, name: "snack")
        filter.category = categorySnack
//        let sortCategory2 = SortCategory()
        var sortedLists2 : [Listing]
        sortedLists2 = ListingProcessingHandler.sortByCategory(listings: lists,with: filter)
        XCTAssert(sortedLists2.count == 2)// two snack

        
        let categoryDairy = ListingCategory.init(id: 1, name: "Dairy")
        filter.category = categoryDairy
//        let sortCategory1 = SortCategory()
        var sortedLists1 : [Listing]
        sortedLists1 = ListingProcessingHandler.sortByCategory(listings: lists,with: filter)
        XCTAssert(sortedLists1.count == 0)// none dairy
    }

    func testSortByExpireDay() {
        let contactInformation = User.ContactInformation(address: "#406", email: "test@wow.com", phone: "123-456-7890")
        let photoImage1 = UIImage(named: "apples")
        let photoImage2 = UIImage(named: "banana")
        let photoImage3 = UIImage(named: "banana")
        let user = User(id: 5, name: "test", contactInformation: contactInformation, communityId:4 , pictureURL: "sample person pic", thumbnailPictureURL: "small pic")
        

        
        var date1 = Date()
        date1 = date1.addDays(daysToAdd: -3)
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "yyyy-MM-dd"
        let dateString2 = dateFormatter1.string(from: date1)
        
        let createDate = Date(dateString:dateString2)
        let modifyDate = Date(dateString:"2016-10-19")

        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString1 = dateFormatter.string(from: date)
        
        let createDate1 = Date(dateString: dateString1)
        let modifyDate1 = Date(dateString:"2016-10-22")
        
        
        var date3 = Date()
        date3 = date3.addDays(daysToAdd: -15)

        let dateFormatter3 = DateFormatter()
        dateFormatter3.dateFormat = "yyyy-MM-dd"
        let dateString3 = dateFormatter.string(from: date3)
        
        let createDate2 = Date(dateString:dateString3)
        let modifyDate2 = Date(dateString:"2016-10-14")
        
        let listingApple = Listing(id: 1, photo:photoImage1,title: "apple", description: "nice apple", price: 1.0, isFree: false, quantity: 2, categoryId: 3, isAvailable: true, createdAt: createDate as Date, modifiedAt: modifyDate as Date, owner: user, pictureURL: "picture",thumbnailPictureURL: "thumbPic", communityId: 4)
        
        let listingBanana = Listing(id: 2, photo:photoImage2,title: "banana", description: "nice banana", price: 2.0, isFree: false, quantity: 2, categoryId: 3, isAvailable: true, createdAt: createDate1 as Date, modifiedAt: modifyDate1 as Date, owner: user, pictureURL: "picture",thumbnailPictureURL: "thumbPic", communityId: 4)
        
        
        let listingPair = Listing(id: 3, photo:photoImage3,title: "Pair", description: "nice Pair", price: 3.0, isFree: false, quantity: 2, categoryId: 3, isAvailable: true, createdAt: createDate2 as Date, modifiedAt: modifyDate2 as Date, owner: user, pictureURL: "picture",thumbnailPictureURL: "thumbPic", communityId: 4)
        
        var lists : [Listing] = []
        lists.append(listingApple)
        lists.append(listingBanana)
        lists.append(listingPair)

        var filter = ListingFilter()
        filter.datePostedWithinOption = .oneDay
        var sortedLists : [Listing]
        sortedLists = ListingProcessingHandler.sortExpireDay(listings: lists, with: filter)

        //check only have banana(create in a day)
        XCTAssert(sortedLists[0].id == 2)
        XCTAssert(sortedLists.count == 1)

        
        var filter1 = ListingFilter()
        filter1.datePostedWithinOption = .twoDays
        var sortedLists1 : [Listing]
        sortedLists1 = ListingProcessingHandler.sortExpireDay(listings: lists, with: filter1)
        
        //check only have banana(create in a day, so it also in two day)
        XCTAssert(sortedLists1[0].id == 2)
        XCTAssert(sortedLists1.count == 1)

        
        var filter2 = ListingFilter()
        filter2.datePostedWithinOption = .sevenDays
        var sortedLists2 : [Listing]
        sortedLists2 = ListingProcessingHandler.sortExpireDay(listings: lists, with: filter2)
        
        //check have apple and banana(create in a day, so it also in a week)
        XCTAssert(sortedLists2[0].id == 1)//apple
        XCTAssert(sortedLists2[1].id == 2)//banana
        //have apple and banana
        XCTAssert(sortedLists2.count == 2)
        
    
        var filter3 = ListingFilter()
        filter3.datePostedWithinOption = .twoWeeks
        var sortedLists3 : [Listing]
        sortedLists3 = ListingProcessingHandler.sortExpireDay(listings: lists, with: filter3)
        
        //check have apple and banana(create in a day, so it also in a week)
        XCTAssert(sortedLists3.count != 3)//apple banana but no pair

    }

    func testSortByPriceRange() {

        let contactInformation = User.ContactInformation(address: "#406", email: "test@wow.com", phone: "123-456-7890")
        let photoImage1 = UIImage(named: "apples")
        let photoImage2 = UIImage(named: "banana")
        let photoImage3 = UIImage(named: "banana")
        let user = User(id: 5, name: "test", contactInformation: contactInformation, communityId:4 , pictureURL: "sample person pic", thumbnailPictureURL: "small pic")
    
        let createDate = Date(dateString:"2016-10-18")
        let modifyDate = Date(dateString:"2016-10-19")
    
        let createDate1 = Date(dateString:"2016-10-22")
        let modifyDate1 = Date(dateString:"2016-10-22")
    
        let createDate2 = Date(dateString:"2016-10-03")
        let modifyDate2 = Date(dateString:"2016-10-14")
    
        let listingApple = Listing(id: 1, photo:photoImage1,title: "apple", description: "nice apple", price: 1.0, isFree: false, quantity: 2, categoryId: 3, isAvailable: true, createdAt: createDate as Date, modifiedAt: modifyDate as Date, owner: user, pictureURL: "picture",thumbnailPictureURL: "thumbPic", communityId: 4)
    
        let listingBanana = Listing(id: 2, photo:photoImage2,title: "banana", description: "nice banana", price: 2.0, isFree: false, quantity: 2, categoryId: 3, isAvailable: true, createdAt: createDate1 as Date, modifiedAt: modifyDate1 as Date, owner: user, pictureURL: "picture",thumbnailPictureURL: "thumbPic", communityId: 4)
    
    
        let listingPair = Listing(id: 3, photo:photoImage3,title: "Pair", description: "nice Pair", price: 3.0, isFree: false, quantity: 2, categoryId: 3, isAvailable: true, createdAt: createDate2 as Date, modifiedAt: modifyDate2 as Date, owner: user, pictureURL: "picture",thumbnailPictureURL: "thumbPic", communityId: 4)
    
        var lists : [Listing] = []
        lists.append(listingApple)
        lists.append(listingBanana)
        lists.append(listingPair)
    
        var filter = ListingFilter()
        filter.maximumPrice = 2
        filter.minimumPrice = 1

        var sortedLists : [Listing]
        sortedLists = ListingProcessingHandler.sortByPriceRange(listings: lists, with: filter)
        //check have apple banana(pair not in range 1~2)
        XCTAssert(sortedLists[0].id == 1)//apple
        XCTAssert(sortedLists[1].id == 2)//banana
        XCTAssert(sortedLists.count == 2)
    }
    
}
