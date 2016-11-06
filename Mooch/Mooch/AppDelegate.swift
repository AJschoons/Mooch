//
//  AppDelegate.swift
//  Mooch
//
//  Created by adam on 9/2/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit
import UserNotifications

struct Platform {
    static var isSimulator: Bool {
        return TARGET_OS_SIMULATOR != 0
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    private(set) var moochTabBarController: MoochTabBarController!
    
    private let TransitionToTabBarDuration = 0.3

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        customizeAppearences()
        
        let initialLoadingViewController = InitialLoadingViewController()
        PushNotificationsManager.sharedInstance.registrationDelegate = initialLoadingViewController
        
        moochTabBarController = MoochTabBarController.instantiate()
        CommunityListingsManager.sharedInstance.delegate = moochTabBarController
        PushNotificationsManager.sharedInstance.notificationsDelegate = moochTabBarController
        
        //Must be called after the delegates of the PushNotificationsManager are setup
        PushNotificationsManager.sharedInstance.handlePushNotificationLaunchOptions(launchOptions: launchOptions)
        
        registerForPushNotifications(application)
        
        window?.rootViewController = initialLoadingViewController
        window?.makeKeyAndVisible()
        
        return true
    }
    
    func transitionToMoochTabBarController() {
        guard let window = window, let moochTabBarController = moochTabBarController else { return }
        UIView.transition(
            with: window,
            duration: TransitionToTabBarDuration,
            options: UIViewAnimationOptions.transitionCrossDissolve,
            animations: {
                window.rootViewController = moochTabBarController
            },
            completion: nil)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        //Reset the badge count when the app is opened
        application.applicationIconBadgeNumber = 0
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    //
    //Appearences
    //

    func customizeAppearences() {
        
        //
        //Nav bar
        //
        
        //Sets the colors of the bar buttons
        UINavigationBar.appearance().tintColor = ThemeColors.moochBlack.color()
        //Change how title looks
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : ThemeColors.moochRed.color()]
        
        
        
        //Changes the checkmarks and other elements on the right of cells to be the color below
        UITableView.appearance().tintColor = ThemeColors.moochYellow.color()
    }
    
    
    //
    //Push notification stuff
    //
    
    //Helper method
    private func registerForPushNotifications(_ application: UIApplication) {
        let notificationSettings = PushNotificationsManager.sharedInstance.notificationSettings()
        application.registerUserNotificationSettings(notificationSettings)
    }
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        if PushNotificationsManager.sharedInstance.areValid(registeredNotifcationSettings: notificationSettings) {
            application.registerForRemoteNotifications()
        } else {
            PushNotificationsManager.sharedInstance.failedToRegister()
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        PushNotificationsManager.sharedInstance.successfullyRegistered(withDeviceToken: deviceTokenString)
    }
    
    func application(_ : UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        PushNotificationsManager.sharedInstance.failedToRegister()
        print("Failed to register push notifications: ", error)
    }
    
    //Callback when app is opened by custom action
    public func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [AnyHashable : Any], withResponseInfo responseInfo: [AnyHashable : Any], completionHandler: @escaping () -> Swift.Void) {
        PushNotificationsManager.sharedInstance.handleAction(withIdentifier: identifier, forRemoteNotification: userInfo, withResponseInfo: responseInfo, completionHandler: completionHandler)
    }
    
    //Callback for when a push notification is received
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Swift.Void) {
        PushNotificationsManager.sharedInstance.handleDidReceiveRemoteNotification(userInfo, fetchCompletionHandler: completionHandler)
    }
}

