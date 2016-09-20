//
//  EditListingQuantityCell.swift
//  Mooch
//
//  Created by adam on 9/20/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

class EditListingQuantityCell: UITableViewCell, EditListingField {
    
    static let Identifier = "EditListingQuantityCell"
    static let EstimatedHeight: CGFloat = 44
    
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var quantityCountLabel: UILabel!
    
    @IBOutlet weak var stepper: UIStepper! {
        didSet {
            stepper.minimumValue = 1.0
            stepper.maximumValue = 100.0
            stepper.stepValue = 1.0
        }
    }
    
    var fieldType: EditListingViewController.Configuration.FieldType!
    
    //The current integer value of the stepper
    private var quantity: Int = 1 {
        didSet {
            guard quantity >= 1 else {
                return
            }
            
            quantityCountLabel.text = String(quantity)
        }
    }
    
    @IBAction func onStepperValueDidChange() {
        quantity = Int(stepper.value)
    }
}
