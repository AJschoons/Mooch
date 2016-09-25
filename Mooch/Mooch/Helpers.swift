//
//  Helpers.swift
//  Mooch
//
//  Created by adam on 9/6/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import Foundation

private let apiDateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    return dateFormatter
}()

func date(fromAPITimespamp apiTimestamp: String) -> Date {
    return apiDateFormatter.date(from: apiTimestamp)!
}
