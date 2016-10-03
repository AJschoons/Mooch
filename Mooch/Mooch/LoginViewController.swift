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
    
    static fileprivate let StoryboardName = "Login"
    static fileprivate let Identifier = "LoginViewController"
    
    // MARK: Actions
    
    @IBAction func onCancel() {
        dismiss(animated: true, completion: nil)
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
    
    static func instantiateFromStoryboard() -> LoginViewController {
        let storyboard = UIStoryboard(name: LoginViewController.StoryboardName, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: LoginViewController.Identifier) as! LoginViewController
    }
    
    override func prefersNavigationBarHidden() -> Bool {
        return true
    }
    
    // MARK: Private methods
    
    fileprivate func presentEditProfileViewController() {
        let vc = EditProfileViewController.instantiateFromStoryboard()
        vc.configuration = EditProfileViewController.DefaultCreatingConfiguration
        vc.delegate = self
        let navC = UINavigationController(rootViewController: vc)
        present(navC, animated: true, completion: nil)
    }
    
    fileprivate func presentAccountCreatedAlert(forUser user: User) {
        let alert = UIAlertController(title: "Account Created", message: "Welcome to Mooch, \(user.name)!", preferredStyle: .alert)
        let action = UIAlertAction(title: "Get Mooching", style: .default) { _ in
            self.delegate?.loginViewControllerDidLogin(withUser: user)
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func login(withUser user: User) {
        let localUser = LocalUser(user: user, authenticationToken: "fake token")
        LocalUserManager.sharedInstance.login(withLocalUser: localUser)
    }
}

extension LoginViewController: EditProfileViewControllerDelegate {
    
    func editProfileViewControllerDidFinishEditing(withUser editedUser: User) {
        login(withUser: editedUser)
        presentAccountCreatedAlert(forUser: editedUser)
    }
}
