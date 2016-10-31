//
//  EditProfileCommunityCell.swift
//  Mooch
//
//  Created by adam on 10/31/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

class EditProfileCommunityCell: UITableViewCell, EditProfileField {
    
    static let Identifier = "EditProfileCommunityCell"
    static let EstimatedHeight: CGFloat = 40
    
    @IBOutlet weak var fieldLabel: UILabel!
    @IBOutlet weak var selectedOptionLabel: UILabel!
    @IBOutlet weak var bottomSeperator: UIView!
    
    var fieldType: EditProfileConfiguration.FieldType!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        bottomSeperator.backgroundColor = ThemeColors.formSeperator.color()
    }
}
