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
        case funGetMoochingSingleActionTitle = "Get Mooching"
        case singleActionTryAgainTitle = "Try again"
    }
    
    enum CommunityPicker: String {
        case title = "CHOOSE A COMMUNITY"
    }
    
    enum EditListing: String {
        case cancelButtonTitle = "Cancel"
        
        case defaultCreatingTitle = "Sell Item"
        case defaultEditingTitle = "Edit Item"
        
        case fieldTypePhotoTextDescription = "Photo"
        case fieldTypeTitleTextDescription = "Title"
        case fieldTypeDescriptionTextDescription = "Description"
        case fieldTypePriceTextDescription = "Price"
        case fieldTypeQuantityTextDescription = "Quantity"
        case fieldTypeCategoryTextDescription = "Category"
        
        case invalidEditErrorAlertTitle = "Problem editing listing"
        case invalidCreationErrorAlertTitle = "Problem creating listing"
        case invalidCreationErrorAlertMessageFirstPart = "Please complete filling out the information for the "
        case invalidCreationErrorAlertMessageSecondPart = " field"
        case invalidCreationErrorInvalidPriceAlertMessage = "The price cannot be greater than $200.00"
        
        case noInformationChangedAlertMessage = "The listing information has not been changed"
        
        case uploadingNewLoadingOverlay = "Uploading Listing"
        case uploadingNewErrorAlertTitle = "Problem Uploading Listing"
        case uploadingNewErrorAlertMessage = "Please try uploading the listing again"
        
        case unselectedCategory = "Unselected"
    }
    
    enum EditProfile: String {
        case cancelButtonTitle = "Cancel"
        
        case defaultCreatingTitle = "CREATE ACCOUNT"
        case defaultEditingTitle = "EDIT ACCOUNT"
        
        case fieldTypePhotoTextDescription = "Photo"
        case fieldTypeNameTextDescription = "Name"
        case fieldTypeEmailTextDescription = "Email"
        case fieldTypePhoneTextDescription = "Phone"
        case fieldTypeAddressTextDescription = "Address"
        case fieldTypePassword1TextDescription = "Password"
        case fieldTypePassword2TextDescription = "Confirm Password"
        
        case invalidCreationErrorAlertTitle = "Problem creating profile"
        case invalidEditingErrorAlertTitle = "Problem editing profile"
        case invalidCreationErrorAlertMessageUnfilledInfoFirstPart = "Please complete filling out the information for the "
        case invalidCreationErrorAlertMessageUnfilledInfoSecondPart = " field"
        case invalidCreationErrorAlertMessageEmail = "Please enter a valid email address"
        case invalidCreationErrorAlertMessagePhone = "Please enter a valid phone number"
        case invalidCreationErrorAlertMessagePassword = "Please enter a valid password. Passwords must be 6-30 characters"
        case invalidCreationErrorAlertMessagePasswordMatch = "Please check that the passwords match"
        case invalidCreationErrorAlertMessageCommunity = "Please select a community"
        
        case noInformationChangedAlertMessage = "The profile information has not been changed"
        
        case uploadingNewLoadingOverlay = "Uploading Profile"
        case uploadingNewErrorAlertTitle = "Problem Uploading Profile"
        case uploadingNewErrorAlertMessage = "Please try uploading the profile again"
        
        case unselectedCommunity = "Unselected"
    }
    
    enum InitialLoading: String {
        case couldNotDownloadInitialDataAlertTitle = "Problem Connecting to Mooch"
        case couldNotDownloadInitialDataAlertMessage = "We were unable to download the data needed to launch"
        
        case loadingText = "Loading"
        case failedPushNotificationRegistrationText = "Mooch requires push notifications to be enabled.\n\nPlease enable them at:\nSettings > Notifications > Mooch\n\nThen restart the app"
    }
    
    enum Login: String {
        case loginOverlay = "Logging In"
        case loginErrorAlertTitle = "Problem Logging In"
        case loginErrorAlertMessage = "Please check the email and password then try again"
    }
    
    enum LoginTextField: String {
        case emailPlaceholder = "Email"
        case passwordPlaceholder = "Password"
    }
    
    enum ListingCategoryPicker: String {
        case title = "CATEGORIES"
    }
    
    enum ListingDetails: String {
        case alertBannerLabelListingSold = "LISTING SOLD"
        case alertBannerLabelListingEnded = "LISTING ENDED"
        
        case title = "VIEW LISTING"
        
        case fieldTypeContactSellerNoContactYetActionString = "Contact Seller"
        case fieldTypeContactSellerAlreadyContactedActionString = "Contacted Seller"
        case fieldTypeViewSellerProfileActionString = "View Seller Profile"
        case fieldTypeEndListingActionString = "End Listing"
        
        case listingDesriptionNoDescription = "No description provided"
    }
    
    enum Listings: String {
        case loadingListingsOverlay = "Loading Listings"
        case loadingListingsErrorAlertTitle = "Problem Loading Listings"
        case loadingListingsErrorAlertMessage = "Please try pulling to refresh to reload the listings"
        
        case navigationItemTitle = "MOOCH"
        
        case noListingsInCommunityLabelText = "There are currently no listings in this community"
        case noListingsInCommunityMatchingSearchLabelText = "There are currently no listings in this community matching this search"
        case noListingsAfterFilterAppliedLabelText = "There are currently no listings in this community matching the filters applied"
        case noListingsMatchingSearchAfterFilterAppliedLabelText = "There are currently no listings in this community matching this search and the filters applied"
    }
    
    enum MoochAPI: String {
        case listingImageFilename = "listing_image.jpeg"
        case userImageFilename = "user_image.jpeg"
    }
    
    enum MoochAPIRouter: String {
        case baseURL = "https://mooch-rails-api.appspot.com/api/v1"
    }
    
    enum Profile: String {
        case titleLocalUser = "My Profile"
        case titleSellerProfile = "Seller Profile"
        
        case noListings = "There are currently no listings to show"

    }
    
    enum SharedErrors: String {
        case invalidCategory = "Invalid Category"
    }
    
    enum TabBar: String {
        case home = "Home"
        case search = "Search"
        case sell = "Sell"
        case myProfile = "My Profile"
        
        case loggedOutMyProfileTabActionSheetActionTitleLoginOrSignUp = "Login / Sign up"
        case loggedOutMyProfileTabActionSheetActionTitleChangeCommunity = "Change Community"
        case loggedOutMyProfileTabActionSheetActionTitleCancel = "Cancel"
    }
    
    enum UserDefaultsKeys: String {
        case userId = "userId"
        case authenticationToken = "authenticationToken"
        case email = "email"
        case guestCommunityId = "guestCommunityId"
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
