//
//  EditListingViewController.swift
//  Mooch
//
//  Created by adam on 9/16/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import Alamofire
import UIKit

protocol EditListingField {
    var fieldType: EditListingConfiguration.FieldType! { get set }
}

protocol EditListingViewControllerDelegate: class {
    
    //Allows the delegate to handle dismissing this view controller at the appropriate time
    func editListingViewControllerDidFinishEditing(with: Listing, isNew: Bool)
    
    //Allows the delegate to handle dismissing this view controller
    func editListingViewControllerDidCancel()
}

class EditListingViewController: MoochModalViewController {
    
    enum State {
        case editing
        case uploading
    }
    
    // MARK: Public variables
    
    @IBOutlet var tableHandler: EditListingTableHandler! {
        didSet { tableHandler.delegate = self }
    }
    
    @IBOutlet var textHandler: EditListingTextHandler! {
        didSet { textHandler.delegate = self }
    }
    
    weak var delegate: EditListingViewControllerDelegate!
    
    //The configuration used to setup the class
    var configuration: EditListingConfiguration! {
        didSet {
            tableHandler.indexOfLastTextfieldCell = configuration.indexOfLastFieldType(conformingToMapping: tableHandler.isTextField)
        }
    }
    
    
    // MARK: Private variables
    
    static fileprivate let StoryboardName = "EditListing"
    static fileprivate let Identifier = "EditListingViewController"
    
    fileprivate var doneButton: UIBarButtonItem!
    fileprivate var cancelButton: UIBarButtonItem!
    
    //The listing being edited
    fileprivate var listing: Listing?
    
    //Used to track what Listing information has been edited
    fileprivate var editedListingInformation = EditedListingInformation(photo: nil, title: nil, price: nil, quantity: nil, description: nil, categoryId: nil)
    
    //Used to differentiate view will/did disappear messages from when another view is being presented or pushed
    fileprivate var isDismissingSelf = false
    
    fileprivate var state: State = .editing
    
    
    // MARK: Actions
    
    func onDoneAction() {
        guard state != .uploading else { return }
        
        //isDoneValidated handles notifying user of form errors, too
        if isDoneValidated() {
            uploadListing()
        }
    }
    
    func onCancelAction() {
        guard state != .uploading else { return }
        notifyDelegateDidCancelAndDismissSelf()
    }
    
    
    // MARK: Public methods
    
    //Used when instantiated to intialize the view controller with the listing being edited
    func setListing(_ listing: Listing, withPhoto photo: UIImage) {
        guard configuration != nil && configuration.mode == .editing else { return }
        
        self.listing = listing
        
        editedListingInformation.photo = photo
        editedListingInformation.title = listing.title
        editedListingInformation.price = listing.price
        editedListingInformation.quantity = listing.quantity
        editedListingInformation.description = listing.description
        editedListingInformation.categoryId = listing.categoryId
    }
    
    //Used when instantiated to give a photo to show when creating a listing
    func setPhoto(photo: UIImage) {
        guard configuration != nil && configuration.mode == .creating else { return }
        
        editedListingInformation.photo = photo
    }
    
    override func setup() {
        super.setup()
        
        registerForKeyboardNotifacations()
        
        setupNavigationBar()
        
        if configuration.mode == .creating {
            //Default the quantity to 1 for validation just in case the user doesn't change the quantity when creating a new listing
            editedListingInformation.quantity = 1
            
            //Default the price to 0.00 for validation just in case the user doesn't change the price when creating a new listing
            editedListingInformation.price = 0.00
        }
        
        updateUI()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isDismissingSelf {
            view.endEditing(true)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if isDismissingSelf {
            unregisterForKeyboardNotifacations()
        }
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
        title = configuration.title
        
        //When creating, this is the child of the UINavigationController of the UIImagePicker
        //We need to disable the back button
        if configuration.mode == .creating {
            navigationItem.hidesBackButton = true
        }
        
        //Remove the text from the nav bar back button so that is doesn't show in view controllers pushed from this view controller
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
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
        guard isEditedListingInformationValid() else {
            presentInvalidEditedListingAlert()
            return false
        }
        
        switch configuration.mode {
            
        case .creating:
            return true
            
        case .editing:
            guard let listing = listing else { return false }
            if editedListingInformation.isEditedInformationChanged(from: listing) {
                return true
            } else {
                presentNoInformationChangedAlert()
                return false
            }
        }
    }
    
    private func uploadListing() {
        guard isEditedListingInformationValid() else { return }
        
        guard let localUser = LocalUserManager.sharedInstance.localUser?.user else { return }
        
        let eli = editedListingInformation
        guard let photo = eli.photo, let title = eli.title, let price = eli.price, let quantity = eli.quantity, let categoryId = eli.categoryId else { return }
        
        let isNewListing = configuration.mode == .creating
        var listingId: Int?
        if !isNewListing {
            guard let listing = listing else { return }
            listingId = listing.id
        }
        
        //Make it so the keyboard doesn't show while uploading
        view.endEditing(true)
        
        //This allows the view controller to disable buttons/actions while loading
        state = .uploading
        
        showLoadingOverlayView(withInformationText: Strings.EditListing.uploadingNewLoadingOverlay.rawValue, overEntireWindow: false, withUserInteractionEnabled: false, showingProgress: true, withHiddenAlertView: false)
        
        let isFree = price <= 0.09
        uploadListingInformationToAPI(
            isNewListing: isNewListing,
            listingId: listingId,
            userId: localUser.id,
            photo: photo,
            title: title,
            description: eli.description,
            price: price,
            isFree: isFree,
            quantity: quantity,
            categoryId: categoryId,
            uploadProgressHandler: { [weak self] progress in
                guard let strongSelf = self else { return }
                strongSelf.loadingOverlayViewBeingShown?.update(withProgress: Float(progress.fractionCompleted))
            },
            completion: { [weak self] success, json, error in
                guard let strongSelf = self else { return }
                guard success else {
                    strongSelf.hideLoadingOverlayView(animated: true)
                    strongSelf.presentSingleActionAlert(title: Strings.EditListing.uploadingNewErrorAlertTitle.rawValue, message: Strings.EditListing.uploadingNewErrorAlertMessage.rawValue, actionTitle: Strings.Alert.defaultSingleActionTitle.rawValue)
                    strongSelf.state = .editing
                    return
                }
                
                var listing: Listing!
                if let json = json {
                    do {
                        listing = try Listing(json: json)
                    } catch let error {
                        print(error)
                    }
                }
                
                strongSelf.notifyDelegateDidFinishEditingAndDismissSelf(with: listing, isNew: isNewListing)
            }
        )
    }
    
    private func uploadListingInformationToAPI(isNewListing: Bool, listingId: Int?, userId: Int, photo: UIImage, title: String, description: String?, price: Float, isFree: Bool, quantity: Int, categoryId: Int, uploadProgressHandler: @escaping Request.ProgressHandler, completion: @escaping (Bool, JSON?, Error?) -> Void) {
        
        if isNewListing {
            MoochAPI.POSTListing(
                userId: userId,
                photo: photo,
                title: title,
                description: description,
                price: price,
                isFree: isFree,
                quantity: quantity,
                categoryId: categoryId,
                uploadProgressHandler: uploadProgressHandler,
                completion: completion
            )
        } else {
            guard let listingId = listingId else { return }
            
            MoochAPI.PUTListing(
                listingId: listingId,
                userId: userId,
                title: title,
                description: description,
                price: price,
                isFree: isFree,
                quantity: quantity,
                categoryId: categoryId,
                uploadProgressHandler: uploadProgressHandler,
                completion: completion
            )
        }
    }

    private func isEditedListingInformationValid() -> Bool {
        return editedListingInformation.isAllInformationFilled && editedListingInformation.isPriceValid
    }
    
    private func presentInvalidEditedListingAlert() {
        if !editedListingInformation.isAllInformationFilled {
            guard let fieldToNotifyAbout = editedListingInformation.firstUnfilledRequiredFieldType() else { return }
            let title = configuration.mode == .creating ?  Strings.EditListing.invalidCreationErrorAlertTitle.rawValue : Strings.EditListing.invalidEditErrorAlertTitle.rawValue
            let message = "\(Strings.EditListing.invalidCreationErrorAlertMessageFirstPart.rawValue)\(configuration.textDescription(forFieldType: fieldToNotifyAbout))\(Strings.EditListing.invalidCreationErrorAlertMessageSecondPart.rawValue)"
            let actionTitle = Strings.Alert.defaultSingleActionTitle.rawValue
            presentSingleActionAlert(title: title, message: message, actionTitle: actionTitle)
        } else if !editedListingInformation.isPriceValid {
            let title = Strings.EditListing.invalidCreationErrorAlertTitle.rawValue
            let message = Strings.EditListing.invalidCreationErrorInvalidPriceAlertMessage.rawValue
            let actionTitle = Strings.Alert.defaultSingleActionTitle.rawValue
            presentSingleActionAlert(title: title, message: message, actionTitle: actionTitle)
        }
    }
    
    private func presentNoInformationChangedAlert() {
        guard configuration.mode == .editing else { return }
        
        let title = Strings.EditListing.invalidEditErrorAlertTitle.rawValue
        let message = Strings.EditListing.noInformationChangedAlertMessage.rawValue
        let actionTitle = Strings.Alert.defaultSingleActionTitle.rawValue
        presentSingleActionAlert(title: title, message: message, actionTitle: actionTitle)
    }
    
    fileprivate func pushListingCategoryPickerViewController(withSelectedListingCategory selectedListingCategory: ListingCategory?) {
        guard let navC = navigationController else { return }
        
        let listingCategoryPickerViewController = ListingCategoryPickerViewController.instantiateFromStoryboard()
        listingCategoryPickerViewController.delegate = self
        listingCategoryPickerViewController.selectedListingCategory = selectedListingCategory
        navC.pushViewController(listingCategoryPickerViewController, animated: true)
    }
    
    //Use this method after login or account creation to notify the delegate, which will then dismiss this view controller
    fileprivate func notifyDelegateDidFinishEditingAndDismissSelf(with listing: Listing, isNew: Bool) {
        //Need this so the keyboard listeners are unregistered
        isDismissingSelf = true
        
        delegate.editListingViewControllerDidFinishEditing(with: listing, isNew: isNew)
    }
    
    //Use this method after cancelling to notify the delegate, which will then dismiss this view controller
    fileprivate func notifyDelegateDidCancelAndDismissSelf() {
        //Need this so the keyboard listeners are unregistered
        isDismissingSelf = true
        
        delegate.editListingViewControllerDidCancel()
    }
}

extension EditListingViewController: EditListingTableHandlerDelegate {
    
    func getConfiguration() -> EditListingConfiguration {
        return configuration
    }
    
    func getTextHandler() -> EditListingTextHandler {
        return textHandler
    }
    
    func getEditedListingInformation() -> EditedListingInformation {
        return editedListingInformation
    }
    
    func didSelectCategoryCell() {
        var currentlySelectedCategory: ListingCategory?
        if let currentlySelectedCategoryId = editedListingInformation.categoryId {
            currentlySelectedCategory = ListingCategoryManager.sharedInstance.getListingCategory(withId: currentlySelectedCategoryId)
        }
        
        pushListingCategoryPickerViewController(withSelectedListingCategory: currentlySelectedCategory)
    }
}

extension EditListingViewController: EditListingTextHandlerDelegate {
    
    func updated(text: String, forFieldType fieldType: EditListingConfiguration.FieldType) {
        let updatedText: String? = text == "" ? nil : text
        
        switch fieldType {
        case .title:
            editedListingInformation.title = updatedText
            
        case .description:
            editedListingInformation.description = updatedText
            
        case .price:
            if let updatedPrice = updatedText {
                //Remove the leading dollar sign
                let priceString = String(updatedPrice.characters.dropFirst())
                if priceString.characters.count > 0 {
                    editedListingInformation.price = Float(priceString)
                } else {
                    editedListingInformation.price = nil
                }
            } else {
                editedListingInformation.price = nil
            }
            
        case .quantity:
            if let updatedQuantity = updatedText {
                editedListingInformation.quantity = Int(updatedQuantity)
            } else {
                editedListingInformation.quantity = nil
            }
            
        default:
            return
        }
    }
    
    func onTextViewDidChangeSize(withHeightDifference heightDifferrence: CGFloat) {
        tableHandler.onTextDidChangeSize(withHeightDifference: heightDifferrence)
    }
}

extension EditListingViewController: ListingCategoryPickerViewControllerDelegate {
    
    func didPick(listingCategory: ListingCategory) {
        editedListingInformation.categoryId = listingCategory.id
        tableHandler.reloadData()
        
        guard let navC = navigationController else { return }
        navC.popViewController(animated: true)
    }
}

extension EditListingViewController: EditListingActionsCellDelegate {
    
    func onDone() {
        onDoneAction()
    }
    
    func onCancel() {
        onCancelAction()
    }
}
