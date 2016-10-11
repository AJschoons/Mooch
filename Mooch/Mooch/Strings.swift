//
//  Strings.swift
//  Mooch
//
//  Created by adam on 9/5/16.
//  Copyright © 2016 cse498. All rights reserved.
//

//Enumeration for string literals used in the app
enum Strings {
    //case InvalidCategoryId = "Bad Category Id"
    
    enum Alert: String {
        case defaultSingleActionTitle = "Okay"
    }
    
    enum SharedErrors: String {
        case invalidCategory = "Invalid Category"
    }
    
    enum EditListing: String {
        case cancelButtonTitle = "Cancel"
        
        case defaultCreatingTitle = "Create Listing"
        case defaultEditingTitle = "Edit Listing"
        
        case invalidCreationErrorAlertTitle = "Problem creating listing"
        case invalidCreationErrorAlertMessageFirstPart = "Please complete filling out the information for the "
        case invalidCreationErrorAlertMessageSecondPart = " field"
        
        case uploadingNewLoadingOverlay = "Uploading Listing"
        case uploadingNewErrorAlertTitle = "Problem Uploading Listing"
        case uploadingNewErrorAlertMessage = "Please try uploading the listing again"
        
        case unselectedCategory = "Unselected"
    }
    
    enum EditProfile: String {
        case cancelButtonTitle = "Cancel"
        
        case defaultCreatingTitle = "Create Profile"
        case defaultEditingTitle = "Edit Profile"
        
        case invalidCreationErrorAlertTitle = "Problem creating listing"
        case invalidCreationErrorAlertMessageUnfilledInfoFirstPart = "Please complete filling out the information for the "
        case invalidCreationErrorAlertMessageUnfilledInfoSecondPart = " field"
        case invalidCreationErrorAlertMessageEmail = "Please enter a valid email address"
        case invalidCreationErrorAlertMessagePhone = "Please enter a valid phone number"
        case invalidCreationErrorAlertMessagePassword = "Please enter a valid password. Passwords must be 6-30 characters"
        case invalidCreationErrorAlertMessagePasswordMatch = "Please check that the passwords match"
        
        case uploadingNewLoadingOverlay = "Uploading Profile"
        case uploadingNewErrorAlertTitle = "Problem Uploading Profile"
        case uploadingNewErrorAlertMessage = "Please try uploading the profile again"
        
        case unselectedCategory = "Unselected"
    }
    
    enum MoochAPI: String {
        case listingImageFilename = "listing_image.jpeg"
        case userImageFilename = "user_image.jpeg"
    }
    
    enum MoochAPIRouter: String {
        case baseURL = "https://mooch-rails-api.appspot.com/api/v1"
    }
    
}


//
// How to markdown a complex object:
//

// MARK: Public variables

// MARK: Private variables

// MARK: Actions

// MARK: Public methods

// MARK: Private methods
