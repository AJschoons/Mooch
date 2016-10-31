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
    
    enum Mode {
        case creating
        case editing
    }
    
    enum FieldType {
        //Informational fields
        case photo
        case title
        case price
        case quantity
        case description
        case category
        
        case actions
    }
    
    var mode: Mode
    
    var title: String
    
    //The fields that should be shown
    var fields: [FieldType]
    
    static func defaultConfiguration(for mode: Mode) -> EditListingConfiguration {
        
        switch mode {
        case .creating:
            return EditListingConfiguration(mode: .creating, title: Strings.EditListing.defaultCreatingTitle.rawValue, fields: [.photo, .title, .price, .quantity, .description, .category, .actions])
            
        case .editing:
            return EditListingConfiguration(mode: .creating, title: Strings.EditListing.defaultEditingTitle.rawValue, fields: [.photo, .title, .price, .quantity, .description, .category, .actions])
        }
    }
    
    func indexOfLastFieldType(conformingToMapping mapping: FieldTypeConformanceMapping) -> Int? {
        let mappedFieldTypes = fields.reversed().map{mapping($0)}
        guard let reversedIndex = mappedFieldTypes.index(of: true) else { return nil }
        return (fields.count - 1) - reversedIndex
    }
    
    func textDescription(forFieldType fieldType: FieldType) -> String {
        switch fieldType {
        case .photo:
            return Strings.EditListing.fieldTypePhotoTextDescription.rawValue
        case .title:
            return Strings.EditListing.fieldTypeTitleTextDescription.rawValue
        case .description:
            return Strings.EditListing.fieldTypeDescriptionTextDescription.rawValue
        case .price:
            return Strings.EditListing.fieldTypePriceTextDescription.rawValue
        case .quantity:
            return Strings.EditListing.fieldTypeQuantityTextDescription.rawValue
        case .category:
            return Strings.EditListing.fieldTypeCategoryTextDescription.rawValue
        default:
            return ""
        }
    }
}
