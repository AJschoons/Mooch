//
//  CommunityCollectionViewCell.swift
//  Mooch
//
//  Created by adam on 10/19/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

class CommunityCollectionViewCell: UICollectionViewCell {

    static let Identifier = "CommunityCollectionViewCell"
    
    @IBOutlet private var roundedView: RoundedView!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var nameTextView: UITextView! {
        didSet {
            //Removes extra space at top of text view
            nameTextView.textContainerInset = UIEdgeInsets.zero
            nameTextView.textContainer.lineFragmentPadding = 0
        }
    }
    
    static func fromNib() -> CommunityCollectionViewCell?
    {
        var cell: CommunityCollectionViewCell?
        guard let nibViews = Bundle.main.loadNibNamed(CommunityCollectionViewCell.Identifier, owner: nil, options: nil) else
        {
            return nil
        }
        
        for nibView in nibViews {
            if let cellView = nibView as? CommunityCollectionViewCell {
                cell = cellView
            }
        }
        
        return cell
    }
    
    func set(nameText: String?) {
        nameTextView.text = nameText
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
        set(nameText: nil)
    }
}
