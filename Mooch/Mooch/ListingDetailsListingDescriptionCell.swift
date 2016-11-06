//
//  ListingDetailsRatingActionCell.swift
//  Mooch
//
//  Created by adam on 9/21/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

class ListingDetailsListingDescriptionCell: UITableViewCell {
    
    static let Identifier = "ListingDetailsListingDescriptionCell"
    static let EstimatedHeight: CGFloat = 98
    
    @IBOutlet weak var topSeperator: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var bottomSeperator: UIView!
    
    override func awakeFromNib() {
        topSeperator.backgroundColor = ThemeColors.formSeperator.color()
        bottomSeperator.backgroundColor = ThemeColors.formSeperator.color()
    }
}
