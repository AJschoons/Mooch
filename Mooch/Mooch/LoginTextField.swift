//
//  LoginTextView.swift
//  Mooch
//
//  Created by adam on 10/3/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

class LoginTextField: UITextField, NavigableResponder {
    
    weak var nextNavigableResponder: UIResponder?
    
    var fieldType: LoginViewController.FieldType! {
        didSet {
            setPlaceholder(hidden: false)
        }
    }
    
    func setPlaceholder(hidden: Bool) {
        if hidden {
            attributedPlaceholder = nil
        } else {
            if let fieldType = fieldType {
                let centeredParagraphStyle = NSMutableParagraphStyle()
                centeredParagraphStyle.alignment = .center
                let placeholderText = self.placeholderText(forFieldType: fieldType)
                attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: [NSParagraphStyleAttributeName: centeredParagraphStyle])
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        setPlaceholder(hidden: false)
    }
    
    private func placeholderText(forFieldType fieldType: LoginViewController.FieldType) -> String {
        switch fieldType {
        case .email:
            return Strings.LoginTextField.emailPlaceholder.rawValue
        case .password:
            return Strings.LoginTextField.passwordPlaceholder.rawValue
        }
    }
}
