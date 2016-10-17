//
//  ListingCollectionViewCell.swift
//  Mooch
//
//  Created by adam on 10/16/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

class ListingCollectionViewCell: UICollectionViewCell {
    
    static let Identifier = "ListingCollectionViewCell"
    
    @IBOutlet private var roundedView: RoundedView!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var gradientView: GradientView!
    @IBOutlet private var bottomLabel: UILabel!

    func set(bottomLabelText: String?) {
        bottomLabel.text = bottomLabelText
    }
    
    func set(photo: UIImage?) {
        guard let photo = photo else {
            imageView.image = nil
            return
        }
        imageView.image = photo
    }
    
    override func prepareForReuse() {
        set(photo: nil)
        set(bottomLabelText: nil)
    }
}
