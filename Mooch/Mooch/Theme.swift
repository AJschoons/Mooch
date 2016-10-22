//
//  Theme.swift
//  Mooch
//
//  Created by adam on 10/21/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

enum ThemeColors {
    
    case formSeperator
    
    case listingDetailsActionBackground
    case listingDetailsActionText
    
    //Returns the Red, Green, Blue ints that should get divided by 255. Also the alpha, from 0.0-1.0
    private func colorRGBA() -> (Int, Int, Int, Float) {
        switch self {
        
        case .formSeperator:
            return (200, 200, 200, 1.0)
            
        case .listingDetailsActionBackground:
            return (85, 85, 85, 1.0)
            
        case .listingDetailsActionText:
            return (255, 255, 255, 1.0)
        }
    }
    
    func color() -> UIColor {
        let rgba = self.colorRGBA()
        let base255 = CGFloat(255.0)
        
        let red = Float(CGFloat(rgba.0) / base255)
        let green = Float(CGFloat(rgba.1) / base255)
        let blue = Float(CGFloat(rgba.2) / base255)
        let alpha = rgba.3
        
        return UIColor(colorLiteralRed: red, green: green, blue: blue, alpha: alpha)
    }
}
