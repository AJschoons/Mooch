//
//  ProfileConfiguration.swift
//  Mooch
//
//  Created by adam on 10/25/16.
//  Copyright © 2016 cse498. All rights reserved.
//

//A configuration to setup the ProfileViewController with
struct ProfileConfiguration {
    
    var mode: Mode
    
    var title: String
    var leftBarButtons: [BarButtonType]?
    var rightBarButtons: [BarButtonType]?
    
    //The bar buttons that can be added
    enum BarButtonType {
        case settings
    }
    
    enum Mode {
        case localUser
        case seller
    }
    
    static func defaultConfiguration(for mode: Mode) -> ProfileConfiguration {
        switch mode {
            
        case .localUser:
            return ProfileConfiguration(mode: .localUser, title: Strings.Profile.titleLocalUser.rawValue, leftBarButtons: nil, rightBarButtons: [.settings])
            
        case .seller:
            return ProfileConfiguration(mode: .seller, title: Strings.Profile.titleSellerProfile.rawValue, leftBarButtons: nil, rightBarButtons: nil)
        }
    }
}
