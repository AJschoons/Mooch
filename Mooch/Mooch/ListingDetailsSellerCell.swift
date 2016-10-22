//
//  ListingDetailsSellerCell.swift
//  Mooch
//
//  Created by adam on 10/21/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

class ListingDetailsSellerCell: UITableViewCell {
    
    static let Identifier = "ListingDetailsSellerCell"
    static let EstimatedHeight: CGFloat = 106
    
    @IBOutlet weak var sellerImageView: CircleImageView!
    @IBOutlet weak var sellerNameLabel: UILabel!
}
