//
//  ListingsPriceFilterTableViewCell.swift
//  Mooch
//
//  Created by adam on 10/20/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

protocol ListingsPriceFilterTableViewCellDelegate: class {
    func priceRangeDidChange(min: Int, max: Int)
}

class ListingsPriceFilterTableViewCell: UITableViewCell {

    static let Identifier = "ListingsPriceFilterTableViewCell"
    static let EstimatedHeight: CGFloat = 100
    
    @IBOutlet private weak var priceRangeSlider: RangeSlider!
    @IBOutlet private weak var minimumPriceLabel: UILabel!
    @IBOutlet private weak var maximumPriceLabel: UILabel!
    
    var delegate: ListingsPriceFilterTableViewCellDelegate!
    
    @IBAction func onPriceRangeSliderValueChange() {
        delegate.priceRangeDidChange(min: Int(priceRangeSlider.lowerValue), max: Int(priceRangeSlider.upperValue))
        updateLabels()
    }
    
    func setPriceRange(min: Int, max: Int) {
        guard min >= Int(priceRangeSlider.minimumValue) && max <= Int(priceRangeSlider.maximumValue) else { return }
        priceRangeSlider.lowerValue = Double(min)
        priceRangeSlider.upperValue = Double(max)
        updateLabels()
    }
    
    private func updateLabels() {
        minimumPriceLabel.text = "Min: $\(Int(priceRangeSlider.lowerValue))"
        maximumPriceLabel.text = "Max: $\(Int(priceRangeSlider.upperValue))"
    }
}
