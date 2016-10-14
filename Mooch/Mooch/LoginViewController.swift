//
//  LoginViewController.swift
//  Mooch
//
//  Created by adam on 9/12/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

protocol LoginViewControllerDelegate: class {
    func loginViewControllerDidLogin(localUser: LocalUser)
    func loginViewControllerDidCancel()
}

//View controller that handles logging in
class LoginViewController: MoochModalViewController {
    
    //The types of fields needed for logging in
    enum FieldType {
        case email
        case password
    }
    
    enum State {
        case loginFieldsUnfilledOrInvalid
        case loginFieldsFilledAndValid
        case loggingIn
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
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var loginButton: RoundedButton!
    @IBOutlet weak var createAccountButton: RoundedButton!

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
    
    //The current state of the view controller. Setting it will update the UI accordingly
    fileprivate var state: State = .loginFieldsUnfilledOrInvalid {
        didSet {
            updateUI()
        }
    }
    
    //Used to differentiate view will/did disappear messages from when another view is being presented or pushed
    fileprivate var isDismissingSelf = false
    
    // MARK: Actions
    
    @IBAction func onCancel() {
        dismissSelf(completion: nil)
    }
    
    @IBAction func onLogin() {
        guard let email = loginData.email, let password = loginData.password, loginData.isFilledAndValid else { return }
        login(email: email, password: password)
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
    
    //Shouldn't be called directly other than when view is first setup; gets called when the state variable changes
    override func updateUI() {
        super.updateUI()
        
        var loginButtonColor: UIColor
        var loginButtonUserInteractionEnabled: Bool
        var createAccountButtonUserInteractionEnabled: Bool
        var textFieldUserInteractionEnabled: Bool
        
        switch state {
        case .loginFieldsUnfilledOrInvalid:
            loginButtonColor = UIColor.darkGray
            loginButtonUserInteractionEnabled = false
            createAccountButtonUserInteractionEnabled = true
            textFieldUserInteractionEnabled = true
        case .loginFieldsFilledAndValid:
            loginButtonColor = UIColor(red: 0.00, green: 0.76, blue: 0.00, alpha: 1.0)
            loginButtonUserInteractionEnabled = true
            createAccountButtonUserInteractionEnabled = true
            textFieldUserInteractionEnabled = true
        case .loggingIn:
            loginButtonColor = UIColor.darkGray
            loginButtonUserInteractionEnabled = false
            createAccountButtonUserInteractionEnabled = false
            textFieldUserInteractionEnabled = false
        }
        
        loginButton.backgroundColor = loginButtonColor
        loginButton.isUserInteractionEnabled = loginButtonUserInteractionEnabled
        createAccountButton.isUserInteractionEnabled = createAccountButtonUserInteractionEnabled
        emailTextField.isUserInteractionEnabled = textFieldUserInteractionEnabled
        passwordTextField.isUserInteractionEnabled = textFieldUserInteractionEnabled
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
    
    fileprivate func presentAccountCreatedAlert(forLocalUser localUser: LocalUser) {
        let title = Strings.Login.accountCreatedAlertTitle.rawValue
        let message = "\(Strings.Login.accountCreatedAlertMessageFirstPart)\(localUser.user.name)\(Strings.Login.accountCreatedAlertMessageSecondPart)"
        let actionTitle = Strings.Alert.funGetMoochingSingleActionTitle.rawValue
        
        presentSingleActionAlert(title: title, message: message, actionTitle: actionTitle) { _ in
            self.dismissSelfAndNotifyDelegateOfLogin(for: localUser)
        }
    }
    
    //Makes an API call to login. Shows a loading overlay while waiting. On success logs that user in locally, else shows an alert on failure
    fileprivate func login(email: String, password: String) {
        state = .loggingIn
        showLoadingOverlayView(withInformationText: Strings.Login.loginOverlay.rawValue, overEntireWindow: false, withUserInteractionEnabled: false, showingProgress: false)
        
        MoochAPI.POSTLogin(email: email, password: password) { [weak self] localUser, error in
            guard let strongSelf = self else { return }
            
            if let localUser = localUser {
                LocalUserManager.sharedInstance.login(localUser: localUser)
                strongSelf.dismissSelfAndNotifyDelegateOfLogin(for: localUser)
            } else {
                strongSelf.state = .loginFieldsFilledAndValid
                strongSelf.presentSingleActionAlert(title: Strings.Login.loginErrorAlertTitle.rawValue, message: Strings.Login.loginErrorAlertMessage.rawValue, actionTitle: Strings.Alert.defaultSingleActionTitle.rawValue)
                strongSelf.hideLoadingOverlayView(animated: true)
            }
        }
    }
    
    //Use this method after login or account creation to dismiss this view controller and notify the delegate
    fileprivate func dismissSelfAndNotifyDelegateOfLogin(for localUser: LocalUser) {
        delegate?.loginViewControllerDidLogin(localUser: localUser)
        dismissSelf(completion: nil)
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
    
    func editProfileViewControllerDidFinishEditing(localUser: LocalUser, isNewProfile: Bool) {
        if isNewProfile {
            LocalUserManager.sharedInstance.login(localUser: localUser)
            presentAccountCreatedAlert(forLocalUser: localUser)
        }
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
        
        if loginData.isFilledAndValid {
            state = .loginFieldsFilledAndValid
        } else {
            state = .loginFieldsUnfilledOrInvalid
        }
    }
}
