//
//  ProfileCollectionHeaderView.swift
//  Mooch
//
//  Created by adam on 10/25/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

class ProfileCollectionHeaderView: UICollectionReusableView {
    
    static let Identifier = "ProfileCollectionHeaderView"
    static let EstimatedHeight: CGFloat = 266
    

    @IBOutlet private weak var userImageView: CircleImageView!
    @IBOutlet private weak var userNameLabel: UILabel!
    @IBOutlet private weak var userCommunityLabel: UILabel!
    
    @IBOutlet private weak var userListingsCollectionHeaderView: UIView!
    @IBOutlet private weak var allListingsHeaderView: UIView!
    
    func setup(for mode: ProfileConfiguration.Mode) {
        switch mode {
        case .localUser:
            allListingsHeaderView.isHidden = true
        case .seller:
            allListingsHeaderView.isHidden = false
        }
    }
}
