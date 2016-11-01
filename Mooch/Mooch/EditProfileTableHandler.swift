//
//  EditProfileTableHandler.swift
//  Mooch
//
//  Created by adam on 10/10/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

protocol EditProfileTableHandlerDelegate: class, EditProfilePhotoCellDelegate, EditProfileActionsCellDelegate {
    func getConfiguration() -> EditProfileConfiguration
    func getTextHandler() -> EditProfileTextHandler
    func getEditedProfileInformation() -> EditedProfileInformation
    func didSelectCommunityCell()
}

class EditProfileTableHandler: NSObject {
    
    // MARK: Public variables
    
    //Used to know which textfield cell should have a "done" return keyboard type instead of a "next"
    var indexOfLastTextfieldCell: Int?
    
    
    // MARK: Private variables
    
    //The spacing between cells is 14, so half that is 7
    //Used for knowing how much to offset due to keyboard so it doesn't go right under the cell
    private let HalfTheSpacingBetweenCells: CGFloat = 7.0
    
    //Used to track the setup of the navigable text fields between configurations
    fileprivate var lastTextViewConfigured: EditProfileTextField?
    
    //Used to restore the tableView insets after the keyboard disappears
    private var originalContentInsets = UIEdgeInsetsMake(64, 0, 0, 0)
    
    @IBOutlet weak fileprivate var tableView: UITableView! {
        didSet {
            //Must set these to get cells to use autolayout and self-size themselves in the table
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.estimatedRowHeight = EditProfileTextCell.EstimatedHeight
        }
    }
    
    weak var delegate: EditProfileTableHandlerDelegate!
    
    
    // MARK: Actions
    
    // MARK: Public methods
    
    func reloadData() {
        tableView.reloadData()
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
    
    //Returns true if a field type maps to a EditProfileTextFieldCell
    func isTextField(forFieldType fieldType: EditProfileConfiguration.FieldType) -> Bool {
        switch fieldType {
        case .photo:
            return false
        default:
            return true
        }
    }
    
    // MARK: Private methods
    
    //Returns the field type that a row is displaying
    fileprivate func fieldType(forIndexPath indexPath: IndexPath) -> EditProfileConfiguration.FieldType {
        return delegate!.getConfiguration().fields[indexPath.row]
    }
    
    //Returns the identifier string for the field type
    fileprivate func cellIdentifer(forFieldType fieldType: EditProfileConfiguration.FieldType) -> String {
        
        switch fieldType {
        case .photo:
            return EditProfilePhotoCell.Identifier
        case .community:
            return EditProfileCommunityCell.Identifier
        case .actions:
            return EditProfileActionsCell.Identifier
        default:
            return EditProfileTextCell.Identifier
        }
    }
    
    //Configures an EditProfilePhotoCell
    fileprivate func configure(editProfilePhotoCell cell: EditProfilePhotoCell) {
        cell.delegate = delegate
    }
    
    //Configures an EditProfileActionsCell
    fileprivate func configure(editProfileActionsCell cell: EditProfileActionsCell) {
        cell.delegate = delegate
    }
    
    //Configures an EditListingCategoryCell
    fileprivate func configure(editProfileCommunityCell cell: EditProfileCommunityCell) {
        var communityNameText = Strings.EditProfile.unselectedCommunity.rawValue
        if let selectedCategoryId = delegate.getEditedProfileInformation().communityId {
            if let selectedCommunity = CommunityManager.sharedInstance.getCommunity(withId: selectedCategoryId) {
                communityNameText = selectedCommunity.name
            } else {
                communityNameText = Strings.SharedErrors.invalidCategory.rawValue
            }
        }
        cell.selectedOptionLabel.text = communityNameText
    }
    
    //Configures an EditProfileTextCell based on the field type
    fileprivate func configure(editProfileTextCell cell: EditProfileTextCell, withFieldType fieldType: EditProfileConfiguration.FieldType, andIndexPath indexPath: IndexPath) {
        
        cell.fieldLabel.text = "\(fieldLabel(forTextFieldType: fieldType)):"
        cell.textField.keyboardType = keyboardType(forTextFieldFieldType: fieldType)
        cell.textField.fieldType = fieldType
        cell.textField.isSecureTextEntry = isSecureEntry(forTextFieldFieldType: fieldType)
        cell.textField.delegate = self
        
        //Make the last cell have done key instead of next
        var returnKeyType: UIReturnKeyType!
        if let _ = indexOfLastTextfieldCell, indexOfLastTextfieldCell! == indexPath.row {
            returnKeyType = .done
        } else {
            returnKeyType = .next
        }
        cell.textField.returnKeyType = returnKeyType
        
        //Setup the order to navigate
        if let previousTextField = lastTextViewConfigured {
            previousTextField.nextNavigableResponder = cell.textField
        } else {
            cell.textField.nextNavigableResponder = nil
        }
        
        lastTextViewConfigured = cell.textField
        
        
        //
        //Make the password fields "appear" to be the same cell ;)
        //
        if fieldType == .password1 {
            cell.bottomSeperator.isHidden = true
        } else if fieldType == .password2 {
            cell.fieldLabel.text = "Confirm:"
            cell.topSpacingConstraint.constant = 2
        }
    }
    
    //Returns the field label text for fieldTypes that are used in the EditProfileText cells
    fileprivate func fieldLabel(forTextFieldType textFieldType: EditProfileConfiguration.FieldType) -> String {
        return delegate.getConfiguration().textDescription(forFieldType: textFieldType)
    }
    
    //Returns the placeholder text for fieldTypes that are used in the EditProfileTextField cells
    fileprivate func keyboardType(forTextFieldFieldType textfieldFieldType: EditProfileConfiguration.FieldType) -> UIKeyboardType {
        switch textfieldFieldType {
        case .email:
            return .emailAddress
        case .phone:
            return .numbersAndPunctuation
        default:
            return .default
        }
    }
    
    //Returns the placeholder text for fieldTypes that are used in the EditProfileTextField cells
    fileprivate func isSecureEntry(forTextFieldFieldType textfieldFieldType: EditProfileConfiguration.FieldType) -> Bool {
        switch textfieldFieldType {
        case .password1, .password2:
            return true
        default:
            return false
        }
    }
    
    fileprivate func numberOfRows() -> Int {
        return delegate.getConfiguration().fields.count
    }
}

extension EditProfileTableHandler: UITableViewDataSource {
    
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
        if let textCell = cell as? EditProfileTextCell {
            configure(editProfileTextCell: textCell, withFieldType: fieldTypeForRow, andIndexPath: indexPath)
        } else if let photoCell = cell as? EditProfilePhotoCell {
            configure(editProfilePhotoCell: photoCell)
        } else if let communityCell = cell as? EditProfileCommunityCell {
            configure(editProfileCommunityCell: communityCell)
        } else if let actionsCell = cell as? EditProfileActionsCell {
            configure(editProfileActionsCell: actionsCell)
        }
        
        return cell
    }
}

extension EditProfileTableHandler: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        if let textCell = cell as? EditProfileTextCell {
            textCell.textField.becomeFirstResponder()
        } else if cell is EditProfileCommunityCell {
            delegate.didSelectCommunityCell()
        }
    }
}

extension EditProfileTableHandler: UITextFieldDelegate {
    
    func  textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return delegate.getTextHandler().textField(textField, shouldChangeCharactersIn: range, replacementString: string)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return delegate.getTextHandler().textFieldShouldReturn(textField)
    }
}
