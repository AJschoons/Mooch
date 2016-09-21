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
    
    // MARK: Public variables
    
    //Used to know which textfield cell should have a "done" return keyboard type instead of a "next"
    var indexOfLastTextfieldCell: Int?
    
    
    // MARK: Private variables
    
    //The spacing between cells is 14, so half that is 7
    //Used for knowing how much to offset due to keyboard so it doesn't go right under the cell
    private let HalfTheSpacingBetweenCells: CGFloat = 7.0
    
    //Used to track the setup of the navigable text fields between configurations
    fileprivate var lastNavigableTextFieldConfigured: NavigableTextField?
    
    //Used to restore the tableView insets after the keyboard disappears
    private var originalContentInsets = UIEdgeInsetsMake(64, 0, 0, 0)
    
    @IBOutlet weak fileprivate var tableView: UITableView! {
        didSet {
            //Must set these to get cells to use autolayout and self-size themselves in the table
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.estimatedRowHeight = EditListingTextfieldCell.EstimatedHeight
        }
    }
    
    weak var delegate: EditListingTableHandlerDelegate!
    
    
    // MARK: Actions
    
    // MARK: Public methods
    
    //Based on https://gist.github.com/TimMedcalf/9505416
    func onKeyboardDidShow(withRect keyboardRect: CGRect, andAnimationDuration animationDuration: Double) {
        let convertedKeyboardRect = tableView.convert(keyboardRect, from: nil)
        let intersectRect = convertedKeyboardRect.intersection(tableView.bounds)
        guard !intersectRect.isNull else { return }
        
        UIView.animate(withDuration: animationDuration) {
            let inset = UIEdgeInsetsMake(self.originalContentInsets.top, 0, intersectRect.height + self.HalfTheSpacingBetweenCells, 0)
            self.tableView.contentInset = inset
            self.tableView.scrollIndicatorInsets = inset
        }
    }
    
    //Based on https://gist.github.com/TimMedcalf/9505416
    func onKeyboardWillHide(withAnimationDuration animationDuration: Double) {
        UIView.animate(withDuration: animationDuration) {
            self.tableView.contentInset = self.originalContentInsets
            self.tableView.scrollIndicatorInsets = self.originalContentInsets
        }
    }
    
    //Returns true if a field type maps to a EditListingTextFieldCell
    func isTextField(forFieldType fieldType: EditListingViewController.Configuration.FieldType) -> Bool {
        switch fieldType {
        case .photo, .quantity:
            return false
        default:
            return true
        }
    }
    
    // MARK: Private methods
    
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
    fileprivate func configure(editListingTextfieldCell cell: EditListingTextfieldCell, withFieldType fieldType: EditListingViewController.Configuration.FieldType, andIndexPath indexPath: IndexPath) {
        
        cell.textfield.placeholder = placeholderText(forTextFieldFieldType: fieldType)
        cell.textfield.keyboardType = keyboardType(forTextFieldFieldType: fieldType)
        cell.textfield.delegate = self
        
        //Make the last cell have done key instead of next
        var returnKeyType: UIReturnKeyType!
        if let _ = indexOfLastTextfieldCell, indexOfLastTextfieldCell! == indexPath.row {
            returnKeyType = .done
        } else {
            returnKeyType = .next
        }
        cell.textfield.returnKeyType = returnKeyType
        
        //Setup the order of textfields to navigate
        if let previousTextfield = lastNavigableTextFieldConfigured {
            previousTextfield.nextNavigableTextField = cell.textfield
        } else {
            cell.textfield.nextNavigableTextField = nil
        }
        
        lastNavigableTextFieldConfigured = cell.textfield
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
    
    fileprivate func numberOfRows() -> Int {
        return delegate.getConfiguration().fields.count
    }
}

extension EditListingTableHandler: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Clear out any previously saved textfields when setting up the first row
        if indexPath.row == 0 {
            lastNavigableTextFieldConfigured = nil
        }
        
        let fieldTypeForRow = fieldType(forIndexPath: indexPath)
        let identifier = cellIdentifer(forFieldType: fieldTypeForRow)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        if let textfieldCell = cell as? EditListingTextfieldCell {
            configure(editListingTextfieldCell: textfieldCell, withFieldType: fieldTypeForRow, andIndexPath: indexPath)
        }
        
        return cell
    }
}

extension EditListingTableHandler: UITableViewDelegate {
    
}

extension EditListingTableHandler: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let navigableTextField = textField as? NavigableTextField {
            //Bring the keyboard to the next textfield if it exists, else hide it
            if let nextTextField = navigableTextField.nextNavigableTextField {
                nextTextField.becomeFirstResponder()
            } else {
                navigableTextField.resignFirstResponder()
            }
        }
        
        return true
    }
}
