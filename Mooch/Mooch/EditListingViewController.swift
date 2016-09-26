//
//  EditListingViewController.swift
//  Mooch
//
//  Created by adam on 9/16/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

protocol EditListingField {
    var fieldType: EditListingViewController.Configuration.FieldType! { get set }
}

protocol EditListingViewControllerDelegate: class {
    
    //Allows the delegate to handle dismissing this view controller at the appropriate time
    func editListingViewControllerDidFinishEditing(withListingInformation editedListingInformation: EditListingViewController.EditedListingInformation)
}

class EditListingViewController: MoochModalViewController {
    
    //A configuration to setup the class with
    struct Configuration {
        
        //A mapping from a FieldType to a Bool that returns true if it conforms
        typealias FieldTypeConformanceMapping = (FieldType) -> Bool
        
        var mode: Mode
        
        var title: String
        var leftBarButtons: [BarButtonType]?
        var rightBarButtons: [BarButtonType]?
        
        //The fields that should be shown
        var fields: [FieldType]
        
        //The bar buttons that can be added
        enum BarButtonType {
            case cancel
            case done
        }
        
        enum Mode {
            case creating
            case editing
        }
        
        enum FieldType {
            case photo
            case title
            case description
            case tag
            case price
            case quantity
        }
        
        func indexOfLastFieldType(conformingToMapping mapping: FieldTypeConformanceMapping) -> Int? {
            let mappedFieldTypes = fields.reversed().map{mapping($0)}
            guard let reversedIndex = mappedFieldTypes.index(of: true) else { return nil }
            return (fields.count - 1) - reversedIndex
        }
        
        func textDescription(forFieldType fieldType: FieldType) -> String {
            switch fieldType {
            case .photo:
                return "Photo"
            case .title:
                return "Title"
            case .description:
                return "Description"
            case .tag:
                return "Tag"
            case .price:
                return "Price"
            case .quantity:
                return "Quantity"
            }
        }
    }
    
    //Struct to track the edited listing information
    struct EditedListingInformation {
        var title: String?
        var description: String?
        var tag: ListingTag?
        var price: Float?
        var quantity: Int?
    }
    
    // MARK: Public variables
    
    static let DefaultCreatingConfiguration = Configuration(mode: .creating, title: "Create Listing", leftBarButtons: [.cancel], rightBarButtons: [.done], fields: [.photo, .title, .description, .tag, .price, .quantity])
    static let DefaultEditingConfiguration = Configuration(mode: .creating, title: "Edit Listing", leftBarButtons: [.cancel], rightBarButtons: [.done], fields: [.photo, .title, .description, .tag, .price, .quantity])
    
    @IBOutlet var tableHandler: EditListingTableHandler! {
        didSet {
            tableHandler.delegate = self
        }
    }
    
    @IBOutlet var textfieldHandler: EditListingTextfieldHandler! {
        didSet {
            textfieldHandler.delegate = self
        }
    }
    
    weak var delegate: EditListingViewControllerDelegate!
    
    //The configuration used to setup the class
    var configuration: Configuration! {
        didSet {
            tableHandler.indexOfLastTextfieldCell = configuration.indexOfLastFieldType(conformingToMapping: tableHandler.isTextField)
        }
    }
    
    //The listing being edited
    var listing: Listing?
    
    
    // MARK: Private variables
    
    static fileprivate let StoryboardName = "EditListing"
    static fileprivate let Identifier = "EditListingViewController"
    
    fileprivate var doneButton: UIBarButtonItem!
    fileprivate var cancelButton: UIBarButtonItem!
    
    fileprivate var editedListingInformation = EditedListingInformation(title: nil, description: nil, tag: nil, price: nil, quantity: nil)
    
    
    // MARK: Actions
    
    func onDoneAction() {
        if isDoneValidated() {
            resignFirstResponder()
            dismiss(animated: true) {
                self.delegate.editListingViewControllerDidFinishEditing(withListingInformation: self.editedListingInformation)
            }
        }
    }
    
    func onCancelAction() {
        resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Public methods
    
    override func setup() {
        super.setup()
        
        registerForKeyboardNotifacations()
        setupNavigationBar()
        
        if configuration.mode == .creating {
            //Default the quantity to 1 for validation just in case the user doesn't change the quantity when creating a new listing
            editedListingInformation.quantity = 1
        }
        
        updateUI()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        view.endEditing(true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        unregisterForKeyboardNotifacations()
    }
    
    override func updateUI() {
        super.updateUI()
        
    }
    
    func onKeyboardDidShow(withNotification notification: Notification) {
        guard let keyboardRect = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue, let animationDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue else { return }
        tableHandler.onKeyboardDidShow(withRect: keyboardRect, andAnimationDuration: animationDuration)
    }
    
    func onKeyboardWillHide(withNotification notification: Notification) {
        guard let animationDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue else { return }
        tableHandler.onKeyboardWillHide(withAnimationDuration: animationDuration)
    }
    
    static func instantiateFromStoryboard() -> EditListingViewController {
        let storyboard = UIStoryboard(name: EditListingViewController.StoryboardName, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: EditListingViewController.Identifier) as! EditListingViewController
    }
    
    
    // MARK: Private methods
    
    fileprivate func setupNavigationBar() {
        doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(onDoneAction))
        cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(onCancelAction))
        
        title = configuration.title
        
        if let leftButtons = configuration.leftBarButtons {
            navigationItem.leftBarButtonItems = barButtons(fromTypeList: leftButtons)
        } else {
            navigationItem.leftBarButtonItems = nil
        }
        
        if let rightButtons = configuration.rightBarButtons {
            navigationItem.rightBarButtonItems = barButtons(fromTypeList: rightButtons)
        } else {
            navigationItem.rightBarButtonItems = nil
        }
    }
    
    fileprivate func barButtons(fromTypeList typeList: [Configuration.BarButtonType]) -> [UIBarButtonItem] {
        return typeList.map({barButton(forType: $0)})
    }
    
    fileprivate func barButton(forType type: Configuration.BarButtonType) -> UIBarButtonItem {
        switch type {
        case .cancel:
            return cancelButton
        case .done:
            return doneButton
        }
    }
    
    fileprivate func registerForKeyboardNotifacations() {
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardDidShow(withNotification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillHide(withNotification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    fileprivate func unregisterForKeyboardNotifacations() {
        NotificationCenter.default.removeObserver(self)
    }
    
    //Returns true if the Done action is validated, else handles notifying the user
    private func isDoneValidated() -> Bool {
        //Editing not yet supported
        if configuration.mode == .editing {
            return false
        } else if configuration.mode == .creating {
            if isValidListingCreation() {
                return true
            } else {
                presentInvalidListingCreationAlert()
                return false
            }
        }
        
        return false
    }
    
    
    private func isValidListingCreation() -> Bool {
        let eli = editedListingInformation
        return eli.title != nil && eli.description != nil && eli.tag != nil && eli.price != nil && eli.quantity != nil
    }
    
    private func presentInvalidListingCreationAlert() {
        var invalidField: Configuration.FieldType?
        
        let eli = editedListingInformation
        if eli.title == nil {
            invalidField = .title
        } else if eli.description == nil {
            invalidField = .description
        } else if eli.tag == nil {
            invalidField = .tag
        } else if eli.price == nil {
            invalidField = .price
        } else if eli.quantity == nil {
            invalidField = .quantity
        }
        
        guard let fieldToNotifyAbout = invalidField else { return }
        presentSingleActionAlert(title: "Problem creating listing", message: "Please complete filling out the information for the \(configuration.textDescription(forFieldType: fieldToNotifyAbout)) field", actionTitle: "Aye aye captain!")
    }
}

extension EditListingViewController: EditListingTableHandlerDelegate {
    
    func getConfiguration() -> EditListingViewController.Configuration {
        return configuration
    }
}


extension EditListingViewController: EditListingTextfieldHandlerDelegate {
    
    func updated(text: String, forFieldType fieldType: EditListingViewController.Configuration.FieldType) {
        switch fieldType {
        case .title:
            editedListingInformation.title = text
        case .description:
            editedListingInformation.description = text
        case .tag:
            editedListingInformation.tag = ListingTag(id: 0, name: text, count: 1)
        case .price:
            editedListingInformation.price = Float(text)
        default:
            return
        }
    }
}
