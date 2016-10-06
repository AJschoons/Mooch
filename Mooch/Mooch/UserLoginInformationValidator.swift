//
//  UserLoginInformationValidator.swift
//  Mooch
//
//  Created by adam on 10/3/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import Foundation

class UserLoginInformationValidator {
    
    static let MinPasswordLength = 6
    static let MaxPasswordLength = 30
    
    //Passwords must be 6-30 characters with no spaces
    static func isValid(password: String) -> Bool {
        let length = password.characters.count
        guard length >= 6 && length <= 30 else {
            return false
        }
        
        guard !password.contains(" ") else {
            return false
        }
        
        return true
    }
    
    //http://stackoverflow.com/questions/3139619/check-that-an-email-address-is-valid-on-ios
    static func isValid(email: String) -> Bool {
        let emailRegexPattern = "^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegexPattern)
        return emailTest.evaluate(with: email)
    }
}
