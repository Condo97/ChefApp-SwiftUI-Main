////
////  ColorUpdater.swift
////  Barback
////
////  Created by Alex Coundouriotis on 10/5/23.
////
//
//import Foundation
//import SwiftUI
//
//class ColorUpdater: ObservableObject {
//    
//    @Published var elementColor: Color
//    @Published var totalColor: Color
//    @Published var mostRecentColor: Color
//    @Published var shortPeriodColor: Color
//    @Published var mediumPeriodColor: Color
//    @Published var longPeriodColor: Color
//    
//    var elementColorOverrideSettingState: ElementColorOverrideSettingState {
//        get {
//            // Get from persistent element color override setting state
//            ColorUpdater.persistentElementColorOverrideSettingState
//        }
//        set {
//            // Set persistentElementColorOverrideSettingState to newValue and update element color
//            ColorUpdater.persistentElementColorOverrideSettingState = newValue
//            
//            updateElementColor()
//        }
//    }
//    
//    private static var persistentElementColor: Color {
//        switch ColorUpdater.persistentElementColorOverrideSettingState {
//        case .auto:
//            ColorUpdater.getColorFromUserDefaults(userDefaultsSuffix: ColorUpdater.autoElementColorUserDefaultsSuffix)
//        case .red:
//            ColorUpdater.elementColors.mostlyRed
//        case .green:
//            ColorUpdater.elementColors.mostlyGreen
//        case .blue:
//            ColorUpdater.elementColors.mostlyBlue
//        }
//    }
//    
//    private static var persistentTotalColor: Color {
//        ColorUpdater.getColorFromUserDefaults(userDefaultsSuffix: totalColorUserDefaultsSuffix)
//    }
//    
//    private static var persistentMostRecentColor: Color {
//        ColorUpdater.getColorFromUserDefaults(userDefaultsSuffix: mostRecentColorUserDefaultsSuffix)
//    }
//    
//    private static var persistentShortPeriodColor: Color {
//        ColorUpdater.getColorFromUserDefaults(userDefaultsSuffix: shortPeriodColorUserDefaultsSuffix)
//    }
//    
//    private static var persistentMediumPeriodColor: Color {
//        ColorUpdater.getColorFromUserDefaults(userDefaultsSuffix: mediumPeriodColorUserDefaultsSuffix)
//    }
//    
//    private static var persistentLongPeriodColor: Color {
//        ColorUpdater.getColorFromUserDefaults(userDefaultsSuffix: longPeriodColorUserDefaultsSuffix)
//    }
//    
//    private static var persistentElementColorOverrideSettingState: ElementColorOverrideSettingState {
//        get {
//            // Get from userDeafults, using auto as default if either the string is nil or ElementColorOverrideSettingState is nil
//            ElementColorOverrideSettingState(rawValue: UserDefaults.standard.string(forKey: Constants.UserDefaults.elementColorOverrideSettingState) ?? ElementColorOverrideSettingState.auto.rawValue) ?? ElementColorOverrideSettingState.auto
//        }
//        set {
//            // Set userDefaults with rawValue of newValue
//            UserDefaults.standard.set(newValue.rawValue, forKey: Constants.UserDefaults.elementColorOverrideSettingState)
//        }
//    }
//    
//    private static let autoElementColorUserDefaultsSuffix = "AutoElementColor"
//    private static let totalColorUserDefaultsSuffix = ""
//    private static let mostRecentColorUserDefaultsSuffix = "MostRecent"
//    private static let shortPeriodColorUserDefaultsSuffix = "ShortPeriod"
//    private static let mediumPeriodColorUserDefaultsSuffix = "MediumPeriod"
//    private static let longPeriodColorUserDefaultsSuffix = "LongPeriod"
//    
//    private static let mostRecentDrinksAgo = 1
//    private static let shortPeriodDrinksAgo = 3
//    private static let mediumPeriodDrinksAgo = 7
//    private static let longPeriodDrinksAgo = 14
//    
//    private static let elementColors = (
//        mostlyRed: Color(Constants.Color.mostlyRed),
//        mostlyGreen: Color(Constants.Color.mostlyGreen),
//        mostlyBlue: Color(Constants.Color.mostlyBlue)
//    )
//    
//    enum ElementColorOverrideSettingState: String, CaseIterable {
//        case auto
//        case red
//        case green
//        case blue
//    }
//    
//    private var totalCount: Float {
//        UserDefaults.standard.float(forKey: Constants.UserDefaults.totalColorValues)
//    }
//    
//    private var totalRed: Float {
//        UserDefaults.standard.float(forKey: Constants.UserDefaults.totalRedValues)
//    }
//    
//    private var totalGreen: Float {
//        UserDefaults.standard.float(forKey: Constants.UserDefaults.totalGreenValues)
//    }
//    
//    private var totalBlue: Float {
//        UserDefaults.standard.float(forKey: Constants.UserDefaults.totalBlueValues)
//    }
//    
//    init() {
//        elementColor = ColorUpdater.persistentElementColor
//        totalColor = ColorUpdater.persistentTotalColor
//        mostRecentColor = ColorUpdater.persistentMostRecentColor
//        shortPeriodColor = ColorUpdater.persistentShortPeriodColor
//        mediumPeriodColor = ColorUpdater.persistentMediumPeriodColor
//        longPeriodColor = ColorUpdater.persistentLongPeriodColor
//    }
//    
//    func update() async throws {
//        var totalCount: Int = 0
//        var totalRed: Float = 0
//        var totalGreen: Float = 0
//        var totalBlue: Float = 0
//        var periodCount: Int = 0
//        var periodRed: Float = 0
//        var periodGreen: Float = 0
//        var periodBlue: Float = 0
//        
//        let fetchRequest = GlassGradientColor.fetchRequest()
//        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \GlassGradientColor.drink?.updateDate, ascending: false)]
//        fetchRequest.predicate = NSPredicate(format: "%K = %d", #keyPath(GlassGradientColor.drink.saved), true)
//        
//        let fetchResults = try CDClient.mainManagedObjectContext.fetch(fetchRequest)
//        
//        for gradientColor in fetchResults {
//            
//            if let hexadecimal = gradientColor.hexadecimal, let color = Color(hex: hexadecimal), let components = color.cgColor?.components, components.count > 3 {
//                totalCount += 1
//                totalRed += Float(components[0])
//                totalGreen += Float(components[1])
//                totalBlue += Float(components[2])
//                
//                periodCount += 1
//                periodRed += Float(components[0])
//                periodGreen += Float(components[1])
//                periodBlue += Float(components[2])
//            }
//            
//            func resetPeriods() {
////                periodCount = 0
////                periodRed = 0
////                periodGreen = 0
////                periodBlue = 0
//            }
//            
//            if totalCount <= ColorUpdater.longPeriodDrinksAgo {
//                if totalCount <= ColorUpdater.mediumPeriodDrinksAgo {
//                    if totalCount <= ColorUpdater.shortPeriodDrinksAgo {
//                        if totalCount <= ColorUpdater.mostRecentDrinksAgo {
//                            ColorUpdater.saveColorsToUserDefaults(count: periodCount, red: periodRed, green: periodGreen, blue: periodBlue, suffix: ColorUpdater.mostRecentColorUserDefaultsSuffix)
//                            
//                            DispatchQueue.main.async {
//                                self.mostRecentColor = ColorUpdater.persistentMostRecentColor
//                            }
//                        }
//                        
//                        ColorUpdater.saveColorsToUserDefaults(count: periodCount, red: periodRed, green: periodGreen, blue: periodBlue, suffix: ColorUpdater.shortPeriodColorUserDefaultsSuffix)
//                        
//                        DispatchQueue.main.async {
//                            self.shortPeriodColor = ColorUpdater.persistentShortPeriodColor
//                        }
//                    }
//                    
//                    ColorUpdater.saveColorsToUserDefaults(count: periodCount, red: periodRed, green: periodGreen, blue: periodBlue, suffix: ColorUpdater.mediumPeriodColorUserDefaultsSuffix)
//                    
//                    DispatchQueue.main.async {
//                        self.mediumPeriodColor = ColorUpdater.persistentMediumPeriodColor
//                    }
//                }
//                
//                ColorUpdater.saveColorsToUserDefaults(count: periodCount, red: periodRed, green: periodGreen, blue: periodBlue, suffix: ColorUpdater.longPeriodColorUserDefaultsSuffix)
//                
//                DispatchQueue.main.async {
//                    self.longPeriodColor = ColorUpdater.persistentLongPeriodColor
//                }
//            }
//            
////            switch totalCount {
////            case mostRecentDrinksAgo:
////                saveColorsToUserDefaults(count: periodCount, red: periodRed, green: periodGreen, blue: periodBlue, suffix: mostRecentColorUserDefaultsSuffix)
////                resetPeriods()
////            case shortPeriodDrinksAgo:
////                saveColorsToUserDefaults(count: periodCount, red: periodRed, green: periodGreen, blue: periodBlue, suffix: shortPeriodColorUserDefaultsSuffix)
////                resetPeriods()
////            case mediumPeriodDrinksAgo:
////                saveColorsToUserDefaults(count: periodCount, red: periodRed, green: periodGreen, blue: periodBlue, suffix: mediumPeriodColorUserDefaultsSuffix)
////                resetPeriods()
////            case longPeriodDrinksAgo:
////                saveColorsToUserDefaults(count: periodCount, red: periodRed, green: periodGreen, blue: periodBlue, suffix: longPeriodColorUserDefaultsSuffix)
////                resetPeriods()
////            default:
////                continue
////            }
//        }
//        
//        ColorUpdater.saveColorsToUserDefaults(count: totalCount, red: totalRed, green: totalGreen, blue: totalBlue, suffix: ColorUpdater.totalColorUserDefaultsSuffix)
//        
//        DispatchQueue.main.async {
//            self.totalColor = ColorUpdater.persistentTotalColor
//        }
//        
//        // Save auto element color
//        ColorUpdater.parseSaveElementColor(red: totalRed, green: totalGreen, blue: totalBlue, suffix: ColorUpdater.autoElementColorUserDefaultsSuffix)
//        
//        print("about to update element color")
//        print(totalRed)
//        print(totalGreen)
//        print(totalBlue)
//        
//        // Update element color
//        updateElementColor()
//    }
//    
//    private static func getCount(userDefaultsSuffix: String) -> Int {
//        UserDefaults.standard.integer(forKey: Constants.UserDefaults.totalColorValues + userDefaultsSuffix)
//    }
//    
//    private static func getTotalRed(userDefaultsSuffix: String) -> Float {
//        UserDefaults.standard.float(forKey: Constants.UserDefaults.totalRedValues + userDefaultsSuffix)
//    }
//    
//    private static func getTotalGreen(userDefaultsSuffix: String) -> Float {
//        UserDefaults.standard.float(forKey: Constants.UserDefaults.totalGreenValues + userDefaultsSuffix)
//    }
//    
//    private static func getTotalBlue(userDefaultsSuffix: String) -> Float {
//        UserDefaults.standard.float(forKey: Constants.UserDefaults.totalBlueValues + userDefaultsSuffix)
//    }
//    
//    private static func getAveragedRed(userDefaultsSuffix: String) -> Float {
//        ColorUpdater.getTotalRed(userDefaultsSuffix: userDefaultsSuffix) / Float(ColorUpdater.getCount(userDefaultsSuffix: userDefaultsSuffix))
//    }
//    
//    private static func getAveragedGreen(userDefaultsSuffix: String) -> Float {
//        ColorUpdater.getTotalGreen(userDefaultsSuffix: userDefaultsSuffix) / Float(ColorUpdater.getCount(userDefaultsSuffix: userDefaultsSuffix))
//    }
//    
//    private static func getAveragedBlue(userDefaultsSuffix: String) -> Float {
//        ColorUpdater.getTotalBlue(userDefaultsSuffix: userDefaultsSuffix) / Float(ColorUpdater.getCount(userDefaultsSuffix: userDefaultsSuffix))
//    }
//    
//    private static func getColorFromUserDefaults(userDefaultsSuffix: String) -> Color {
//        Color(cgColor: CGColor(
//            red: CGFloat(ColorUpdater.getAveragedRed(userDefaultsSuffix: userDefaultsSuffix)),
//            green: CGFloat(ColorUpdater.getAveragedGreen(userDefaultsSuffix: userDefaultsSuffix)),
//            blue: CGFloat(ColorUpdater.getAveragedBlue(userDefaultsSuffix: userDefaultsSuffix)),
//            alpha: 1.0))
//    }
//    
//    private static func saveColorsToUserDefaults(count: Int, red: Float, green: Float, blue: Float, suffix: String) {
//        UserDefaults.standard.set(count, forKey: Constants.UserDefaults.totalColorValues + suffix)
//        UserDefaults.standard.set(red, forKey: Constants.UserDefaults.totalRedValues + suffix)
//        UserDefaults.standard.set(green, forKey: Constants.UserDefaults.totalGreenValues + suffix)
//        UserDefaults.standard.set(blue, forKey: Constants.UserDefaults.totalBlueValues + suffix)
//    }
//    
//    private static func parseSaveElementColor(red: Float, green: Float, blue: Float, suffix: String) {
//        // Update the element color based on the highest color value in the view, mostlyBlue for mostly blue and so on
//        if blue > green && blue > red {
//            saveColor(color: ColorUpdater.elementColors.mostlyBlue, suffix: suffix)
//        } else if green > red && green > blue {
//            saveColor(color: ColorUpdater.elementColors.mostlyGreen, suffix: suffix)
//        } else if red > blue && red > green {
//            saveColor(color: ColorUpdater.elementColors.mostlyRed, suffix: suffix)
//        } else {
//            saveColor(color: .orange, suffix: suffix)
//        }
//    }
//    
//    private static func saveColor(color: Color, suffix: String) {
//        // Save to User Defaults
//        if let components = UIColor(color).cgColor.components, components.count >= 3 {
//            let red = components[0]
//            let green = components[1]
//            let blue = components[2]
//            
//            self.saveColorsToUserDefaults(
//                count: 1,
//                red: Float(red),
//                green: Float(green),
//                blue: Float(blue),
//                suffix: ColorUpdater.autoElementColorUserDefaultsSuffix)
//            
//            print("Here")
//            print(red)
//            print(green)
//            print(blue)
//        }
//    }
//    
//    private func updateElementColor() {
//        DispatchQueue.main.async {
//            self.elementColor = ColorUpdater.persistentElementColor
//            
//            print("what")
//            print("e0: \(String(describing: self.elementColor.cgColor?.components![0]))")
//            print("e1: \(String(describing: self.elementColor.cgColor?.components![1]))")
//            print("e2: \(String(describing: self.elementColor.cgColor?.components![2]))")
//            
////            let appearance = UINavigationBarAppearance()
////            appearance.backgroundColor = UIColor(self.elementColor)
////            
////            UINavigationBar.appearance().standardAppearance = appearance
////            UINavigationBar.appearance().scrollEdgeAppearance = appearance
//        }
//    }
//    
//}
