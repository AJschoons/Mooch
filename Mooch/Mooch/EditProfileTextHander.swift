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
    
    fileprivate func shouldAllowChanges(forFieldType fieldType: EditProfileConfiguration.FieldType, withUpdatedText updatedText: String) -> Bool {
        var allowChanges: Bool
        switch fieldType {
        case .email:
            allowChanges = shouldAllowChangesForEmailField(withUpdatedText: updatedText)
        case .password1, .password2:
            allowChanges = shouldAllowChangesForPasswordField(withUpdatedText: updatedText)
        default:
            return true
        }
        
        return allowChanges
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
        let allowChanges = shouldAllowChanges(forFieldType: fieldType, withUpdatedText: updatedTextFieldText)
        
        if allowChanges {
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
