//
//  ListingCategoryManager.swift
//  Mooch
//
//  Created by adam on 10/1/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import Foundation

//Singleton for managing the ListingCategory models in the app
class ListingCategoryManager {
    
    //The variable to access this class through
    static let sharedInstance = ListingCategoryManager()
    
    private(set) var listingCategories = [ListingCategory]() {
        didSet {
            generateIdToObjectMapping(forListingCategories: listingCategories)
        }
    }
    
    //Dictionary of a ListingCategory's id to the ListingCategory for quick ListingCategory lookup
    private var idToObjectMapping = [Int : ListingCategory]()
    
    //This prevents others from using the default '()' initializer for this class
    fileprivate init() {
        var dummyListingCategories = [ListingCategory]()
        for i in 1...30 {
            let dummyListingCategory = ListingCategory.createDummy(fromNumber: i)
            dummyListingCategories.append(dummyListingCategory)
        }
        listingCategories = dummyListingCategories
    }
    
    func update(withListingCategories listingCategories: [ListingCategory]) {
        self.listingCategories = listingCategories
    }
    
    func getListingCategory(withId listingCategoryId: Int) -> ListingCategory? {
        return idToObjectMapping[listingCategoryId]
    }
    
    private func generateIdToObjectMapping(forListingCategories listingCategories: [ListingCategory]) {
        var newIdToObjectMapping = [Int : ListingCategory]()
        for listingCategory in listingCategories {
            newIdToObjectMapping[listingCategory.id] = listingCategory
        }
        idToObjectMapping = newIdToObjectMapping
    }
}
