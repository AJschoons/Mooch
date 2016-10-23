//
//  ListingDetailsInterestedBuyerCell.swift
//  Mooch
//
//  Created by adam on 10/23/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

protocol ListingDetailsInterestedBuyerCellDelegate: class {
    
    func didAccept(buyer: User)
}

class ListingDetailsInterestedBuyerCell: UITableViewCell {
    
    static let Identifier = "ListingDetailsInterestedBuyerCell"
    static let EstimatedHeight: CGFloat = 70
    
    @IBOutlet weak var buyerImageView: CircleImageView!
    @IBOutlet weak var buyerNameLabel: UILabel!
    @IBOutlet weak var acceptBuyerButton: RoundedButton!
    
    var buyer: User!
    weak var delegate: ListingDetailsInterestedBuyerCellDelegate!
    
    @IBAction func onAcceptBuyer() {
        delegate.didAccept(buyer: buyer)
    }
}
