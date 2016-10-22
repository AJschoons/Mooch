//
//  ListingProcessingHandler.swift
//  Mooch
//
//  Created by adam on 10/20/16.
//  Copyright © 2016 cse498. All rights reserved.
//
import UIKit

//Singleton helper object that handles searching and filtering Listings
class ListingProcessingHandler {
    //The variable to access this class through
    static private let sharedInstance = ListingProcessingHandler()
    
    //This prevents others from using the initializer for this class
    fileprivate init() { }
    
    //Filters the Listings array passed with the given Filter, then returns the Listings that match the Filter
    static func filter(listings: [Listing], with filter: ListingFilter) -> [Listing] {
        let sortOrder = SortOrder()
        var sortedLists : [Listing]
        switch filter.sortByOption{
        case .lowestPrice:
            sortedLists = sortOrder.sortPriceLowerToHigh(listings: listings)
        case .highestPrice:
            sortedLists = sortOrder.sortPriceHighToLower(listings: listings)
        case .newest:
            sortedLists = sortOrder.newest(listings: listings)
        default:
            sortedLists = sortOrder.bestMatch(listings: listings)
        }

        let SortByOrderAndSortCategory = SortCategory()
        sortedLists = SortByOrderAndSortCategory.sortByCategory(listings: sortedLists, with: filter)
        
        let SortByOrderSortCategoryAndExpireDay = SortExpireDay()
        
        sortedLists = SortByOrderSortCategoryAndExpireDay.sortExpireDay(listings: sortedLists, with: filter)
        
        let SortByOrderCategoryExpireAndPriceR = SortByPriceRange()

        
        sortedLists = SortByOrderCategoryExpireAndPriceR.sortByPriceRange(listings: sortedLists, with: filter)
        
        return sortedLists
    }
    
    //Searches the Listings array passed with the given search input string, then returns the Listings that match the input string
    static func search(listings: [Listing], for searchInputString: String) -> [Listing] {
        var lists : [Listing] = []
        let inputLowerCase = searchInputString.lowercased()
        let inputStringWithoutSpace = inputLowerCase.removeWhitespace()
        
        for itemInList in listings {
            let title = itemInList.title
            let description = itemInList.description
            var titleAndDescrip = title+description!
            titleAndDescrip = titleAndDescrip.removeWhitespace()
            titleAndDescrip = titleAndDescrip.lowercased()
            if titleAndDescrip.range(of:inputStringWithoutSpace) != nil {
                lists.append(itemInList)
            }
        }
        return lists
    }
    
}

class SortOrder{
    //default
    func bestMatch(listings: [Listing])->[Listing]{
        return listings
    }
    //sort high to lower
    func sortPriceHighToLower(listings: [Listing])->[Listing]{
        let HighToLowList = listings.sorted(by: {$0.price > $1.price})
        return HighToLowList
    }
    
    //sort lower to high
    func sortPriceLowerToHigh(listings: [Listing])->[Listing]{
        let LowToHighList = listings.sorted(by: {$0.price < $1.price})
        return LowToHighList
    }
    //newest
    func newest(listings: [Listing])->[Listing]{
        let newest = listings.sorted(by: {$0.createdAt > $1.createdAt})
        return newest
    }

}

class SortCategory{
    func sortByCategory (listings: [Listing], with filter: ListingFilter)->[Listing]{
        //if user does select category. means he does't care and he want all categore
        if (filter.category == nil){
            return listings
        }
        let sortlists = listings
        var returnLists : [Listing] = []
        for item in sortlists{
            if(item.categoryId == filter.category?.id){
                returnLists.append(item)
            }
        }
        
        return returnLists
    }
}

//
class SortExpireDay {
    func sortExpireDay (listings: [Listing], with filter: ListingFilter)->[Listing]{
        //if user does select expire day. means he does't care and whatever how long he will take
        if (filter.datePostedWithinOption == nil){
            return listings
        }

        var day : Int = 0
        switch filter.datePostedWithinOption! {
        case .oneDay:
            day = 1
        case .twoDays:
            day = 2
        case .fiveDays:
            day = 5
        case .sevenDays:
            day = 7
        case .twoWeeks:
            day = 14
        default:
            day = 14
        }
        let currentDate = NSDate()
        let sortLists = listings
        var returnLists : [Listing] = []
        for item in sortLists{
            let expectDay = item.createdAt.addDays(daysToAdd: day)
            if(expectDay.isGreaterThanDate(dateToCompare: currentDate as Date)){
                returnLists.append(item)
            }
        }
        return returnLists
    }
}

class SortByPriceRange {
    func sortByPriceRange(listings: [Listing], with filter: ListingFilter)->[Listing]{
        let sortlists = listings
        var returnLists : [Listing] = []
        for item in sortlists{
            if((item.price <= Float(filter.maximumPrice))&&(item.price >= Float(filter.minimumPrice))){
                returnLists.append(item)
            }
        }
        return returnLists
    }
}


extension String {
    func replace(string:String, replacement:String) -> String {
        return self.replacingOccurrences(of: string, with: replacement)
    }
    
    func removeWhitespace() -> String {
        return self.replace(string: " ", replacement: "")
    }
}

extension Date {
    func isLessThanDate(dateToCompare: Date) -> Bool {
        var isLess = false
        if self.compare(dateToCompare) == ComparisonResult.orderedAscending {
            isLess = true
        }
        return isLess
    }
    
    func isGreaterThanDate(dateToCompare: Date) -> Bool {
        var isGreater = false
        if self.compare(dateToCompare as Date) == ComparisonResult.orderedDescending {
            isGreater = true
        }
        return isGreater
    }
    
    func addDays(daysToAdd: Int) -> Date {
        let secondsInDays: TimeInterval = Double(daysToAdd) * 60 * 60 * 24
        let dateWithDaysAdded: Date = self.addingTimeInterval(secondsInDays)
        return dateWithDaysAdded
    }
    
}



