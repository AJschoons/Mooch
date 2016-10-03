//
//  RoundedImageView.swift
//  Mooch
//
//  Created by adam on 9/27/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

//An image view that supports editing how rounded the corners are and rendering the changes in interface builder
@IBDesignable
class RoundedImageView: UIImageView {

    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
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
