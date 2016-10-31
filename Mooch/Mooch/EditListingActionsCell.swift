//
//  EditListingActionsCell.swift
//  Mooch
//
//  Created by adam on 10/30/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

protocol EditListingActionsCellDelegate: class {
    
    func onDone()
    func onCancel()
}

class EditListingActionsCell: UITableViewCell, EditListingField {
    
    static let Identifier = "EditListingActionsCell"
    static let EstimatedHeight: CGFloat = 146
    
    @IBOutlet weak var doneButton: RoundedButton!
    @IBOutlet weak var cancelButton: RoundedButton!
    
    weak var delegate: EditListingActionsCellDelegate!
    
    var fieldType: EditListingConfiguration.FieldType!
    
    @IBAction func onDone() {
        delegate.onDone()
    }
    
    @IBAction func onCancel() {
        delegate.onCancel()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        doneButton.backgroundColor = ThemeColors.moochRed.color()
        doneButton.setTitleColor(ThemeColors.moochWhite.color(), for: .normal)
        
        cancelButton.backgroundColor = ThemeColors.moochWhite.color()
        cancelButton.setTitleColor(ThemeColors.moochRed.color(), for: .normal)
        cancelButton.borderWidth = 2.0
        cancelButton.borderColor = ThemeColors.moochRed.color()
    }
}

