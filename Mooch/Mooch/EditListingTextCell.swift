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
    static let EstimatedHeight: CGFloat = 66
    
    @IBOutlet weak var fieldLabel: UILabel!
    @IBOutlet weak var textView: EditListingTextView!
    
    var fieldType: EditListingConfiguration.FieldType!
}
