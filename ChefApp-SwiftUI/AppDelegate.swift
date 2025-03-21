//
//  AppDelegate.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 3/24/24.
//

import AppsFlyerLib
import AppTrackingTransparency
import FacebookCore
import Foundation
import SwiftUI

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        
        // Configure AppsFlyer
        // Request push notifications, which will later request tracking
        Task {
            let center = UNUserNotificationCenter.current()
            try await center.requestAuthorization(options: [.badge, .sound, .alert])
            
            // 3
            await MainActor.run {
                application.registerForRemoteNotifications()
            }
        }
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Start AppsFlyer
        AppsFlyerLib.shared().start()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Task {
            do {
                let registerAPNSRequest = APNSRegistrationRequest(
                    authToken: try await AuthHelper.ensure(),
                    deviceID: deviceToken)
                
                let response = try await ChefAppNetworkService.registerAPNS(request: registerAPNSRequest)
                
                // TODO: Handle Response
            } catch {
                // TODO: Handle Errors if Necessary
                print("Error registering APNS in AppDelegate... \(error)")
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
#if DEBUG
                AppsFlyerLib.shared().isDebug = true
#endif
                AppsFlyerLib.shared().appsFlyerDevKey = Keys.AppsFlyer.devKey
                AppsFlyerLib.shared().appleAppID = Keys.AppsFlyer.appKey
                AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 120.0)
                AppsFlyerLib.shared().delegate = self
                //        NotificationCenter.default.addObserver(self, selector: NSSelectorFromString("sendLaunch"), name: UIApplication.didBecomeActiveNotification, object: nil) // SceneDelegate support
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0) {
                    ATTrackingManager.requestTrackingAuthorization { (status) in
                        // Set Facebook Advertising Tracking Enabled to True
                        Settings.shared.isAdvertiserTrackingEnabled = true
                        Settings.shared.isAdvertiserIDCollectionEnabled = true
                        
                        // Do stuff for status
                        switch status {
                        case .denied:
                            print("AuthorizationSatus is denied")
                        case .notDetermined:
                            print("AuthorizationSatus is notDetermined")
                        case .restricted:
                            print("AuthorizationSatus is restricted")
                        case .authorized:
                            print("AuthorizationSatus is authorized")
                        @unknown default:
                            print("Invalid authorization status")
                        }
                    }
                }
            }
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
#if DEBUG
            AppsFlyerLib.shared().isDebug = true
#endif
            AppsFlyerLib.shared().appsFlyerDevKey = Keys.AppsFlyer.devKey
            AppsFlyerLib.shared().appleAppID = Keys.AppsFlyer.appKey
            AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 120.0)
            AppsFlyerLib.shared().delegate = self
            //        NotificationCenter.default.addObserver(self, selector: NSSelectorFromString("sendLaunch"), name: UIApplication.didBecomeActiveNotification, object: nil) // SceneDelegate support
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0) {
                ATTrackingManager.requestTrackingAuthorization { (status) in
                    // Set Facebook Advertising Tracking Enabled to True
                    Settings.shared.isAdvertiserTrackingEnabled = true
                    Settings.shared.isAdvertiserIDCollectionEnabled = true
                    
                    // Do stuff for status
                    switch status {
                    case .denied:
                        print("AuthorizationSatus is denied")
                    case .notDetermined:
                        print("AuthorizationSatus is notDetermined")
                    case .restricted:
                        print("AuthorizationSatus is restricted")
                    case .authorized:
                        print("AuthorizationSatus is authorized")
                    @unknown default:
                        print("Invalid authorization status")
                    }
                }
            }
        }
    }
    
    //    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    //
    //    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Set notFirstLaunchEver to true
        UserDefaults.standard.set(true, forKey: Constants.UserDefaults.storedNotFirstLaunchEver)
    }
    
}


extension AppDelegate: AppsFlyerLibDelegate {
    
    func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {
        print("Conversion data success in App Delegate!")
        
        if let status = conversionInfo["af_status"] as? String {
            if status == "Non-organic" {
                if let sourceID = conversionInfo["media_source"],
                   let campaign = conversionInfo["campaign"] {
                    NSLog("[AFSDK] This is a Non-Organic install. Media source: \(sourceID)  Campaign: \(campaign)")
                }
            } else {
                NSLog("[AFSDK] This is an organic install.")
            }
            if let is_first_launch = conversionInfo["is_first_launch"] as? Bool,
               is_first_launch {
                NSLog("[AFSDK] First Launch")
            } else {
                NSLog("[AFSDK] Not First Launch")
            }
        }
    }
    
    func onConversionDataFail(_ error: Error) {
        print("Conversion data fail in App Delegate... \(error)")
    }
    
}

