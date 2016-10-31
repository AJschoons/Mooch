//
//  EditListingTableHandler.swift
//  Mooch
//
//  Created by adam on 9/19/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

protocol EditListingTableHandlerDelegate: class, EditListingActionsCellDelegate {
    func getConfiguration() -> EditListingConfiguration
    func getTextHandler() -> EditListingTextHandler
    func getEditedListingInformation() -> EditedListingInformation
    func didSelectCategoryCell()
}

class EditListingTableHandler: NSObject {
    
    // MARK: Public variables
    
    //Used to know which textfield cell should have a "done" return keyboard type instead of a "next"
    var indexOfLastTextfieldCell: Int?
    
    
    // MARK: Private variables
    
    //Used for knowing how much to offset due to keyboard so it doesn't go right under the text field
    private let HalfTheSpacingBetweenCells: CGFloat = 5.0
    
    //Used to track the setup of the navigable text views between configurations
    fileprivate var lastTextViewConfigured: EditListingTextView?
    
    //Used to restore the tableView insets after the keyboard disappears
    private var originalContentInsets = UIEdgeInsetsMake(64, 0, 0, 0)
    
    //Used to get the exact height for each cell so that the table view isn't jerky with beginUpdates and endUpdates
    fileprivate var heightForIndexPaths = [IndexPath : CGFloat]()
    
    @IBOutlet weak fileprivate var tableView: UITableView! {
        didSet {
            //Must set these to get cells to use autolayout and self-size themselves in the table
            tableView.rowHeight = UITableViewAutomaticDimension
            //tableView.estimatedRowHeight = 1000
        }
    }
    
    weak var delegate: EditListingTableHandlerDelegate!
    
    
    // MARK: Actions
    
    // MARK: Public methods
    
    func reloadData() {
        tableView.reloadData()
    }
    
    //Resizes and repositions the table view based on the height difference
    func onTextDidChangeSize(withHeightDifference heightDifferrence: CGFloat) {
        //Automatically resizes the table view due to text changes
        tableView.beginUpdates()
        tableView.endUpdates()
        
        //Animate to account for the change in height
        var newOffset = self.tableView.contentOffset
        newOffset.y += heightDifferrence
        tableView.setContentOffset(newOffset, animated: true)
    }
    
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
    func isTextField(forFieldType fieldType: EditListingConfiguration.FieldType) -> Bool {
        switch fieldType {
        case .title, .description, .price, .quantity:
            return true
        default:
            return false
        }
    }
    
    // MARK: Private methods
    
    //Returns the field type that a row is displaying
    fileprivate func fieldType(forIndexPath indexPath: IndexPath) -> EditListingConfiguration.FieldType {
        return delegate!.getConfiguration().fields[indexPath.row]
    }
    
    //Returns the identifier string for the field type
    fileprivate func cellIdentifer(forFieldType fieldType: EditListingConfiguration.FieldType) -> String {
        
        switch fieldType {
        case .photo:
            return EditListingPhotoCell.Identifier
        case .category:
            return EditListingCategoryCell.Identifier
        case .actions:
            return EditListingActionsCell.Identifier
        default:
            return EditListingTextCell.Identifier
        }
    }
    
    //Configures an EditListingPhotoCell
    fileprivate func configure(editListingPhotoCell cell: EditListingPhotoCell) {
        if let photo = delegate.getEditedListingInformation().photo {
            cell.photoImageView.image = photo
        }
    }
    
    //Configures an EditListingCategoryCell
    fileprivate func configure(editListingCategoryCell cell: EditListingCategoryCell) {
        var categoryNameText = Strings.EditListing.unselectedCategory.rawValue
        if let selectedCategoryId = delegate.getEditedListingInformation().categoryId {
            if let selectedCategory = ListingCategoryManager.sharedInstance.getListingCategory(withId: selectedCategoryId) {
                categoryNameText = selectedCategory.name
            } else {
                categoryNameText = Strings.SharedErrors.invalidCategory.rawValue
            }
        }
        cell.categoryNameLabel.text = categoryNameText
    }
    
    //Configures an EditListingActionsCell
    fileprivate func configure(editListingActionsCell cell: EditListingActionsCell) {
        cell.delegate = delegate
    }

    //Configures an EditListingTextCell based on the field type
    fileprivate func configure(editListingTextCell cell: EditListingTextCell, withFieldType fieldType: EditListingConfiguration.FieldType, andIndexPath indexPath: IndexPath) {
        
        cell.fieldLabel.text = "\(fieldLabel(forTextFieldType: fieldType)):"
        cell.textView.keyboardType = keyboardType(forTextFieldFieldType: fieldType)
        cell.textView.fieldType = fieldType
        cell.textView.delegate = self
        
        if let text = delegate.getEditedListingInformation().string(for: fieldType) {
            cell.textView.text = text
        }
        
        //Make the last cell have done key instead of next
        var returnKeyType: UIReturnKeyType!
        if let _ = indexOfLastTextfieldCell, indexOfLastTextfieldCell! == indexPath.row {
            returnKeyType = .done
        } else {
            returnKeyType = .next
        }
        cell.textView.returnKeyType = returnKeyType
        
        //Setup the order of textviews to navigate
        if let previousTextView = lastTextViewConfigured {
            previousTextView.nextNavigableResponder = cell.textView
        } else {
            cell.textView.nextNavigableResponder = nil
        }
        
        lastTextViewConfigured = cell.textView
    }
    
    //Returns the field label text for fieldTypes that are used in the EditListingText cells
    fileprivate func fieldLabel(forTextFieldType textFieldType: EditListingConfiguration.FieldType) -> String {
        return delegate.getConfiguration().textDescription(forFieldType: textFieldType)
    }
    
    //Returns the placeholder text for fieldTypes that are used in the EditListingTextField cells
    fileprivate func keyboardType(forTextFieldFieldType textfieldFieldType: EditListingConfiguration.FieldType) -> UIKeyboardType {
        switch textfieldFieldType {
        case .price, .quantity:
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
            lastTextViewConfigured = nil
        }
        
        let fieldTypeForRow = fieldType(forIndexPath: indexPath)
        let identifier = cellIdentifer(forFieldType: fieldTypeForRow)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        if let textCell = cell as? EditListingTextCell {
            configure(editListingTextCell: textCell, withFieldType: fieldTypeForRow, andIndexPath: indexPath)
        } else if let photoCell = cell as? EditListingPhotoCell {
            configure(editListingPhotoCell: photoCell)
        } else if let categoryCell = cell as? EditListingCategoryCell {
            configure(editListingCategoryCell: categoryCell)
        } else if let actionsCell = cell as? EditListingActionsCell {
            configure(editListingActionsCell: actionsCell)
        }
        
        return cell
    }
}

extension EditListingTableHandler: UITableViewDelegate {
    
    //Used to get the exact height for each cell so that the table view isn't jerky with beginUpdates and endUpdates
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        heightForIndexPaths[indexPath] = cell.frame.size.height
    }
    
    //Used to get the exact height for each cell so that the table view isn't jerky with beginUpdates and endUpdates
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if let height = heightForIndexPaths[indexPath] {
            return height
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard fieldType(forIndexPath: indexPath) == .category else { return }
        delegate.didSelectCategoryCell()
    }
}

extension EditListingTableHandler: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return delegate.getTextHandler().textView(textView, shouldChangeCharactersIn: range, replacementString: text)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        return delegate.getTextHandler().textViewDidChange(textView)
    }
}
