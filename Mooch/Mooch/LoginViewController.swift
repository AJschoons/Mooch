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

//View controller that handles logging in
class LoginViewController: MoochModalViewController {
    
    //The types of fields needed for logging in
    enum FieldType {
        case email
        case password
    }
    
    //Tracks the state of the login data. Fields must be nil if empty or invalid
    struct LoginData {
        var email: String?
        var password: String?
        
        var isFilledAndValid: Bool { return email != nil && password != nil && isEmailValid }
        
        var isEmailValid: Bool { return false }
    }
    
    // MARK: Public variables
    
    @IBOutlet weak var emailTextView: LoginTextView!
    @IBOutlet weak var passwordTextView: LoginTextView!
    @IBOutlet var textHandler: LoginTextHandler! {
        didSet {
            textHandler.delegate = self
        }
    }
    
    weak var delegate: LoginViewControllerDelegate?
    
    
    // MARK: Private variables
    
    static fileprivate let StoryboardName = "Login"
    static fileprivate let Identifier = "LoginViewController"
    
    fileprivate var loginData = LoginData(email: nil, password: nil)
    
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
    
    override func setup() {
        super.setup()
        
        setupTextViews()
        
        updateUI()
    }
    
    override func updateUI() {
        super.updateUI()
        
//        let emailTextViewState: LoginTextView.State = loginData.email == nil ? .empty : .notEmpty
//        emailTextView.updateUI(forState: emailTextViewState)
//
//        let passwordTextViewState: LoginTextView.State = loginData.email == nil ? .empty : .notEmpty
//        passwordTextView.updateUI(forState: passwordTextViewState)
        
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
    
    private func setupTextViews() {
        emailTextView.delegate = textHandler
        passwordTextView.delegate = textHandler
        
        emailTextView.nextNavigableTextView = passwordTextView
        
        emailTextView.fieldType = .email
        passwordTextView.fieldType = .password
    }
}

extension LoginViewController: EditProfileViewControllerDelegate {
    
    func editProfileViewControllerDidFinishEditing(withUser editedUser: User) {
        login(withUser: editedUser)
        presentAccountCreatedAlert(forUser: editedUser)
    }
}

extension LoginViewController: LoginTextHandlerDelegate {
    
    func updated(text: String, forFieldType fieldType: LoginViewController.FieldType) {
        let isEmpty = text == ""
        
        switch fieldType {
        case .email:
            loginData.email = isEmpty ? nil : text
        case .password:
            loginData.password = isEmpty ? nil : text
        }
    }
}
