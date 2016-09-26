//
//  EditListingTextfieldHandler.swift
//  Mooch
//
//  Created by adam on 9/25/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import Foundation
import UIKit

protocol EditListingTextHandlerDelegate: class {
    func updated(text: String, forFieldType: EditListingConfiguration.FieldType)
}

class EditListingTextHandler: NSObject {
    
    // MARK: Public variables
    
    weak var delegate: EditListingTextHandlerDelegate!
    
    
    // MARK: Private variables
    
    private let NumbersAllowedLeftOfPriceDecimal = 3
    private let NumbersAllowedRightOfPriceDecimal = 2
    
    // MARK: Actions
    
    // MARK: Public methods
    
    // MARK: Private methods
    
    fileprivate func shouldAllowChangesForTitleField(withUpdatedText updatedText: String) -> Bool {
        return updatedText.characters.count <= 30
    }
    
    fileprivate func shouldAllowChangesForDescriptionField(withUpdatedText updatedText: String) -> Bool {
        return updatedText.characters.count <= 200
    }
    
    fileprivate func shouldAllowChangesForTagField(withUpdatedText updatedText: String) -> Bool {
        if updatedText.contains(" ") {
            return false
        }
        
        return updatedText.characters.count <= 12
    }
    
    fileprivate func shouldAllowChangesForPriceField(withUpdatedText updatedText: String) -> Bool {
        let numbersSet = CharacterSet.decimalDigits
        
        let decimalPointSet = CharacterSet(charactersIn: ".")
        
        var numbersLeftOfDecimal = 0
        var numbersRightOfDecimal = 0
        var isLeftOfDecimal = true
        
        func isCharacterLeftOfDecimalLegal(character: String.UnicodeScalarView.Iterator.Element) -> Bool {
            //Hit the decimal
            if decimalPointSet.contains(character) {
                //Need at least one number to the left of the decimal point
                if numbersLeftOfDecimal < 1 {
                    return false
                } else {
                    //Switch to right of decimal logic
                    isLeftOfDecimal = false
                    return true
                }
            }
            
            if !numbersSet.contains(character) {
                return false
            }
            
            if numbersLeftOfDecimal == NumbersAllowedLeftOfPriceDecimal {
                return false
            }
            
            numbersLeftOfDecimal += 1
            
            return true
        }
        
        func isCharacterRightOfDecimalLegal(character: String.UnicodeScalarView.Iterator.Element) -> Bool {
            if !numbersSet.contains(character) {
                return false
            } else if numbersRightOfDecimal == NumbersAllowedRightOfPriceDecimal {
                return false
            }
            
            numbersRightOfDecimal += 1
            return true
        }
        
        for character in updatedText.unicodeScalars {
            if isLeftOfDecimal {
                if !isCharacterLeftOfDecimalLegal(character: character) { return false }
            } else {
                if !isCharacterRightOfDecimalLegal(character: character) { return false }
            }
        }
        
        return true
    }
}

extension EditListingTextHandler: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let editListingTextfield = textField as? EditListingTextfield, let fieldType = (textField as! EditListingTextfield).fieldType else { return false }
        let textfieldText = editListingTextfield.text ?? ""
        guard let NSStringTextfieldText = textfieldText as NSString? else { return false }
        let updatedTextfieldText = NSStringTextfieldText.replacingCharacters(in: range, with: string)
        
        var allowChanges: Bool
        switch fieldType {
        case .title:
            allowChanges = shouldAllowChangesForTitleField(withUpdatedText: updatedTextfieldText)
        case .description:
            allowChanges = shouldAllowChangesForDescriptionField(withUpdatedText: updatedTextfieldText)
        case .price:
            allowChanges = shouldAllowChangesForPriceField(withUpdatedText: updatedTextfieldText)
        case .tag:
            allowChanges = shouldAllowChangesForTagField(withUpdatedText: updatedTextfieldText)
        default:
            allowChanges = false
        }
        
        if allowChanges {
            delegate.updated(text: updatedTextfieldText, forFieldType: fieldType)
        }
        
        return allowChanges
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let navigableTextField = textField as? NavigableTextField {
            //Bring the keyboard to the next textfield if it exists, else hide it
            if let nextTextField = navigableTextField.nextNavigableTextField {
                nextTextField.becomeFirstResponder()
            } else {
                navigableTextField.resignFirstResponder()
            }
        }
        
        return true
    }
}
