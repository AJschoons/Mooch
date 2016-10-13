//
//  LoginTextHandler.swift
//  Mooch
//
//  Created by adam on 10/3/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

protocol LoginTextHandlerDelegate: class {
    func updated(text: String, forFieldType: LoginViewController.FieldType)
}

class LoginTextHandler: NSObject {
    
    // MARK: Public variables
    
    weak var delegate: LoginTextHandlerDelegate!
    
    
    // MARK: Private variables
    
    // MARK: Actions
    
    // MARK: Public methods
    
    // MARK: Private methods
    
    fileprivate func onReturnKey(forTextField textField: LoginTextField) {
        //Bring the keyboard to the next responder if it exists, else hide it
        if let next = textField.nextNavigableResponder {
            next.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
    }
    
    fileprivate func shouldAllowChanges(forFieldType fieldType: LoginViewController.FieldType, withUpdatedText updatedText: String) -> Bool {
        var allowChanges: Bool
        switch fieldType {
        case .email:
            allowChanges = shouldAllowChangesForEmailField(withUpdatedText: updatedText)
        case .password:
            allowChanges = shouldAllowChangesForPasswordField(withUpdatedText: updatedText)
        }
        
        return allowChanges
    }
    
    fileprivate func shouldAllowChangesForEmailField(withUpdatedText updatedText: String) -> Bool {
        return !updatedText.contains(" ")
    }
    
    fileprivate func shouldAllowChangesForPasswordField(withUpdatedText updatedText: String) -> Bool {
        return !updatedText.contains(" ") && updatedText.characters.count <= UserLoginInformationValidator.MaxPasswordLength
    }
    
    fileprivate func updateStateAfterSelected(forLoginTextField loginTextField: LoginTextField) {
        loginTextField.setPlaceholder(hidden: true)
    }
    
    fileprivate func updateStateAfterUnselected(forLoginTextField loginTextField: LoginTextField) {
        if isEmpty(loginTextField.text) {
            loginTextField.setPlaceholder(hidden: false)
        }
    }
}

extension LoginTextHandler: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let loginTextField = textField as? LoginTextField, let fieldType = (textField as! LoginTextField).fieldType else { return false }
        
        let textViewText = loginTextField.text ?? ""
        guard let NSStringTextfieldText = textViewText as NSString? else { return false }
        let updatedTextFieldText = NSStringTextfieldText.replacingCharacters(in: range, with: string)
        let allowChanges = shouldAllowChanges(forFieldType: fieldType, withUpdatedText: updatedTextFieldText)
        
        if allowChanges {
            delegate.updated(text: updatedTextFieldText, forFieldType: fieldType)
        }
        
        return allowChanges
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let loginTextField = textField as? LoginTextField else { return true }
        onReturnKey(forTextField: loginTextField)
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        guard let loginTextField = textField as? LoginTextField else { return true }
        updateStateAfterSelected(forLoginTextField: loginTextField)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let loginTextField = textField as? LoginTextField else { return }
        updateStateAfterUnselected(forLoginTextField: loginTextField)
    }
}
