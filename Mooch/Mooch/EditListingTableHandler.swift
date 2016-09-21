//
//  EditListingTableHandler.swift
//  Mooch
//
//  Created by adam on 9/19/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

protocol EditListingTableHandlerDelegate: class {
    func getConfiguration() -> EditListingViewController.Configuration
}

class EditListingTableHandler: NSObject {
    
    private let HalfTheSpacingBetweenCells: CGFloat = 7.0
    
    @IBOutlet weak fileprivate var tableView: UITableView! {
        didSet {
            
            //Must set these to get cells to use autolayout and self-size themselves in the table
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.estimatedRowHeight = EditListingTextfieldCell.EstimatedHeight
        }
    }
    
    weak var delegate: EditListingTableHandlerDelegate!
    
    //Based on https://gist.github.com/TimMedcalf/9505416
    func onKeyboardDidShow(withRect keyboardRect: CGRect, andAnimationDuration animationDuration: Double) {
        let convertedKeyboardRect = tableView.convert(keyboardRect, from: nil)
        let intersectRect = convertedKeyboardRect.intersection(tableView.bounds)
        guard !intersectRect.isNull else { return }
        
        UIView.animate(withDuration: animationDuration) {
            let inset = UIEdgeInsetsMake(0, 0, intersectRect.height + HalfTheSpacingBetweenCells, 0)
            self.tableView.contentInset = inset
            self.tableView.scrollIndicatorInsets = inset
        }
    }
    
    //Based on https://gist.github.com/TimMedcalf/9505416
    func onKeyboardWillHide(withAnimationDuration animationDuration: Double) {
        UIView.animate(withDuration: animationDuration) {
            self.tableView.contentInset = UIEdgeInsets.zero
            self.tableView.scrollIndicatorInsets = UIEdgeInsets.zero
        }
    }
    
    //Returns the field type that a row is displaying
    fileprivate func fieldType(forIndexPath indexPath: IndexPath) -> EditListingViewController.Configuration.FieldType {
        return delegate!.getConfiguration().fields[indexPath.row]
    }
    
    //Returns the identifier string for
    fileprivate func cellIdentifer(forFieldType fieldType: EditListingViewController.Configuration.FieldType) -> String {
        
        switch fieldType {
        case .photo:
            return EditListingPhotoCell.Identifier
        case .quantity:
            return EditListingQuantityCell.Identifier
        default:
            return EditListingTextfieldCell.Identifier
        }
    }
    
    //Configures an EditListingTextfieldCell based on the field type
    fileprivate func configure(editListingTextfieldCell cell: EditListingTextfieldCell, withFieldType fieldType: EditListingViewController.Configuration.FieldType) {
        
        cell.textfield.placeholder = placeholderText(forTextFieldFieldType: fieldType)
        cell.textfield.keyboardType = keyboardType(forTextFieldFieldType: fieldType)
    }
    
    //Returns the placeholder text for fieldTypes that are used in the EditListingTextField cells
    fileprivate func placeholderText(forTextFieldFieldType textfieldFieldType: EditListingViewController.Configuration.FieldType) -> String {
        switch textfieldFieldType {
        case .title:
            return "Title"
        case .description:
            return "Description"
        case .category:
            return "Tags"
        case .price:
            return "Price"
        default:
            return ""
        }
    }
    
    //Returns the placeholder text for fieldTypes that are used in the EditListingTextField cells
    fileprivate func keyboardType(forTextFieldFieldType textfieldFieldType: EditListingViewController.Configuration.FieldType) -> UIKeyboardType {
        switch textfieldFieldType {
        case .price:
            return .numbersAndPunctuation
        default:
            return .default
        }
    }
}

extension EditListingTableHandler: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return delegate.getConfiguration().fields.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let fieldTypeForRow = fieldType(forIndexPath: indexPath)
        let identifier = cellIdentifer(forFieldType: fieldTypeForRow)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        if let textfieldCell = cell as? EditListingTextfieldCell {
            configure(editListingTextfieldCell: textfieldCell, withFieldType: fieldTypeForRow)
        }
        
        return cell
    }
}

extension EditListingTableHandler: UITableViewDelegate {
    
}
