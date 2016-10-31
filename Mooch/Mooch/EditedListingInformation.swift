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
    var price: Float?
    var quantity: Int?
    var description: String?
    var categoryId: Int?
    
    var isPriceValid: Bool {
        guard let price = price else { return false }
        return price <= Float(200.0)
    }
    
    var isAllInformationFilled: Bool {
        if photo == nil || title == nil || categoryId == nil || price == nil || quantity == nil {
            return false
        }
        
        return true
    }
    
    func string(for fieldType: EditListingConfiguration.FieldType) -> String? {
        switch fieldType {
        case .title:
            return title
            
        case .price:
            guard let price = price else { return nil }
            return "$" + String(format: "%.2f", price)
            
        case .quantity:
            guard let quantity = quantity else { return nil }
            return String(quantity)
            
        case .description:
            return description
            
        default:
            return nil
        }
    }
    
    func firstUnfilledRequiredFieldType() -> EditListingConfiguration.FieldType? {
        var unfilledFieldType: EditListingConfiguration.FieldType? = nil
        
        if photo == nil {
            unfilledFieldType = .photo
        } else if title == nil {
            unfilledFieldType = .title
        } else if price == nil {
            unfilledFieldType = .price
        } else if quantity == nil {
            unfilledFieldType = .quantity
        } else if categoryId == nil {
            unfilledFieldType = .category
        }
        
        return unfilledFieldType
    }
}
