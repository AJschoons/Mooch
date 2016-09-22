//
//  ListingDetailsActionCell.swift
//  Mooch
//
//  Created by adam on 9/21/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

protocol ListingDetailsActionCellDelegate: class {
    func onActionButton(forFieldType: ListingDetailsViewController.Configuration.FieldType)
}

class ListingDetailsActionCell: UITableViewCell {
    
    static let Identifier = "ListingDetailsActionCell"
    static let EstimatedHeight: CGFloat = 44
    
    @IBOutlet weak var actionButton: RoundedButton!
    weak var delegate: ListingDetailsActionCellDelegate!
    var fieldType: ListingDetailsViewController.Configuration.FieldType!
    
    @IBAction func onActionButton() {
        print(actionButton.titleLabel?.text)
        delegate.onActionButton(forFieldType: fieldType)
    }
}
