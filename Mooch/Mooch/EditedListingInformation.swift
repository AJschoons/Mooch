//
//  EditedListingInformation.swift
//  Mooch
//
//  Created by adam on 9/26/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

//Struct to track the edited listing information for the EditListingViewController
struct EditedListingInformation {
    
    var photo: UIImage?
    var title: String?
    var description: String?
    var categoryId: Int?
    var price: Float?
    var quantity: Int?
    
    var isAllInformationFilled: Bool {
        if photo == nil || title == nil || categoryId == nil || price == nil || quantity == nil {
            return false
        }
        
        return true
    }
    
    func firstUnfilledFieldType() -> EditListingConfiguration.FieldType? {
        var unfilledFieldType: EditListingConfiguration.FieldType? = nil
        
        if photo == nil {
            unfilledFieldType = .photo
        } else if title == nil {
            unfilledFieldType = .title
        } else if description == nil {
            unfilledFieldType = .description
        } else if categoryId == nil {
            unfilledFieldType = .tag
        } else if price == nil {
            unfilledFieldType = .price
        } else if quantity == nil {
            unfilledFieldType = .quantity
        }
        
        return unfilledFieldType
    }
}
