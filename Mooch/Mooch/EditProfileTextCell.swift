//
//  EditProfileTextCell.swift
//  Mooch
//
//  Created by adam on 10/10/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

class EditProfileTextCell: UITableViewCell, EditProfileField {
    
    static let Identifier = "EditProfileTextCell"
    static let EstimatedHeight: CGFloat = 66
    
    @IBOutlet weak var fieldLabel: UILabel!
    @IBOutlet weak var textField: EditProfileTextField!
    
    var fieldType: EditProfileConfiguration.FieldType!
}
