//
//  EditListingTextView.swift
//  Mooch
//
//  Created by adam on 9/25/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

@IBDesignable
class EditListingTextView: UITextView, NavigableResponder {

    weak var nextNavigableResponder: UIResponder?
    
    var fieldType: EditListingConfiguration.FieldType!
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }
}
