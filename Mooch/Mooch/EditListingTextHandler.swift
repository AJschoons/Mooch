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
    func onTextViewDidChangeSize(withHeightDifference heightDifferrence: CGFloat)
}

class EditListingTextHandler: NSObject {
    
    // MARK: Public variables
    
    weak var delegate: EditListingTextHandlerDelegate!
    
    
    // MARK: Private variables
    
    private let NumbersAllowedLeftOfPriceDecimal = 3
    private let NumbersAllowedRightOfPriceDecimal = 2
    private let MaxTitleFieldCharacters = 30
    private let MaxDescriptionFieldCharacters = 200
    private let MaxTagFieldCharacters = 12
    
    //These variables are used to check if the text view size height has changed
    fileprivate var lastEditedTextView: UITextView?
    fileprivate var lastEditedTextViewSizeThatFits: CGSize?
    
    // MARK: Actions
    
    // MARK: Public methods
    
    // MARK: Private methods
    
    fileprivate func onReturnKey(forTextView textView: EditListingTextView) {
        //Bring the keyboard to the next textview if it exists, else hide it
        if let nextTextField = textView.nextNavigableTextView {
            nextTextField.becomeFirstResponder()
        } else {
            textView.resignFirstResponder()
        }
    }
    
    fileprivate func shouldAllowChanges(forFieldType fieldType: EditListingConfiguration.FieldType, withUpdatedText updatedText: String) -> Bool {
        var allowChanges: Bool
        switch fieldType {
        case .title:
            allowChanges = shouldAllowChangesForTitleField(withUpdatedText: updatedText)
        case .description:
            allowChanges = shouldAllowChangesForDescriptionField(withUpdatedText: updatedText)
        case .price:
            allowChanges = shouldAllowChangesForPriceField(withUpdatedText: updatedText)
        case .tag:
            allowChanges = shouldAllowChangesForTagField(withUpdatedText: updatedText)
        default:
            allowChanges = false
        }
        
        return allowChanges
    }
    
    fileprivate func shouldAllowChangesForTitleField(withUpdatedText updatedText: String) -> Bool {
        return updatedText.characters.count <= MaxTitleFieldCharacters
    }
    
    fileprivate func shouldAllowChangesForDescriptionField(withUpdatedText updatedText: String) -> Bool {
        return updatedText.characters.count <= MaxDescriptionFieldCharacters
    }
    
    fileprivate func shouldAllowChangesForTagField(withUpdatedText updatedText: String) -> Bool {
        if updatedText.contains(" ") {
            return false
        }
        
        return updatedText.characters.count <= MaxTagFieldCharacters
    }
    
    //Only allows changes if it fits into the ###.## decimal format (3 numbers leading the decimal point and two following)
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

extension EditListingTextHandler: UITextViewDelegate {
    
    @nonobjc func textView(_ textView: UITextView, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let editListingTextView = textView as? EditListingTextView, let fieldType = (textView as! EditListingTextView).fieldType else { return false }
        
        //Handle the return key
        guard string != "\n" else {
            onReturnKey(forTextView: editListingTextView)
            return false
        }
        
        let textViewText = editListingTextView.text ?? ""
        guard let NSStringTextfieldText = textViewText as NSString? else { return false }
        let updatedTextViewText = NSStringTextfieldText.replacingCharacters(in: range, with: string)
        let allowChanges = shouldAllowChanges(forFieldType: fieldType, withUpdatedText: updatedTextViewText)
        
        if allowChanges {
            delegate.updated(text: updatedTextViewText, forFieldType: fieldType)
            
            //Track this to see if the height changed
            lastEditedTextView = textView
            lastEditedTextViewSizeThatFits = textView.sizeThatFits(CGSize(width: textView.frame.size.width, height: CGFloat(MAXFLOAT)))
        }
        
        return allowChanges
    }
    
    func textViewDidChange(_ textView: UITextView) {
        guard let lastEditedTextView = lastEditedTextView, let lastSizeThatFits = lastEditedTextViewSizeThatFits else { return }
        guard lastEditedTextView == textView else { return }
        let newSizeThatFits = textView.sizeThatFits(CGSize(width: textView.frame.size.width, height: CGFloat(MAXFLOAT)))
        
        //Notofy the delegate when the height changes
        if newSizeThatFits.height != lastSizeThatFits.height {
            let heightDifference = newSizeThatFits.height - lastSizeThatFits.height
            delegate!.onTextViewDidChangeSize(withHeightDifference: heightDifference)
        }
    }
}
