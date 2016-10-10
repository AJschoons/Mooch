//
//  EditProfileConfiguation.swift
//  Mooch
//
//  Created by adam on 10/10/16.
//  Copyright © 2016 cse498. All rights reserved.
//

//A configuration to setup the EditProfileViewController with
struct EditProfileConfiguration {
    
    //A mapping from a FieldType to a Bool that returns true if it conforms
    typealias FieldTypeConformanceMapping = (FieldType) -> Bool
    
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
        case name
        case email
        case phone
        case address
        case password1
        case password2
    }
    
    private(set) var mode: Mode
    
    private(set) var title: String
    private(set) var leftBarButtons: [BarButtonType]?
    private(set) var rightBarButtons: [BarButtonType]?
    
    //The fields that should be shown mapped to whether they are required or not
    private(set) var fieldsShownToRequiredPairs: [(FieldType, Bool)]
    
    private(set) var fields: [FieldType]
    
    init(mode: Mode, title: String, leftBarButtons: [BarButtonType]?, rightBarButtons: [BarButtonType]?, fieldsShownToRequiredPairs: [(FieldType, Bool)]) {
        self.mode = mode
        self.title = title
        self.leftBarButtons = leftBarButtons
        self.rightBarButtons = rightBarButtons
        self.fieldsShownToRequiredPairs = fieldsShownToRequiredPairs
        self.fields = fieldsShownToRequiredPairs.map({$0.0})
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
        case .name:
            return "Name"
        case .email:
            return "Email"
        case .phone:
            return "Phone"
        case .address:
            return "Address"
        case .password1:
            return "Password"
        case .password2:
            return "Confirm Password"
        }
    }
}
