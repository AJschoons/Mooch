//
//  Extensions.swift
//  Mooch
//
//  Created by Zhiming Jiang on 10/22/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import Foundation
import UIKit
extension String {
    func replace(string:String, replacement:String) -> String {
        return self.replacingOccurrences(of: string, with: replacement)
    }
    
    func removeWhitespace() -> String {
        return self.replace(string: " ", replacement: "")
    }
    
    var hexColor: UIColor {
        let hex = trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return .clear
        }
        return UIColor(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

extension Date {
    func isLessThanDate(dateToCompare: Date) -> Bool {
        var isLess = false
        if self.compare(dateToCompare) == ComparisonResult.orderedAscending {
            isLess = true
        }
        return isLess
    }
    
    func isGreaterThanDate(dateToCompare: Date) -> Bool {
        var isGreater = false
        if self.compare(dateToCompare as Date) == ComparisonResult.orderedDescending {
            isGreater = true
        }
        return isGreater
    }
    
    func addDays(daysToAdd: Int) -> Date {
        let secondsInDays: TimeInterval = Double(daysToAdd) * 60 * 60 * 24
        let dateWithDaysAdded: Date = self.addingTimeInterval(secondsInDays)
        return dateWithDaysAdded
    }
}

extension UIImage {
    func imageWithColor(color: UIColor) -> UIImage? {
        var image: UIImage? = withRenderingMode(.alwaysTemplate)
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        color.set()
        image?.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

extension UITabBarController {
    
    //http://stackoverflow.com/questions/6325457/getting-the-frame-of-a-particular-tab-bar-item
    func frameForTab(in tabBar: UITabBar, withIndex index: Int) -> CGRect {
        
        var frames = tabBar.subviews.flatMap { (subview: UIView) -> CGRect? in
            if let view = subview as? UIControl {
                return view.frame
            }
            return nil
        }
        
        frames.sort { $0.origin.x < $1.origin.x }
        
        if frames.count > index {
            return frames[index]
        }
        
        return frames.last ?? CGRect.zero
    }
}
