//
//  PhoneNumberHandler.swift
//  Mooch
//
//  Created by adam on 10/10/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import PhoneNumberKit

//Singleton that handles formatting and verifying phone numbers
class PhoneNumberHandler {
    
    //The variable to access this class through
    static private let sharedInstance = PhoneNumberHandler()
    
    //This prevents others from using the initializer for this class
    fileprivate init() {
        phoneNumberKit = PhoneNumberKit()
        partialFormatter = PartialFormatter(phoneNumberKit: phoneNumberKit, defaultRegion: "US")
    }
    
    private var phoneNumberKit: PhoneNumberKit!
    private var partialFormatter: PartialFormatter!
    
    static func format(number: String) -> String {
        return sharedInstance.partialFormatter.formatPartial(number)
    }
    
    static func isValid(number: String) -> Bool {
        do {
            let _ = try sharedInstance.phoneNumberKit.parse(number, withRegion: "US")
            return true
        } catch {
            return false
        }
    }
    
    //Returns true when a formatted phone number is complete
    //Example: "1(848) 483-8333", "(848) 483-8333"
    static func isComplete(phoneNumber: String) -> Bool {
        guard phoneNumber.characters.count >= 14 else { return false }
        let last5Characters = String(phoneNumber.characters.suffix(5))
        return String(last5Characters.characters.prefix(1)) == "-"
    }

}
