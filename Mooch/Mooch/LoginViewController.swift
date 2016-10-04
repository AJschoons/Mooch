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
        
        var isFilledAndValid: Bool { return email != nil && password != nil && isEmailValid && isPasswordValid }
        
        var isEmailValid: Bool {
            guard let email = email else { return false }
            return UserLoginInformationValidator.isValid(email: email)
        }
        
        var isPasswordValid: Bool {
            guard let password = password else { return false }
            return UserLoginInformationValidator.isValid(password: password)
        }
    }
    
    // MARK: Public variables
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var emailTextField: LoginTextField!
    @IBOutlet weak var passwordTextField: LoginTextField!
    @IBOutlet weak var loginButton: RoundedButton!

    @IBOutlet var textHandler: LoginTextHandler! {
        didSet {
            textHandler.delegate = self
        }
    }
    
    weak var delegate: LoginViewControllerDelegate?
    
    
    // MARK: Private variables
    
    static fileprivate let StoryboardName = "Login"
    static fileprivate let Identifier = "LoginViewController"
    
    private let KeyboardSpacingBelowLoginButton: CGFloat = 10
    
    fileprivate var loginData = LoginData(email: nil, password: nil)
    
    //Used to differentiate view will/did disappear messages from when another view is being presented or pushed
    fileprivate var isDismissingSelf = false
    
    // MARK: Actions
    
    @IBAction func onCancel() {
        dismissSelf(completion: nil)
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
    
    func onKeyboardDidShow(withNotification notification: Notification) {
        guard let keyboardRect = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        scrollIfNeeded(forKeyboardRect: keyboardRect)
    }
    
    func onKeyboardWillHide(withNotification notification: Notification) {
        resetScroll()
    }
    
    override func setup() {
        super.setup()
        
        setupTextFields()
        registerForKeyboardNotifacations()
        
        updateUI()
    }
    
    override func updateUI() {
        super.updateUI()
        
        var loginButtonColor: UIColor
        var loginButtonUserInteractionEnabled: Bool
        if loginData.isFilledAndValid {
            loginButtonColor = UIColor(red: 0.00, green: 0.76, blue: 0.00, alpha: 1.0)
            loginButtonUserInteractionEnabled = true
        } else {
            loginButtonColor = UIColor.darkGray
            loginButtonUserInteractionEnabled = false
        }
        
        loginButton.backgroundColor = loginButtonColor
        loginButton.isUserInteractionEnabled = loginButtonUserInteractionEnabled
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
            self.dismissSelf(completion: nil)
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func login(withUser user: User) {
        let localUser = LocalUser(user: user, authenticationToken: "fake token")
        LocalUserManager.sharedInstance.login(withLocalUser: localUser)
    }
    
    private func setupTextFields() {
        emailTextField.delegate = textHandler
        passwordTextField.delegate = textHandler
        
        emailTextField.nextNavigableResponder = passwordTextField
        
        emailTextField.fieldType = .email
        passwordTextField.fieldType = .password
    }
    
    fileprivate func registerForKeyboardNotifacations() {
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardDidShow(withNotification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillHide(withNotification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    fileprivate func unregisterForKeyboardNotifacations() {
        NotificationCenter.default.removeObserver(self)
    }
    
    //If needed, scrolls the screen so that KeyboardSpacingBelowLoginButton pixels are visible below the Login Button
    private func scrollIfNeeded(forKeyboardRect keyboardRect: CGRect) {
        let loginButtonFrameInViewCoordinates = view.convert(loginButton.frame, from: loginButton.superview)
        
        // Y coordinate of the point KeyboardSpacingBelowLoginButton pixels below the button
        let pointToBeVisibleY = loginButtonFrameInViewCoordinates.origin.y + loginButtonFrameInViewCoordinates.height + KeyboardSpacingBelowLoginButton
        
        let topOfKeyboardY = view.frame.height - keyboardRect.height
        let heightOfVisiblePointHidden = pointToBeVisibleY - topOfKeyboardY
        
        if heightOfVisiblePointHidden > 1 {
            let offset = CGPoint(x: 0, y: heightOfVisiblePointHidden)
            scrollView.setContentOffset(offset, animated: true)
        }
    }
    
    //Resets the scroll view after the keyboard is dismissed
    private func resetScroll() {
        let offset = CGPoint.zero
        scrollView.setContentOffset(offset, animated: true)
    }
    
    fileprivate func dismissSelf(completion: (() -> Void)?) {
        isDismissingSelf = true
        dismiss(animated: true, completion: completion)
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
        
        updateUI()
    }
}
