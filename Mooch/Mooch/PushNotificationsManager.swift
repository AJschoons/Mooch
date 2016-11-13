//
//  PushNotificationsManager.swift
//  Mooch
//
//  Created by adam on 10/22/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

protocol PushNotificationsManagerRegistrationDelegate: class {
    
    func pushNotificationsDidRegister(success: Bool)
}

protocol PushNotificationsManagerNotificationsDelegate: class {
    
    func onDidReceive(listingPush: PushNotificationsManager.ListingPush, whenAppClosed wasAppClosed: Bool)
}

//Singleton for managing all things with push notifications
class PushNotificationsManager {
    
    struct ListingPush {
        
        enum ExchangeType {
            case sellerApproved
            case buyerRequested
        }
        
        let exchangeType: ExchangeType
        let listingId: Int
    }
    
    //The variable to access this class through
    static let sharedInstance = PushNotificationsManager()
    
    weak var registrationDelegate: PushNotificationsManagerRegistrationDelegate?
    weak var notificationsDelegate: PushNotificationsManagerNotificationsDelegate?
    private(set) var deviceToken: String?
    
    private(set) var arePushNotificationsRegistered = false
    
    private let ViewAcceptedExchangeActionIdentifier = "VIEW_ACCEPTED_EXCHANGE_IDENTIFIER"
    private let ViewExchangeRequestActionIdentifier = "VIEW_EXCHANGE_REQUEST_IDENTIFIER"
    
    private let SellerApprovedCategoryIdentifier = "SELLER_APPROVED_CATEGORY"
    private let ExchangeRequestCategoryIdentifier = "EXCHANGE_REQUEST_CATEGORY"
    
    //This prevents others from using the default '()' initializer for this class
    fileprivate init() {}
    
    func successfullyRegistered(withDeviceToken deviceToken: String) {
        arePushNotificationsRegistered = true
        self.deviceToken = deviceToken
        registrationDelegate?.pushNotificationsDidRegister(success: true)
    }
    
    func failedToRegister() {
        arePushNotificationsRegistered = false
        registrationDelegate?.pushNotificationsDidRegister(success: false)
    }
    
    func notificationSettings() -> UIUserNotificationSettings {
        //
        //Construct notifcation category / actions for when the Seller approves an exchange
        //
        
        let viewExchangeAction = UIMutableUserNotificationAction()
        viewExchangeAction.identifier = ViewAcceptedExchangeActionIdentifier
        viewExchangeAction.title = "Contact Seller"
        viewExchangeAction.activationMode = .foreground
        
        let sellerApprovedCategory = UIMutableUserNotificationCategory()
        sellerApprovedCategory.identifier = SellerApprovedCategoryIdentifier
        sellerApprovedCategory.setActions([viewExchangeAction], for: .default)
        
        
        //
        //Construct notifcation category / actions for when a buyer requests an exchange
        //
        
        let viewExchangeRequestAction = UIMutableUserNotificationAction()
        viewExchangeRequestAction.identifier = ViewExchangeRequestActionIdentifier
        viewExchangeRequestAction.title = "View Request"
        viewExchangeRequestAction.activationMode = .foreground
        
        let exchangeRequestCategory = UIMutableUserNotificationCategory()
        exchangeRequestCategory.identifier = ExchangeRequestCategoryIdentifier
        exchangeRequestCategory.setActions([viewExchangeRequestAction], for: .default)
        
        return UIUserNotificationSettings(types: [.badge, .alert], categories: [sellerApprovedCategory, exchangeRequestCategory])
    }
    
    func areValid(registeredNotifcationSettings: UIUserNotificationSettings) -> Bool {
        let alertsAllowed = registeredNotifcationSettings.types.contains(.alert)
        let badgesAllowed = registeredNotifcationSettings.types.contains(.badge)
        return alertsAllowed && badgesAllowed
    }
    
    //Called when app is opened by custom action
    func handleAction(withIdentifier identifier: String?, forRemoteNotification userInfo: [AnyHashable : Any], withResponseInfo responseInfo: [AnyHashable : Any], completionHandler: @escaping () -> Swift.Void) {
        processNotification(userInfo: userInfo, receivedWhenAppClosed: true, completionHandler: completionHandler)
    }
    
    //Callback for when a push notification is received while app is running (or for silent push notifications; but we don't support those)
    func handleDidReceiveRemoteNotification(_ userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Swift.Void) {
        processNotification(userInfo: userInfo, receivedWhenAppClosed: false) {
            completionHandler(.newData)
        }
    }
    
    //Checks if there was a push notification tphat launched the app
    func handlePushNotificationLaunchOptions(launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        guard let remoteNotification = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? [AnyHashable : Any] else { return }
        processNotification(userInfo: remoteNotification, receivedWhenAppClosed: true, completionHandler: {})
    }
    
    private func processNotification(userInfo: [AnyHashable : Any], receivedWhenAppClosed: Bool, completionHandler: @escaping (() -> Swift.Void)) {
        let notificationJSON = JSON(userInfo)
        guard notificationJSON["aps"].exists() else { return }
        let notificationJSONData = notificationJSON["aps"]
        guard let category = notificationJSONData["category"].string, let listingId = notificationJSONData["listing_id"].int else { return }
        
        
        
        if category == SellerApprovedCategoryIdentifier {
            let push = ListingPush(exchangeType: .sellerApproved, listingId: listingId)
            notificationsDelegate?.onDidReceive(listingPush: push, whenAppClosed: receivedWhenAppClosed)
        } else if category == ExchangeRequestCategoryIdentifier {
            let push = ListingPush(exchangeType: .buyerRequested, listingId: listingId)
            notificationsDelegate?.onDidReceive(listingPush: push, whenAppClosed: receivedWhenAppClosed)
        }
    }
}

