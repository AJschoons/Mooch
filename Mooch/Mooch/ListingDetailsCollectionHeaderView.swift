//
//  ListingDetailsCollectionHeaderView.swift
//  Mooch
//
//  Created by adam on 11/6/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import GSKStretchyHeaderView
import UIKit

class ListingDetailsCollectionHeaderView: GSKStretchyHeaderView {
    
    static let Identifier = "ProfileCollectionHeaderView"
    static let EstimatedHeight: CGFloat = 314
    
    @IBOutlet var view: UIView!
    
    @IBOutlet weak var listingImageView: UIImageView!
    @IBOutlet weak var alertBannerView: UIView!
    @IBOutlet weak var alertBannerLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        Bundle.main.loadNibNamed("ListingDetailsCollectionHeaderView", owner: self, options: nil)
        self.addSubview(view)
        view.frame = self.bounds
        
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        Bundle.main.loadNibNamed("ListingDetailsCollectionHeaderView", owner: self, options: nil)
        self.addSubview(view)
        view.frame = frame
        
        setup()
    }
    
    private func setup() {
        alertBannerView.backgroundColor = ThemeColors.moochRed.color()
        alertBannerLabel.textColor = ThemeColors.moochWhite.color()
    }
}
