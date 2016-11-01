//
//  EditProfoleViewController.swift
//  Mooch
//
//  Created by adam on 9/12/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

protocol EditProfileField {
    var fieldType: EditProfileConfiguration.FieldType! { get set }
}

protocol EditProfileViewControllerDelegate: class {
    
    func editProfileViewControllerDidFinishEditing(localUser: LocalUser, isNewProfile: Bool)
}

class EditProfileViewController: MoochModalViewController {
    
    enum State {
        case editing
        case uploading
    }
    
    // MARK: Public variables
    
    @IBOutlet var tableHandler: EditProfileTableHandler! {
        didSet { tableHandler.delegate = self }
    }
    
    @IBOutlet var textHandler: EditProfileTextHandler! {
        didSet { textHandler.delegate = self }
    }
    
    weak var delegate: EditProfileViewControllerDelegate!
    
    //The configuration used to setup the class
    var configuration: EditProfileConfiguration! {
        didSet {
            editedProfileInformation = EditedProfileInformation(fieldsShownToRequiredPairs: configuration.fieldsShownToRequiredPairs)
            tableHandler.indexOfLastTextfieldCell = configuration.indexOfLastFieldType(conformingToMapping: tableHandler.isTextField)
            
            //When creating a profile, default the community to the current one the guest is in
            if configuration.mode == .creating, let communityId = LocalUserManager.sharedInstance.userCommunityId {
                editedProfileInformation.communityId = communityId
            }
        }
    }
    
    //The user being edited
    var localUser: LocalUser?
    
    
    // MARK: Private variables
    
    static fileprivate let StoryboardName = "EditProfile"
    static fileprivate let Identifier = "EditProfileViewController"
    
    //Used to track what Profile information has been edited
    fileprivate var editedProfileInformation: EditedProfileInformation!
    
    //Used to differentiate view will/did disappear messages from when another view is being presented or pushed
    fileprivate var isDismissingSelf = false
    
    //Tracks which photo adding view the camera is taking a picture for
    fileprivate var currentPhotoAddingView: PhotoAddingView?
    
    fileprivate var state: State = .editing
    
    
    // MARK: Actions
    
    func onDoneAction() {
        guard state != .uploading else { return }
        
        if isDoneValidated() {
            uploadProfile()
        }
    }
    
    func onCancelAction() {
        guard state != .uploading else { return }
        dismissSelf(completion: nil)
    }
    
    
    // MARK: Public methods
    
    override func setup() {
        super.setup()
        
        registerForKeyboardNotifacations()
        setupNavigationBar()
        
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
    
    static func instantiateFromStoryboard() -> EditProfileViewController {
        let storyboard = UIStoryboard(name: EditProfileViewController.StoryboardName, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: EditProfileViewController.Identifier) as! EditProfileViewController
    }
    
    
    // MARK: Private methods
    
    fileprivate func setupNavigationBar() {
        title = configuration.title
        
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
        //Editing not yet supported
        if configuration.mode == .editing {
            return false
        } else if configuration.mode == .creating {
            if isValidProfileCreation() {
                return true
            } else {
                presentInvalidProfileCreationAlert()
                return false
            }
        }
        
        return false
    }
    
    private func uploadProfile() {
        //Only creation is supported right now
        guard isValidProfileCreation() else { return }
        guard let epi = editedProfileInformation, let deviceToken = PushNotificationsManager.sharedInstance.deviceToken else { return }
        guard let photo = epi.photo, let name = epi.name, let email = epi.email, let digitsOnlyPhone = epi.digitsOnlyPhone, let password = epi.password1, let communityId = epi.communityId else { return }
        
        //This allows the view controller to disable buttons/actions while loading
        state = .uploading
        
        showLoadingOverlayView(withInformationText: Strings.EditProfile.uploadingNewLoadingOverlay.rawValue, overEntireWindow: false, withUserInteractionEnabled: false, showingProgress: true, withHiddenAlertView: false)
        
        MoochAPI.POSTUser(
            communityId: communityId,
            photo: photo,
            name: name,
            email: email,
            phone: digitsOnlyPhone,
            password: password,
            address: epi.address,
            deviceToken: deviceToken,
            uploadProgressHandler: { [weak self] progress in
                guard let strongSelf = self else { return }
                strongSelf.loadingOverlayViewBeingShown?.update(withProgress: Float(progress.fractionCompleted))
            },
            completion: { [weak self] localUser, error in
                guard let strongSelf = self else { return }
                guard let localUser = localUser else {
                    strongSelf.hideLoadingOverlayView(animated: true)
                    strongSelf.presentSingleActionAlert(title: Strings.EditProfile.uploadingNewErrorAlertTitle.rawValue, message: Strings.EditProfile.uploadingNewErrorAlertMessage.rawValue, actionTitle: Strings.Alert.defaultSingleActionTitle.rawValue)
                    strongSelf.state = .editing
                    return
                }
                
                strongSelf.dismissSelf() {
                    strongSelf.delegate.editProfileViewControllerDidFinishEditing(localUser: localUser, isNewProfile: true)
                }
            }
        )
    }
    
    private func isValidProfileCreation() -> Bool {
        return editedProfileInformation.isAllRequiredInformationFilledAndValid
    }
    
    private func presentInvalidProfileCreationAlert() {
        let title = Strings.EditProfile.invalidCreationErrorAlertTitle.rawValue
        var message = ""
        let actionTitle = Strings.Alert.defaultSingleActionTitle.rawValue
        
        if !editedProfileInformation.isRequiredInformationFilled {
            guard let fieldToNotifyAbout = editedProfileInformation.firstUnfilledRequiredFieldType() else { return }
            message = "\(Strings.EditProfile.invalidCreationErrorAlertMessageUnfilledInfoFirstPart.rawValue)\(configuration.textDescription(forFieldType: fieldToNotifyAbout))\(Strings.EditProfile.invalidCreationErrorAlertMessageUnfilledInfoSecondPart.rawValue)"
        } else if !editedProfileInformation.isEmailValid {
            message = Strings.EditProfile.invalidCreationErrorAlertMessageEmail.rawValue
        } else if !editedProfileInformation.isPhoneValid {
            message = Strings.EditProfile.invalidCreationErrorAlertMessagePhone.rawValue
        } else if !editedProfileInformation.isPasswordValid {
            message = Strings.EditProfile.invalidCreationErrorAlertMessagePassword.rawValue
        } else if !editedProfileInformation.isPasswordMatchValid {
            message = Strings.EditProfile.invalidCreationErrorAlertMessagePasswordMatch.rawValue
        }
        
        presentSingleActionAlert(title: title, message: message, actionTitle: actionTitle)
    }
    
    fileprivate func presentCameraViewController(forPhotoAddingView photoAddingView: PhotoAddingView) {
        currentPhotoAddingView = photoAddingView
        let cameraViewController = CameraViewController()
        cameraViewController.delegate = self
        present(cameraViewController, animated: true, completion: nil)
    }
    
    fileprivate func pushCommunityPicker() {
        let vc = CommunityPickerViewController.instantiateFromStoryboard()
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    fileprivate func dismissSelf(completion: (() -> Void)?) {
        isDismissingSelf = true
        dismiss(animated: true, completion: completion)
    }
}

extension EditProfileViewController: EditProfileTableHandlerDelegate {
    
    func getConfiguration() -> EditProfileConfiguration {
        return configuration
    }
    
    func getTextHandler() -> EditProfileTextHandler {
        return textHandler
    }
    
    func getEditedProfileInformation() -> EditedProfileInformation {
        return editedProfileInformation
    }
    
    func didSelectCommunityCell() {
        pushCommunityPicker()
    }
}

extension EditProfileViewController: EditProfileTextHandlerDelegate {
    
    func updated(text: String, forFieldType fieldType: EditProfileConfiguration.FieldType) {
        let updatedText: String? = text == "" ? nil : text
        
        switch fieldType {
        case .name:
            editedProfileInformation.name = updatedText
            
        case .email:
            editedProfileInformation.email = updatedText
            
        case .phone:
            editedProfileInformation.phone = updatedText
            
        case .address:
            editedProfileInformation.address = updatedText
            
        case .password1:
            editedProfileInformation.password1 = updatedText
            
        case .password2:
            editedProfileInformation.password2 = updatedText
            
        default:
            return
        }
    }
}

extension EditProfileViewController: PhotoAddingViewDelegate {
    
    func photoAddingViewReceivedAddPhotoAction(_ photoAddingView: PhotoAddingView) {
        presentCameraViewController(forPhotoAddingView: photoAddingView)
    }
    
    func photoAddingViewReceivedDeletePhotoAction(_ photoAddingView: PhotoAddingView) {
        editedProfileInformation.photo = nil
    }
}

extension EditProfileViewController: EditListingActionsCellDelegate {
    
    func onDone() {
        onDoneAction()
    }
    
    func onCancel() {
        onCancelAction()
    }
}

extension EditProfileViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let photo = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            currentPhotoAddingView = nil
            return
        }
        
        currentPhotoAddingView?.photo = photo
        currentPhotoAddingView = nil
        
        editedProfileInformation.photo = photo
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        currentPhotoAddingView = nil
        dismiss(animated: true, completion: nil)
    }
}

//Required by UIImagePickerController delegate property
extension EditProfileViewController: UINavigationControllerDelegate {
    
}

extension EditProfileViewController: CommunityPickerViewControllerDelegate {
    
    func didPick(community: Community) {
        
        editedProfileInformation.communityId = community.id
        tableHandler.reloadData()
        navigationController?.popViewController(animated: true)
    }
}
