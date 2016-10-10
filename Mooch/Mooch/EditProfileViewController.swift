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
    
    //Allows the delegate to handle dismissing this view controller at the appropriate time
    func editProfileViewControllerDidFinishEditing(withUser editedUser: User)
}

class EditProfileViewController: MoochModalViewController {
    
    enum State {
        case editing
        case uploading
    }
    
    //A configuration to setup the class with
    struct Configuration {
        
        var mode: Mode
        
        var title: String
        var leftBarButtons: [BarButtonType]?
        var rightBarButtons: [BarButtonType]?
        
        //The bar buttons that can be added
        enum BarButtonType {
            case cancel
            case done
        }
        
        enum Mode {
            case creating
            case editing
        }
    }
    
    // MARK: Public variables
    
    static let DefaultCreatingConfiguration = EditProfileConfiguration(mode: .creating, title: "Create Profile", leftBarButtons: [.cancel], rightBarButtons: [.done], fields: [.photo, .name, .email, .phone, .address, .password1, .password2])
    static let DefaultEditingConfiguration = EditProfileConfiguration(mode: .creating, title: "Edit Profile", leftBarButtons: [.cancel], rightBarButtons: [.done], fields: [.photo, .name, .email, .phone, .address, .password1, .password2])
    
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
            tableHandler.indexOfLastTextfieldCell = configuration.indexOfLastFieldType(conformingToMapping: tableHandler.isTextField)
        }
    }
    
    //The user being edited
    var user: User?
    
    
    // MARK: Private variables
    
    static fileprivate let StoryboardName = "EditProfile"
    static fileprivate let Identifier = "EditProfileViewController"
    
    fileprivate var doneButton: UIBarButtonItem!
    fileprivate var cancelButton: UIBarButtonItem!
    
    //Used to track what Profile information has been edited
    fileprivate var editedProfileInformation = EditedProfileInformation(photo: nil, name: nil, email: nil, phone: nil, address: nil, password1: nil, password2: nil)
    
    //Used to differentiate view will/did disappear messages from when another view is being presented or pushed
    fileprivate var isDismissingSelf = false
    
    //Tracks which photo adding view the camera is taking a picture for
    fileprivate var currentPhotoAddingView: PhotoAddingView?
    
    fileprivate var state: State = .editing
    
    
    // MARK: Actions
    
    func onDoneAction() {
        let dummyUser = User.createDummy(fromNumber: 62)
        dismiss(animated: true) {
            self.delegate.editProfileViewControllerDidFinishEditing(withUser: dummyUser)
        }
    }
    
    func onCancelAction() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Public methods
    
    override func setup() {
        super.setup()
        
        setupNavigationBar()
        
        updateUI()
    }
    
    override func updateUI() {
        super.updateUI()
        
    }
    
    static func instantiateFromStoryboard() -> EditProfileViewController {
        let storyboard = UIStoryboard(name: EditProfileViewController.StoryboardName, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: EditProfileViewController.Identifier) as! EditProfileViewController
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
    
    fileprivate func barButtons(fromTypeList typeList: [EditProfileConfiguration.BarButtonType]) -> [UIBarButtonItem] {
        return typeList.map({barButton(forType: $0)})
    }
    
    fileprivate func barButton(forType type: EditProfileConfiguration.BarButtonType) -> UIBarButtonItem {
        switch type {
        case .cancel:
            return cancelButton
        case .done:
            return doneButton
        }
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
}

extension EditProfileViewController: EditProfileTextHandlerDelegate {
    
    func updated(text: String, forFieldType fieldType: EditProfileConfiguration.FieldType) {
//        switch fieldType {
//        case .title:
//            editedListingInformation.title = text
//        case .description:
//            editedListingInformation.description = text
//        case .price:
//            editedListingInformation.price = Float(text)
//        default:
//            return
//        }
    }
}


extension EditProfileViewController: PhotoAddingViewDelegate {
    
    func photoAddingViewReceivedAddPhotoAction(_ photoAddingView: PhotoAddingView) {
        //presentCameraViewController(forPhotoAddingView: photoAddingView)
    }
    
    func photoAddingViewReceivedDeletePhotoAction(_ photoAddingView: PhotoAddingView) {
        //editedListingInformation.photo = nil
    }
}
