//
//  EditedProfileInformation.swift
//  Mooch
//
//  Created by adam on 10/10/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

//Struct to track the edited profile information for the EditProfileViewController
struct EditedProfileInformation {
    
    typealias FieldType = EditProfileConfiguration.FieldType
    
    private var fieldsShownToRequiredPairs: [(FieldType, Bool)]
    private var fieldsShownToRequiredMapping: [FieldType : Bool]
    
    var photo: UIImage? {
        didSet {
            photoDidChange = true
        }
    }
    
    var name: String?
    var email: String?
    var phone: String?
    var address: String?
    var password1: String?
    var password2: String?
    var communityId: Int?
    
    private(set) var photoDidChange = false
    
    init(fieldsShownToRequiredPairs: [(FieldType, Bool)]) {
        self.fieldsShownToRequiredPairs = fieldsShownToRequiredPairs
        
        var fieldsShownToRequiredMapping = [FieldType : Bool]()
        for (field, isRequired) in fieldsShownToRequiredPairs {
            fieldsShownToRequiredMapping[field] = isRequired
        }
        self.fieldsShownToRequiredMapping = fieldsShownToRequiredMapping
    }
    
    var digitsOnlyPhone: String? {
        guard let phone = phone else { return nil }
        return digitOnlyString(of: phone)
    }
    
    var isAllRequiredInformationFilledAndValid: Bool {
        return isRequiredInformationFilled && isEmailValid && isPhoneValid && isPasswordValid && isPasswordMatchValid && isCommunityValid
    }
    
    var isRequiredInformationFilled: Bool {
        return firstUnfilledRequiredFieldType() == nil
    }
    
    var isEmailValid: Bool {
        //Valid if the email field isn't shown
        let showsEmail = fieldsShownToRequiredMapping[.email] != nil
        guard showsEmail else { return true }
        
        let isEmailRequired = fieldsShownToRequiredMapping[.email]!
        let isEmailPresent = variable(forFieldType: .email) != nil
        
        if isEmailRequired || isEmailPresent {
            guard let email = variable(forFieldType: .email) as? String else { return false }
            return UserLoginInformationValidator.isValid(email: email)
        } else {
            //If the email isn't required or present then it is valid
            return true
        }
    }
    
    var isPhoneValid: Bool {
        //Valid if the phone field isn't shown
        let showsPhone = fieldsShownToRequiredMapping[.phone] != nil
        guard showsPhone else { return true }
        
        let isPhoneRequired = fieldsShownToRequiredMapping[.phone]!
        let isPhonePresent = variable(forFieldType: .phone) != nil
        
        if isPhoneRequired || isPhonePresent {
            guard let phone = digitsOnlyPhone else { return false }
            return phone.characters.count == 10 || phone.characters.count == 11
        } else {
            //If the phone isn't required or present then it is valid
            return true
        }
    }
    
    var isPasswordValid: Bool {
        //Valid if the password field isn't shown
        let showsPassword = fieldsShownToRequiredMapping[.password1] != nil
        guard showsPassword else { return true }
        
        let isPasswordRequired = fieldsShownToRequiredMapping[.password1]!
        let isPasswordPresent = variable(forFieldType: .password1) != nil
        
        if isPasswordRequired || isPasswordPresent {
            guard let password = variable(forFieldType: .password1) as? String else { return false }
            return UserLoginInformationValidator.isValid(password: password)
        } else {
            //If the password isn't required or present then it is valid
            return true
        }
    }
    
    var isPasswordMatchValid: Bool {
        //Valid if the password fields aren't shown
        let showsPassword1 = fieldsShownToRequiredMapping[.password1] != nil
        let showsPassword2 = fieldsShownToRequiredMapping[.password2] != nil
        guard showsPassword1, showsPassword2 else { return true }
        
        let isPassword1Required = fieldsShownToRequiredMapping[.password1]!
        let isPassword2Required = fieldsShownToRequiredMapping[.password2]!
        let isPasswordMatchRequired = isPassword1Required && isPassword2Required
        
        if isPasswordMatchRequired {
            //When required, both the passwords must be present and match
            guard let password1 = variable(forFieldType: .password1) as? String, let password2 = variable(forFieldType: .password2) as? String else { return false }
            return password1 == password2
        } else {
            //When not required, if the first password is present then they both must be valid
            if let password1 = variable(forFieldType: .password1) as? String {
                guard let password2 = variable(forFieldType: .password2) as? String else { return false }
                return password1 == password2
            } else {
                return true
            }
        }
    }
    
    var isCommunityValid: Bool {
        //Valid if the community field isn't shown
        let showsCommunity = fieldsShownToRequiredMapping[.community] != nil
        guard showsCommunity else { return true }
        
        let isCommunityRequired = fieldsShownToRequiredMapping[.community]!
        let isCommunityPresent = variable(forFieldType: .community) != nil
        
        if isCommunityRequired || isCommunityPresent {
            guard let _ = variable(forFieldType: .community) as? Int else { return false }
            return true
        } else {
            //If the community isn't required or present then it is valid
            return true
        }
    }
    
    func isEditedInformationChanged(from user: User) -> Bool {
        guard let name = name, let phone = phone else { return false }
        
        let hasRequiredVariableChanged = name != user.name || phone != user.contactInformation.phone
        let hasAddressChanged = user.contactInformation.address != address
        
        return hasRequiredVariableChanged || hasAddressChanged || photoDidChange
    }
    
    func string(for fieldType: FieldType) -> String? {
        guard var string = variable(forFieldType: fieldType) as? String? else { return nil }
        
        if fieldType == .phone, let number = string {
            string = PhoneNumberHandler.format(number: number)
        }
        
        return string
    }
    
    func firstUnfilledRequiredFieldType() -> FieldType? {
        var unfilledFieldType: EditProfileConfiguration.FieldType? = nil
        
        for (field, isRequired) in fieldsShownToRequiredPairs {
            if !isRequired {
                continue
            }
            
            if variable(forFieldType: field) == nil {
                unfilledFieldType = field
                break
            }
        }
        
        return unfilledFieldType
    }
    
    private func digitOnlyString(of s: String) -> String {
        let numbersSet = CharacterSet.decimalDigits
        
        var digits = ""
        for c in s.unicodeScalars {
            if numbersSet.contains(c) {
                digits.append(Character(c))
            }
        }
        
        return digits
    }
    
    private func variable(forFieldType fieldType: FieldType) -> Any? {
        switch fieldType {
        case .photo:
            return photo
        case .name:
            return name
        case .email:
            return email
        case .phone:
            return phone
        case .address:
            return address
        case .password1:
            return password1
        case .password2:
            return password2
        case .community:
            return communityId
        default:
            return nil
        }
    }
}
