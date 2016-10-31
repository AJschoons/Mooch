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
    static let EstimatedHeight: CGFloat = 363
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var alertBannerView: UIView!
    @IBOutlet weak var alertBannerLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var postedLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
}
