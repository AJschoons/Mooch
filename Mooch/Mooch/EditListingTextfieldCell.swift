//
//  EditListingTextfieldCell.swift
//  Mooch
//
//  Created by adam on 9/18/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

class EditListingTextfieldCell: UITableViewCell, EditListingField {

    static let Identifier = "EditListingTextfieldCell"
    static let EstimatedHeight: CGFloat = 44
    
    @IBOutlet weak var textfield: EditListingTextfield!
    
    var fieldType: EditListingConfiguration.FieldType!
}
