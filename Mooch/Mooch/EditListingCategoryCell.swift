//
//  EditListingCategoryCell.swift
//  Mooch
//
//  Created by adam on 10/1/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

class EditListingCategoryCell: UITableViewCell, EditListingField {
    
    static let Identifier = "EditListingCategoryCell"
    static let EstimatedHeight: CGFloat = 44
    
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var categoryNameLabel: UILabel!
    
    var fieldType: EditListingConfiguration.FieldType!
}
