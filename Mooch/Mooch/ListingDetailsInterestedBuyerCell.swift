//
//  ListingDetailsInterestedBuyerCell.swift
//  Mooch
//
//  Created by adam on 10/23/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

protocol ListingDetailsInterestedBuyerCellDelegate: class {
    
    func didAccept(exchange: Exchange)
}

class ListingDetailsInterestedBuyerCell: UITableViewCell {
    
    static let Identifier = "ListingDetailsInterestedBuyerCell"
    static let EstimatedHeight: CGFloat = 80
    
    @IBOutlet weak var buyerImageView: CircleImageView!
    @IBOutlet weak var buyerNameLabel: UILabel!
    @IBOutlet weak var acceptBuyerButton: RoundedButton!
    
    var exchange: Exchange!
    weak var delegate: ListingDetailsInterestedBuyerCellDelegate!
    
    @IBAction func onAcceptBuyer() {
        delegate.didAccept(exchange: exchange)
    }
}
