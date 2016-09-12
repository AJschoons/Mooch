//
//  RoundedButton.swift
//  Mooch
//
//  Created by adam on 9/12/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

//A button that supports editing how rounded the corners are and rendering the changes in interface builder
@IBDesignable
class RoundedButton: UIButton {
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
}
