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
    static let EstimatedHeight: CGFloat = 271

    @IBOutlet weak var userImageView: CircleImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userCommunityLabel: UILabel!
    
    //The short "header" that shows above the listing cells
    @IBOutlet private weak var userListingsCollectionHeaderView: UIView!
    
    //The highest superview for version of the header for .localUser mode
    @IBOutlet private weak var differentListingsToShowHeaderView: UIView!
    //The actual content view to add things to for the differentListingsToShowHeaderView
    @IBOutlet private weak var differentListingsToShowHeaderContentView: UIView!
    @IBOutlet weak var bottomBarDoubleSegmentedControl: BottomBarDoubleSegmentedControl!
    
    //The highest superview for version of the header for .seller mode
    @IBOutlet private weak var allListingsHeaderView: UIView!
    
    func setup(for mode: ProfileConfiguration.Mode) {
        switch mode {
        case .localUser:
            allListingsHeaderView.isHidden = true
            differentListingsToShowHeaderView.isHidden = false
            
        case .seller:
            allListingsHeaderView.isHidden = false
            differentListingsToShowHeaderView.isHidden = true
        }
    }
}
