//
//  EditListingConfiguration.swift
//  Mooch
//
//  Created by adam on 9/26/16.
//  Copyright © 2016 cse498. All rights reserved.
//

//A configuration to setup the EditListingViewController with
struct EditListingConfiguration {
    
    //A mapping from a FieldType to a Bool that returns true if it conforms
    typealias FieldTypeConformanceMapping = (FieldType) -> Bool
    
    var mode: Mode
    
    var title: String
    var leftBarButtons: [BarButtonType]?
    var rightBarButtons: [BarButtonType]?
    
    //The fields that should be shown
    var fields: [FieldType]
    
    //The bar buttons that can be added
    enum BarButtonType {
        case cancel
        case done
    }
    
    enum Mode {
        case creating
        case editing
    }
    
    enum FieldType {
        case photo
        case title
        case description
        case tag
        case price
        case quantity
    }
    
    func indexOfLastFieldType(conformingToMapping mapping: FieldTypeConformanceMapping) -> Int? {
        let mappedFieldTypes = fields.reversed().map{mapping($0)}
        guard let reversedIndex = mappedFieldTypes.index(of: true) else { return nil }
        return (fields.count - 1) - reversedIndex
    }
    
    func textDescription(forFieldType fieldType: FieldType) -> String {
        switch fieldType {
        case .photo:
            return "Photo"
        case .title:
            return "Title"
        case .description:
            return "Description"
        case .tag:
            return "Tag"
        case .price:
            return "Price"
        case .quantity:
            return "Quantity"
        }
    }
}
