//
//  LoginViewController.swift
//  Mooch
//
//  Created by adam on 9/12/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

protocol LoginViewControllerDelegate: class {
    
    func loginViewControllerDidLogin(withUser loggedInUser: User)
}

class LoginViewController: MoochModalViewController {
    
    // MARK: Public variables
    
    weak var delegate: LoginViewControllerDelegate?
    
    
    // MARK: Private variables
    
    // MARK: Actions
    
    @IBAction func onCancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onLogin() {
        let dummyUser = User.createDummy(fromNumber: 83)
        login(withUser: dummyUser)
        delegate?.loginViewControllerDidLogin(withUser: dummyUser)
    }
    
    @IBAction func onCreateAccount() {
        presentEditProfileViewController()
    }
    
    // MARK: Public methods
    
    override func prefersNavigationBarHidden() -> Bool {
        return true
    }
    
    // MARK: Private methods
    
    private func presentEditProfileViewController() {
        let vc = EditProfileViewController.instantiateFromStoryboard()
        vc.configuration = EditProfileViewController.DefaultCreatingConfiguration
        vc.delegate = self
        let navC = UINavigationController(rootViewController: vc)
        presentViewController(navC, animated: true, completion: nil)
    }
    
    private func presentAccountCreatedAlert(forUser user: User) {
        let alert = UIAlertController(title: "Account Created", message: "Welcome to Mooch, \(user.name)!", preferredStyle: .Alert)
        let action = UIAlertAction(title: "Get Mooching", style: .Default) { _ in
            self.delegate?.loginViewControllerDidLogin(withUser: user)
        }
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    private func login(withUser user: User) {
        let localUser = LocalUser(user: user, password: "test password")
        LocalUserManager.sharedInstance.login(withLocalUser: localUser)
    }
}

extension LoginViewController: EditProfileViewControllerDelegate {
    
    func editProfileViewControllerDidFinishEditing(withUser editedUser: User) {
        login(withUser: editedUser)
        presentAccountCreatedAlert(forUser: editedUser)
    }
}