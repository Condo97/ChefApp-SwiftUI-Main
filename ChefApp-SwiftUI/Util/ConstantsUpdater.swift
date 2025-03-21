//
//  ConstantsHelper.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/30/23.
//

import Foundation
import SwiftUI

class ConstantsUpdater: ObservableObject {
    
    @AppStorage("EasyPantryUpdateContainerOlderThanDays") var easyPantryUpdateContainerOlderThanDays: Int = 3
    @AppStorage("LaunchCount") var launchCount: Int = 0
    @AppStorage("CachedTikTokUrlsCSV") var cachedTikTokUrlsCSV: String = ""
    
    static var encodedBingAPIKey: String? {
        get {
            UserDefaults.standard.string(forKey: Constants.UserDefaults.storedEncodedBingAPIKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.UserDefaults.storedEncodedBingAPIKey)
        }
    }
    
    static var shareURL: String {
        get {
            UserDefaults.standard.string(forKey: Constants.UserDefaults.storedShareURL) ?? Constants.Additional.defaultShareURL
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.UserDefaults.storedShareURL)
        }
    }
    
    static var weeklyProductID: String {
        get {
            UserDefaults.standard.string(forKey: Constants.UserDefaults.storedWeeklyProductID) ?? Constants.Additional.fallbackWeeklyProductIdentifier
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.UserDefaults.storedWeeklyProductID)
        }
    }
    
    static var monthlyProductID: String {
        get {
            UserDefaults.standard.string(forKey: Constants.UserDefaults.storedMonthlyProductID) ?? Constants.Additional.fallbackMonthlyProductIdentifier
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.UserDefaults.storedMonthlyProductID)
        }
    }
    
    
    func update() async throws {
        let response = try await ChefAppNetworkService.getImportantConstants()
        
        ConstantsUpdater.encodedBingAPIKey = response.body.bingAPIKey
        
        if let shareURL = response.body.shareURL {
            ConstantsUpdater.shareURL = shareURL
        }
        
//        // Check if iapVarientSuffix is nil or empty, and if so do chance calculation based on priceVAR2DisplayChance and set iapVarientSuffix
//        if iapVarientSuffix == nil || iapVarientSuffix!.isEmpty, let priceVAR2DisplayChance = response.body.priceVAR2DisplayChance {
//            // Get random double
//            let randomDouble = Double.random(in: 0..<1)
//            
//            // Since we're getting a percentage that the price will be VAR2, we can create a random number between 0-1 and check if it is less than priceVAR2DisplayChance.. for example, it the priceVAR2DisplayChance is 0.8, check if our random number is less than or equal to 0.8 and if so then set suffix to VAR2 otherwise VAR1
//            iapVarientSuffix = randomDouble < priceVAR2DisplayChance ? priceVAR2Suffix : priceVAR1Suffix
//        }
        
//        // Set weekly and monthly productID and displayPrice by iapVarientSuffix
//        if iapVarientSuffix == priceVAR2Suffix {
//            // Set VAR2
//            if let responseWeeklyProductID = response.body.weeklyProductID_VAR2 {
//                weeklyProductID = responseWeeklyProductID
//            }
//            
//            if let responseMonthlyProductID = response.body.monthlyProductID_VAR2 {
//                monthlyProductID = responseMonthlyProductID
//            }
//        } else {
            // Default to VAR1
            if let weeklyProductID = response.body.weeklyProductID {
                ConstantsUpdater.weeklyProductID = weeklyProductID
            }
            
            if let monthlyProductID = response.body.monthlyProductID {
                ConstantsUpdater.monthlyProductID = monthlyProductID
            }
//        }
        
    }
    
    private static func setIfNil(_ value: Any, forKey key: String) {
        if UserDefaults.standard.object(forKey: key) == nil {
            UserDefaults.standard.set(value, forKey: key)
        }
    }
    
}
