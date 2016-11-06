//
//  Community.swift
//  Mooch
//
//  Created by adam on 9/6/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import CoreLocation

struct Community {
    
    //The required data for JSON initialization
    enum JSONInitializationError: Error {
        case id
        case address
        case name
        case pictureURL
        case latitude
        case longitude
    }
    
    enum JSONMapping: String {
        case id = "id"
        case address = "address"
        case name = "name"
        case pictureURL = "image_url"
        case latitude = "lat"
        case longitude = "long"
    }
    
    let id: Int
    let address: String
    let name: String
    let pictureURL: String
    let location: CLLocation
    
    //Distance from the user in meters. Has to be updated witht the updateDistance function
    var distanceFromUser: Double = 0.0
    
    mutating func updateAndCalculateDistance(fromUserLocation userLocation: CLLocation) {
        distanceFromUser = userLocation.distance(from: self.location)
    }
    
    //Designated initializer
    init(id: Int, address: String, name: String, pictureURL: String, location: CLLocation) {
        self.id = id
        self.address = address
        self.name = name
        self.pictureURL = pictureURL
        self.location = location
    }
    
    //Convenience JSON initializer
    init(json: JSON) throws {
        guard let id = json[JSONMapping.id.rawValue].int else { throw JSONInitializationError.id }
        guard let address = json[JSONMapping.address.rawValue].string else { throw JSONInitializationError.address }
        guard let name = json[JSONMapping.name.rawValue].string else { throw JSONInitializationError.name }
        guard let pictureURL = json[JSONMapping.pictureURL.rawValue].string else { throw JSONInitializationError.pictureURL }
        guard let latitudeString = json[JSONMapping.latitude.rawValue].string else { throw JSONInitializationError.latitude }
        guard let longitudeString = json[JSONMapping.longitude.rawValue].string else { throw JSONInitializationError.longitude }
        
        guard let latitude = Double(latitudeString) else {
            throw JSONInitializationError.latitude
        }
        
        guard let longitude = Double(longitudeString) else {
            throw JSONInitializationError.longitude
        }
        
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        self.init(id: id, address: address, name: name, pictureURL: pictureURL, location: location)
    }
}
