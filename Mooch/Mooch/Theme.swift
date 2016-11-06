//
//  Theme.swift
//  Mooch
//
//  Created by adam on 10/21/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

class Theming {
    
    static let InsetsForTileCollectionViewCells = UIEdgeInsets(top: 15.0, left: 15.0, bottom: 15.0, right: 15.0)
}

enum ThemeColors {
    
    case border
    case formSeperator
    
    case moochBlack
    case moochGray
    case moochRed
    case moochRedDisabled
    case moochWhite
    case moochYellow
    case moochYellowDisabled
    
    
    //Returns the Red, Green, Blue ints that should get divided by 255. Also the alpha, from 0.0-1.0
    private func colorRGBA() -> (Int, Int, Int, Float) {
        switch self {
        
        case .border:
            return ThemeColors.moochGray.colorRGBA()
            
        case .formSeperator:
            return (230, 233, 237, 1.0)
            
            
        case .moochBlack:
            return (0, 0, 0, 1.0)
            
        case .moochGray:
            return (210, 210, 210, 1.0)
            
        case .moochRed:
            return (252, 97, 58, 1.0)
            
        case .moochRedDisabled:
            return (252, 97, 58, 0.5)
            
        case .moochWhite:
            return (255, 255, 255, 1.0)
            
        case .moochYellow:
            return (252, 194, 58, 1.0)
            
        case .moochYellowDisabled:
            return (252, 232, 184, 1.0)
            
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
