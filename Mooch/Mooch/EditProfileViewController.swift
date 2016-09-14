//
//  EditProfoleViewController.swift
//  Mooch
//
//  Created by adam on 9/12/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

protocol EditProfileViewControllerDelegate: class {
    
    //Allows the delegate to handle dismissing this view controller at the appropriate time
    func editProfileViewControllerDidFinishEditing(withUser editedUser: User)
}

class EditProfileViewController: MoochModalViewController {
    
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
    
    static let DefaultCreatingConfiguration = Configuration(mode: .creating, title: "Create Account", leftBarButtons: [.cancel], rightBarButtons: [.done])
    static let DefaultEditingConfiguration = Configuration(mode: .creating, title: "Edit Profile", leftBarButtons: [.cancel], rightBarButtons: [.done])
    
    weak var delegate: EditProfileViewControllerDelegate!
    
    //The configuration used to setup the class
    var configuration: Configuration!
    
    //The user being edited
    var user: User?
    
    
    // MARK: Private variables
    
    static fileprivate let StoryboardName = "EditProfile"
    static fileprivate let Identifier = "EditProfileViewController"
    
    fileprivate var doneButton: UIBarButtonItem!
    fileprivate var cancelButton: UIBarButtonItem!
    
    
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
}
