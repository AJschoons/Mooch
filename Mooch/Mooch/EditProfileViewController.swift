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
            case Cancel
            case Done
        }
        
        enum Mode {
            case Creating
            case Editing
        }
    }
    
    // MARK: Public variables
    
    static let DefaultCreatingConfiguration = Configuration(mode: .Creating, title: "Create Account", leftBarButtons: [.Cancel], rightBarButtons: [.Done])
    static let DefaultEditingConfiguration = Configuration(mode: .Creating, title: "Edit Profile", leftBarButtons: [.Cancel], rightBarButtons: [.Done])
    
    weak var delegate: EditProfileViewControllerDelegate!
    
    //The configuration used to setup the class
    var configuration: Configuration!
    
    //The user being edited
    var user: User?
    
    
    // MARK: Private variables
    
    static private let StoryboardName = "EditProfile"
    static private let Identifier = "EditProfileViewController"
    
    private var doneButton: UIBarButtonItem!
    private var cancelButton: UIBarButtonItem!
    
    
    // MARK: Actions
    
    func onDoneAction() {
        let dummyUser = User.createDummy(fromNumber: 62)
        dismissViewControllerAnimated(true) {
            self.delegate.editProfileViewControllerDidFinishEditing(withUser: dummyUser)
        }
    }
    
    func onCancelAction() {
        dismissViewControllerAnimated(true, completion: nil)
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
        return storyboard.instantiateViewControllerWithIdentifier(EditProfileViewController.Identifier) as! EditProfileViewController
    }
    
    
    // MARK: Private methods
    
    private func setupNavigationBar() {
        doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(onDoneAction))
        cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(onCancelAction))
        
        
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
    
    private func barButtons(fromTypeList typeList: [Configuration.BarButtonType]) -> [UIBarButtonItem] {
        return typeList.map({barButton(forType: $0)})
    }
    
    private func barButton(forType type: Configuration.BarButtonType) -> UIBarButtonItem {
        switch type {
        case .Cancel:
            return cancelButton
        case .Done:
            return doneButton
        }
    }
}
