//
//  ListingProcessingHandler.swift
//  Mooch
//
//  Created by adam on 10/20/16.
//  Copyright © 2016 cse498. All rights reserved.
//

//Singleton helper object that handles searching and filtering Listings
class ListingProcessingHandler {
    
    //The variable to access this class through
    static private let sharedInstance = ListingProcessingHandler()
    
    //This prevents others from using the initializer for this class
    fileprivate init() { }
    
    //Filters the Listings array passed with the given Filter, then returns the Listings that match the Filter
    static func filter(listings: [Listing], with filter: ListingFilter) -> [Listing] {
        return [Listing]()
    }
    
    //Searches the Listings array passed with the given search input string, then returns the Listings that match the input string
    static func search(listings: [Listing], for searchInputString: String) -> [Listing] {
        return [Listing]()
    }
}
