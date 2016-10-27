//
//  EditListingViewController.swift
//  Mooch
//
//  Created by adam on 9/16/16.
//  Copyright © 2016 cse498. All rights reserved.
//

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
    
    static let DefaultCreatingConfiguration = EditListingConfiguration(mode: .creating, title: Strings.EditListing.defaultCreatingTitle.rawValue, leftBarButtons: [.cancel], rightBarButtons: [.done], fields: [.photo, .title, .description, .price, .quantity, .category])
    static let DefaultEditingConfiguration = EditListingConfiguration(mode: .creating, title: Strings.EditListing.defaultEditingTitle.rawValue, leftBarButtons: [.cancel], rightBarButtons: [.done], fields: [.photo, .title, .description, .price, .quantity, .category])
    
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
    
    //The listing being edited
    var listing: Listing?
    
    
    // MARK: Private variables
    
    static fileprivate let StoryboardName = "EditListing"
    static fileprivate let Identifier = "EditListingViewController"
    
    fileprivate var doneButton: UIBarButtonItem!
    fileprivate var cancelButton: UIBarButtonItem!
    
    //Used to track what Listing information has been edited
    fileprivate var editedListingInformation = EditedListingInformation(photo: nil, title: nil, description: nil, categoryId: nil, price: nil, quantity: nil)
    
    //Used to differentiate view will/did disappear messages from when another view is being presented or pushed
    fileprivate var isDismissingSelf = false
    
    //Tracks which photo adding view the camera is taking a picture for
    fileprivate var currentPhotoAddingView: PhotoAddingView?
    
    fileprivate var state: State = .editing
    
    
    // MARK: Actions
    
    func onDoneAction() {
        guard state != .uploading else { return }
        
        if isDoneValidated() {
            uploadNewListing()
        }
    }
    
    func onCancelAction() {
        guard state != .uploading else { return }
        notifyDelegateDidCancelAndDismissSelf()
    }
    
    // MARK: Public methods
    
    //Used when instantiated to give a photo to show when creating a listing
    func setPhoto(photo: UIImage) {
        editedListingInformation.photo = photo
    }
    
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
        doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(onDoneAction))
        cancelButton = UIBarButtonItem(title: Strings.EditListing.cancelButtonTitle.rawValue, style: UIBarButtonItemStyle.plain, target: self, action: #selector(onCancelAction))
        
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
    
    fileprivate func barButtons(fromTypeList typeList: [EditListingConfiguration.BarButtonType]) -> [UIBarButtonItem] {
        return typeList.map({barButton(forType: $0)})
    }
    
    fileprivate func barButton(forType type: EditListingConfiguration.BarButtonType) -> UIBarButtonItem {
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
    
    private func uploadNewListing() {
        guard isValidListingCreation() else { return }
        guard let localUser = LocalUserManager.sharedInstance.localUser?.user else { return }
        let eli = editedListingInformation
        guard let photo = eli.photo, let title = eli.title, let price = eli.price, let quantity = eli.quantity, let categoryId = eli.categoryId else { return }
        
        //This allows the view controller to disable buttons/actions while loading
        state = .uploading
        
        showLoadingOverlayView(withInformationText: Strings.EditListing.uploadingNewLoadingOverlay.rawValue, overEntireWindow: false, withUserInteractionEnabled: false, showingProgress: true, withHiddenAlertView: false)
        
        MoochAPI.POSTListing(
            userId: localUser.id,
            photo: photo,
            title: title,
            description: eli.description,
            price: price,
            isFree: false,
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
                
                let localListing = Listing(id: -1, photo: photo, title: title, description: eli.description, price: price, isFree: false, quantity: quantity, categoryId: categoryId, isAvailable: true, createdAt: Date(), modifiedAt: nil, owner: localUser, pictureURL: "", thumbnailPictureURL: "", communityId: localUser.communityId, exchanges: [])
                strongSelf.notifyDelegateDidFinishEditingAndDismissSelf(with: localListing, isNew: true)
            }
        )
    }
    
    private func isValidListingCreation() -> Bool {
        return editedListingInformation.isAllInformationFilled
    }
    
    private func presentInvalidListingCreationAlert() {
        guard let fieldToNotifyAbout = editedListingInformation.firstUnfilledRequiredFieldType() else { return }
        let title = Strings.EditListing.invalidCreationErrorAlertTitle.rawValue
        let message = "\(Strings.EditListing.invalidCreationErrorAlertMessageFirstPart.rawValue)\(configuration.textDescription(forFieldType: fieldToNotifyAbout))\(Strings.EditListing.invalidCreationErrorAlertMessageSecondPart.rawValue)"
        let actionTitle = Strings.Alert.defaultSingleActionTitle.rawValue
        presentSingleActionAlert(title: title, message: message, actionTitle: actionTitle)
    }
    
    fileprivate func presentCameraViewController(forPhotoAddingView photoAddingView: PhotoAddingView) {
        currentPhotoAddingView = photoAddingView
        let cameraViewController = CameraViewController()
        cameraViewController.delegate = self
        present(cameraViewController, animated: true, completion: nil)
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
                editedListingInformation.price = Float(updatedPrice)
            } else {
                editedListingInformation.price = nil
            }
            
        default:
            return
        }
    }
    
    func onTextViewDidChangeSize(withHeightDifference heightDifferrence: CGFloat) {
        tableHandler.onTextDidChangeSize(withHeightDifference: heightDifferrence)
    }
}

extension EditListingViewController: EditListingQuantityCellDelegate {
    
    func quantityDidChange(toValue value: Int) {
        editedListingInformation.quantity = value
    }
}

extension EditListingViewController: PhotoAddingViewDelegate {
    
    func photoAddingViewReceivedAddPhotoAction(_ photoAddingView: PhotoAddingView) {
        presentCameraViewController(forPhotoAddingView: photoAddingView)
    }
    
    func photoAddingViewReceivedDeletePhotoAction(_ photoAddingView: PhotoAddingView) {
        editedListingInformation.photo = nil
    }
}

extension EditListingViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let photo = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            currentPhotoAddingView = nil
            return
        }
        
        currentPhotoAddingView?.photo = photo
        currentPhotoAddingView = nil
        
        editedListingInformation.photo = photo
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        currentPhotoAddingView = nil
        dismiss(animated: true, completion: nil)
    }
}

//Required by UIImagePickerController delegate property
extension EditListingViewController: UINavigationControllerDelegate {
    
}

extension EditListingViewController: ListingCategoryPickerViewControllerDelegate {
    
    func didPick(listingCategory: ListingCategory) {
        editedListingInformation.categoryId = listingCategory.id
        tableHandler.reloadData()
        
        guard let navC = navigationController else { return }
        navC.popViewController(animated: true)
    }
}
