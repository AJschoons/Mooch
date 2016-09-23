//
//  Errors.swift
//  Mooch
//
//  Created by adam on 9/6/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import Foundation

enum InitializationError: Error {
    case insufficientJSONInformationForInitialization
}

enum MoochAPIError: Error {
    case noResponseValueForJSONMapping      //MoochAPI response did not have a value to convert to JSON
    case swiftyJSONConversionFailed         //MoochAPI response could not be converted to SwiftyJSON
}
