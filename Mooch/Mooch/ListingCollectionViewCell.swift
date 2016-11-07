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
    
    func set(photo: UIImage?, withBackgroundColor backgroundColor: UIColor, animated: Bool) {
        guard let photo = photo else {
            gradientView.isHidden = true
            imageView.image = nil
            imageView.alpha = 0.0
            roundedView.backgroundColor = backgroundColor
            return
        }
        
        gradientView.isHidden = false
        imageView.image = photo
        
        if animated {
            UIView.animate(withDuration: 0.3) {
                self.imageView.alpha = 1.0
            }
        } else {
            self.imageView.alpha = 1.0
        }
    }
}
