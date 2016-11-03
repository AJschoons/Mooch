//
//  ListingDetailsConfiguration.swift
//  Mooch
//
//  Created by adam on 10/23/16.
//  Copyright © 2016 cse498. All rights reserved.
//

//A configuration to setup the class with
struct ListingDetailsConfiguration {

    enum Mode {
        case viewingOtherUsersListing
        case viewingThisUsersListing
        case viewingOtherUsersCompletedListing
        case viewingThisUsersCompletedListing
    }
    
    //The bar buttons that can be added
    enum BarButtonType {
        case cancel
        case edit
    }
    
    enum FieldType {
        //Information
        case listing
        case listingDescription
        case aboutOtherUser
        case interestedBuyersHeader
        case interestedBuyer
        
        //Actions: Make sure to update isAction() when adding an action
        case contactSeller
        case viewSellerProfile
        case endListing
        
        func isAction() -> Bool {
            return self == .contactSeller || self == .viewSellerProfile || self == .endListing
        }
    }
    
    var listing: Listing
    
    let mode: Mode
    
    let title: String
    var leftBarButtons: [BarButtonType]?
    var rightBarButtons: [BarButtonType]?
    
    //The fields that should be shown
    private(set) var fields: [FieldType]
    
    private(set) var noInterestedBuyersForInterestedBuyersHeader = false
    
    private var numberOfNonInterestedBuyerFields: Int?
    
    static func defaultConfiguration(for mode: Mode, with listing: Listing, isViewingSellerProfileNotAllowed: Bool) -> ListingDetailsConfiguration {
        switch mode {
            
        case .viewingOtherUsersListing:
            var fields: [FieldType] = [.listing, .contactSeller, .viewSellerProfile, .listingDescription, .aboutOtherUser]
            if isViewingSellerProfileNotAllowed, let viewSellerProfileIndex = fields.index(of: .viewSellerProfile) {
                fields.remove(at: viewSellerProfileIndex)
            }
            
            return ListingDetailsConfiguration(listing: listing, mode: .viewingOtherUsersListing, title: Strings.ListingDetails.title.rawValue, leftBarButtons: nil, rightBarButtons: nil, fields: fields)
            
        case .viewingOtherUsersCompletedListing:
            var fields: [FieldType] = [.listing, .viewSellerProfile, .listingDescription, .aboutOtherUser]
            if isViewingSellerProfileNotAllowed, let viewSellerProfileIndex = fields.index(of: .viewSellerProfile) {
                fields.remove(at: viewSellerProfileIndex)
            }
            
            return ListingDetailsConfiguration(listing: listing, mode: .viewingOtherUsersCompletedListing, title: Strings.ListingDetails.title.rawValue, leftBarButtons: nil, rightBarButtons: nil, fields: fields)
            
        case .viewingThisUsersListing:
            return ListingDetailsConfiguration(listing: listing, mode: .viewingThisUsersListing, title: Strings.ListingDetails.title.rawValue, leftBarButtons: nil, rightBarButtons: [.edit], fields: [.listing, .endListing, .listingDescription, .interestedBuyersHeader])
            
        case .viewingThisUsersCompletedListing:
            return ListingDetailsConfiguration(listing: listing, mode: .viewingThisUsersCompletedListing, title: Strings.ListingDetails.title.rawValue, leftBarButtons: nil, rightBarButtons: nil, fields: [.listing, .listingDescription, .aboutOtherUser])
        }
    }
    
    //Note: Passing the interestedBuyersHeader FieldType will automatically generate the interestedBuyer fields from the Listing
    init(listing: Listing, mode: Mode, title: String, leftBarButtons: [BarButtonType]?, rightBarButtons: [BarButtonType]?, fields: [FieldType]) {
        self.listing = listing
        self.mode = mode
        self.title = title
        self.leftBarButtons = leftBarButtons
        self.rightBarButtons = rightBarButtons
        self.fields = fields
        
        //We have to generate the interested buyer fields from the listing
        if fields.contains(.interestedBuyersHeader) {
            guard listing.interestedBuyers.count > 0 else {
                noInterestedBuyersForInterestedBuyersHeader = true
                return
            }
            
            numberOfNonInterestedBuyerFields = self.fields.count
            
            for _ in 0..<listing.interestedBuyers.count {
                self.fields.append(.interestedBuyer)
            }
        }
    }
    
    func fieldType(forRow row: Int) -> FieldType {
        return fields[row]
    }
    
    func exchange(forRow row: Int) -> Exchange? {
        guard noInterestedBuyersForInterestedBuyersHeader == false else { return nil }
        guard let numberOfNonInterestedBuyerFields = numberOfNonInterestedBuyerFields else { return nil }
        return listing.exchanges[row - numberOfNonInterestedBuyerFields]
    }
    
    func isListingDescriptionLastField() -> Bool {
        return fields.last == .listingDescription
    }
    
    func firstActionFieldType() -> FieldType? {
        for field in fields {
            if field.isAction() {
                return field
            }
        }
        return nil
    }
    
    func firstIndex(of fieldType: FieldType) -> Int? {
        return fields.index(of: fieldType)
    }
}
