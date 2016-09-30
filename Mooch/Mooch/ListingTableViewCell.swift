//
//  ListingTableViewCell.swift
//  Mooch
//
//  Created by adam on 9/11/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

class ListingTableViewCell: UITableViewCell {
    
    static let Identifier = "ListingTableViewCell"
    static let EstimatedHeight: CGFloat = 57
    
    @IBOutlet weak var photo: RoundedImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
}
