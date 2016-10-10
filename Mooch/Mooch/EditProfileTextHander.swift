//
//  EditProfileTextHander.swift
//  Mooch
//
//  Created by adam on 10/10/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

protocol EditProfileTextHandlerDelegate: class {
    func updated(text: String, forFieldType: EditProfileConfiguration.FieldType)
}

class EditProfileTextHandler: NSObject {
    
    // MARK: Public variables
    
    weak var delegate: EditProfileTextHandlerDelegate!
    
    
    // MARK: Private variables
    
    // MARK: Actions
    
    // MARK: Public methods
    
    // MARK: Private methods
    
    fileprivate func onReturnKey(forTextField textField: EditProfileTextField) {
        //Bring the keyboard to the next responder if it exists, else hide it
        if let next = textField.nextNavigableResponder {
            next.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
    }
    
    fileprivate func shouldAllowChanges(forFieldType fieldType: EditProfileConfiguration.FieldType, withCurrentText currentText: String, andUpdatedText updatedText: String, fromReplacementString replacementString: String) -> Bool {
        var allowChanges: Bool
        switch fieldType {
        case .email:
            allowChanges = shouldAllowChangesForEmailField(withUpdatedText: updatedText)
        case .password1, .password2:
            allowChanges = shouldAllowChangesForPasswordField(withUpdatedText: updatedText)
        case .phone:
            allowChanges = shouldAllowChangesForPhoneField(withUpdatedText: updatedText, replacementString: replacementString, currentText: currentText)
        default:
            return true
        }
        
        return allowChanges
    }
    
    //Only allow numbers to be entered; don't allow more text after the number is complete
    fileprivate func shouldAllowChangesForPhoneField(withUpdatedText updatedText: String, replacementString: String,currentText: String) -> Bool {
        let isComplete = PhoneNumberHandler.isComplete(phoneNumber: currentText)
        let isDeletingText = updatedText.characters.count < currentText.characters.count
        
        if isComplete && !isDeletingText {
            return false
        }
    
        let numbersSet = CharacterSet.decimalDigits
        for c in replacementString.unicodeScalars {
            if !numbersSet.contains(c) {
                return false
            }
        }
        
        return true
    }
    
    fileprivate func shouldAllowChangesForEmailField(withUpdatedText updatedText: String) -> Bool {
        return !updatedText.contains(" ")
    }
    
    fileprivate func shouldAllowChangesForPasswordField(withUpdatedText updatedText: String) -> Bool {
        return !updatedText.contains(" ") && updatedText.characters.count <= UserLoginInformationValidator.MaxPasswordLength
    }
}

extension EditProfileTextHandler: UITextFieldDelegate {
    

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let editProfileTextField = textField as? EditProfileTextField, let fieldType = (textField as! EditProfileTextField).fieldType else { return false }
        
        let textViewText = editProfileTextField.text ?? ""
        guard let NSStringTextfieldText = textViewText as NSString? else { return false }
        let updatedTextFieldText = NSStringTextfieldText.replacingCharacters(in: range, with: string)
        var allowChanges = shouldAllowChanges(forFieldType: fieldType, withCurrentText: textViewText, andUpdatedText: updatedTextFieldText, fromReplacementString: string)
        
        if allowChanges {
            var updatedText = updatedTextFieldText
            
            //When it is the phone field, we manually update the text field to the formatted number so allowChanges must be false
            if fieldType == .phone {
                updatedText = PhoneNumberHandler.format(number: updatedText)
                editProfileTextField.text = updatedText
                allowChanges = false
            }
            
            delegate.updated(text: updatedTextFieldText, forFieldType: fieldType)
        }
        
        return allowChanges
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let editProfileTextField = textField as? EditProfileTextField else { return true }
        onReturnKey(forTextField: editProfileTextField)
        return true
    }
}
