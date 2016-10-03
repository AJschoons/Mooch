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
    
    fileprivate func onReturnKey(forTextView textView: NavigableTextView) {
        //Bring the keyboard to the next textview if it exists, else hide it
        if let nextTextField = textView.nextNavigableTextView {
            nextTextField.becomeFirstResponder()
        } else {
            textView.resignFirstResponder()
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
        return true
    }
    
    fileprivate func shouldAllowChangesForPasswordField(withUpdatedText updatedText: String) -> Bool {
        return true
    }
    
    fileprivate func updateStateForAllowedChanges(forLoginTextView loginTextView: LoginTextView, withUpdatedText updatedText: String) {
        if !isEmpty(updatedText) {
            loginTextView.updateUI(forState: .notEmpty)
        }
    }
    
    fileprivate func updateStateAfterSelected(forLoginTextView loginTextView: LoginTextView) {
        if loginTextView.state == .empty {
            loginTextView.updateUI(forState: .emptySelected)
        }
    }
    
    fileprivate func updateStateAfterUnselected(forLoginTextView loginTextView: LoginTextView) {
        if isEmpty(loginTextView.text) {
            loginTextView.updateUI(forState: .empty)
        }
    }
}

extension LoginTextHandler: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let loginTextView = textView as? LoginTextView, let fieldType = (textView as! LoginTextView).fieldType else { return false }
        
        //Handle the return key
        guard text != "\n" else {
            onReturnKey(forTextView: loginTextView)
            return false
        }
        
        let textViewText = loginTextView.text ?? ""
        guard let NSStringTextfieldText = textViewText as NSString? else { return false }
        let updatedTextViewText = NSStringTextfieldText.replacingCharacters(in: range, with: text)
        let allowChanges = shouldAllowChanges(forFieldType: fieldType, withUpdatedText: updatedTextViewText)
        
        if allowChanges {
            delegate.updated(text: updatedTextViewText, forFieldType: fieldType)
            updateStateForAllowedChanges(forLoginTextView: loginTextView, withUpdatedText: updatedTextViewText)
        }
        
        return allowChanges
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        guard let loginTextView = textView as? LoginTextView else { return }
        updateStateAfterSelected(forLoginTextView: loginTextView)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        guard let loginTextView = textView as? LoginTextView else { return }
        updateStateAfterUnselected(forLoginTextView: loginTextView)
    }
}
