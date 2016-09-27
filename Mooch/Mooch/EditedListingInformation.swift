//
//  EditedListingInformation.swift
//  Mooch
//
//  Created by adam on 9/26/16.
//  Copyright © 2016 cse498. All rights reserved.
//

//Struct to track the edited listing information for the EditListingViewController
struct EditedListingInformation {
    var title: String?
    var description: String?
    var tag: ListingTag?
    var price: Float?
    var quantity: Int?
    
    var numberOfInformationFieldsEdited: Int {
        var num = 0
        if title != nil { num += 1 }
        if description != nil { num += 1 }
        if tag != nil { num += 1 }
        if price != nil { num += 1 }
        if quantity != nil { num += 1 }
        return num
    }
    
    var isAllInformationFilled: Bool {
        return numberOfInformationFieldsEdited == 5
    }
    
    func firstUnfilledFieldType() -> EditListingConfiguration.FieldType? {
        var unfilledFieldType: EditListingConfiguration.FieldType? = nil
        
        if title == nil {
            unfilledFieldType = .title
        } else if description == nil {
            unfilledFieldType = .description
        } else if tag == nil {
            unfilledFieldType = .tag
        } else if price == nil {
            unfilledFieldType = .price
        } else if quantity == nil {
            unfilledFieldType = .quantity
        }
        
        return unfilledFieldType
    }
}
