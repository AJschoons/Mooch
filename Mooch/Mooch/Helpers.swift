//
//  Helpers.swift
//  Mooch
//
//  Created by adam on 9/6/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import Foundation
import UIKit

private let apiDateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    return dateFormatter
}()

func date(fromAPITimespamp apiTimestamp: String) -> Date {
    return apiDateFormatter.date(from: apiTimestamp)!
}

func isEmpty(_ string: String?) -> Bool {
    guard let string = string else { return true }
    return string == ""
}

//Returns the number of days since the current date
fileprivate let calendar = Calendar.current
func daysFromTodaySince(previousDate: Date) -> Int {
    let now = calendar.startOfDay(for: Date())
    let previousDay = calendar.startOfDay(for: previousDate)
    
    let dayComponentSet = Set<Calendar.Component>([Calendar.Component.day])
    let compenents = calendar.dateComponents(dayComponentSet, from: previousDay, to: now)
    
    guard let numberOfDays = compenents.day else {
        return 1
    }
    
    return max(numberOfDays, 0)
}

// Get the largest square portion of an image from the center
func cropBiggestCenteredSquareImage(from image: UIImage, toLength length: CGFloat) -> UIImage {
    // Get size of current image
    let size = image.size
    if (size.width == size.height) && (size.width == length) {
        return image
    }
    
    let newSize = CGSize(width: length, height: length)
    var ratio: Double
    var delta: Double
    var offset: CGPoint
    
    // Make a new square size that is the resized image width
    let sz = CGSize(width: newSize.width, height: newSize.width)
    
    // Figure out if the picture is landscape or portrait, then calculate scale factor and offset
    if image.size.width > image.size.height {
        ratio = Double(newSize.height / image.size.height)
        delta = ratio * Double((image.size.width - image.size.height))
        offset = CGPoint(x: CGFloat(delta) / 2, y: 0)
    } else {
        ratio = Double(newSize.width / image.size.width)
        delta = ratio * Double((image.size.height - image.size.width))
        offset = CGPoint(x: 0, y: CGFloat(delta) / 2)
    }
    
    // Make the final clipping rect based on the calculated values
    let clipRect = CGRect(x: -offset.x, y: -offset.y, width: CGFloat(ratio) * image.size.width, height: CGFloat(ratio) * image.size.height)
    
    // Start a new context, with scale factor 0.0 so retina displays get high quality image
    UIGraphicsBeginImageContextWithOptions(sz, true, 0.0)
    
    UIRectClip(clipRect)
    image.draw(in: clipRect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage!
}
