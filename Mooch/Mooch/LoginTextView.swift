//
//  LoginTextView.swift
//  Mooch
//
//  Created by adam on 10/3/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

@IBDesignable
class LoginTextView: NavigableTextView {
    
    enum State {
        case empty              //Text view is empty and unselected
        case emptySelected      //Text view is empty but selected
        case notEmpty           //Text view has text
    }
    
    var fieldType: LoginViewController.FieldType! {
        didSet {
            updateUI(forState: .empty)
        }
    }
    
    private(set) var state: State = .empty
    
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
    
    func updateUI(forState newState: State) {
        state = newState
        
        switch newState {
        case .empty:
            textColor = UIColor.lightGray
            if let fieldType = fieldType {
                text = placeholderText(forFieldType: fieldType)
            }
        case .emptySelected:
            textColor = UIColor.black
            text = ""
        case .notEmpty:
            textColor = UIColor.black
        }
    }
    
    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setup()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        textAlignment = .center
        updateUI(forState: state)
    }
    
    private func placeholderText(forFieldType fieldType: LoginViewController.FieldType) -> String {
        switch fieldType {
        case .email:
            return "Email"
        case .password:
            return "Password"
        }
    }
}
