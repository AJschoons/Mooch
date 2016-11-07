//
//  ListingDetailsListingCell.swift
//  Mooch
//
//  Created by adam on 9/21/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

class ListingDetailsListingCell: UITableViewCell {

    static let Identifier = "ListingDetailsListingCell"
    static let EstimatedHeight: CGFloat = 125
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var postedLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
}
