//
//  EditListingTextCell.swift
//  Mooch
//
//  Created by adam on 9/18/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

class EditListingTextCell: UITableViewCell, EditListingField {

    static let Identifier = "EditListingTextCell"
    static let EstimatedHeight: CGFloat = 44
    
    @IBOutlet weak var fieldLabel: UILabel!
    
    @IBOutlet weak var textView: EditListingTextView! {
        didSet {
            //Removes extra space at top of text view
            textView.textContainerInset = UIEdgeInsets.zero
            textView.textContainer.lineFragmentPadding = 0
        }
    }
    
    @IBOutlet weak var bottomSeperator: UIView!
    
    var fieldType: EditListingConfiguration.FieldType!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        bottomSeperator.backgroundColor = ThemeColors.formSeperator.color()
    }
}
