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
    
    var photo: UIImage?
    var name: String?
    var email: String?
    var phone: String?
    var address: String?
    var password1: String?
    var password2: String?
    
    var isAllInformationFilledAndValid: Bool {
        return isAllInformationFilled && isEmailValid && isPasswordValid && passwordsMatch
    }
    
    var isAllInformationFilled: Bool {
        if photo == nil || name == nil || email == nil || phone == nil || address == nil || password1 == nil || password2 == nil {
            return false
        }
        
        return true
    }
    
    var isEmailValid: Bool {
        guard let email = email else { return false }
        return UserLoginInformationValidator.isValid(email: email)
    }
    
    var isPasswordValid: Bool {
        guard let password = password1 else { return false }
        return UserLoginInformationValidator.isValid(password: password)
    }
    
    var passwordsMatch: Bool {
        guard let first = password1, let second = password2 else { return false}
        return first == second
    }
    
    func firstUnfilledRequiredFieldType() -> EditProfileConfiguration.FieldType? {
        var unfilledFieldType: EditProfileConfiguration.FieldType? = nil
        
        if photo == nil {
            unfilledFieldType = .photo
        } else if name == nil {
            unfilledFieldType = .name
        } else if email == nil {
            unfilledFieldType = .email
        } else if phone == nil {
            unfilledFieldType = .phone
        } else if address == nil {
            unfilledFieldType = .address
        } else if password1 == nil {
            unfilledFieldType = .password1
        } else if password2 == nil {
            unfilledFieldType = .password2
        }
        
        return unfilledFieldType
    }
}
