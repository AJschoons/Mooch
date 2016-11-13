//
//  ListingFilter.swift
//  Mooch
//
//  Created by adam on 10/20/16.
//  Copyright © 2016 cse498. All rights reserved.
//

struct ListingFilter {
    
    enum SortByOption: String {
        case bestMatch = "Best Match"
        case lowestPrice = "Lowest Price"
        case highestPrice = "Highest Price"
        case newest = "Newest"
        
        static func numberOfOptions() -> Int {
            return 4
        }
        
        static func option(forIndex index: Int) -> SortByOption {
            switch index {
            case 0:
                return .bestMatch
            case 1:
                return .lowestPrice
            case 2:
                return .highestPrice
            case 3:
                return .newest
            default:
                return .bestMatch
            }
        }
    }
    
    enum DatePostedWithinOption: String {
        case oneDay = "Last 24 hours"
        case twoDays = "Last 2 days"
        case fiveDays = "Last 5 days"
        case sevenDays = "Last 7 days"
        case twoWeeks = "Last 2 weeks"
        
        static func numberOfOptions() -> Int {
            return 5
        }
        
        static func option(forIndex index: Int) -> DatePostedWithinOption {
            switch index {
            case 0:
                return .oneDay
            case 1:
                return .twoDays
            case 2:
                return .fiveDays
            case 3:
                return .sevenDays
            case 4:
                return .twoWeeks
            default:
                return .twoWeeks
            }
        }
    }
    
    var sortByOption: SortByOption = .bestMatch
    
    var datePostedWithinOption: DatePostedWithinOption = .twoWeeks
    
    var category: ListingCategory?
    
    var minimumPrice: Int = 0
    var maximumPrice: Int = 200
}
