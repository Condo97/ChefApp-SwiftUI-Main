//
//  Constants.swift
//  Barback
//
//  Created by Alex Coundouriotis on 9/17/23.
//

import Foundation
import SwiftUI

struct Constants {
    
    struct Additional {
        
        static let appGroupID: String = "group.com.acapplications.chefsuite"
        
        static let copyFooterText: String = "Made with ChefApp!"
        
        static let coreDataModelName = "PantryPal"
        
        static let defaultShareURL = "https://apps.apple.com/us/app/chefapp-ai-recipe-creator/id6450523267"
        
        static let defaultTitleText = "Tap to Claim 3 Days Free"
        static let defaultTopLabelText = "ChefApp Ultra hasn't been activated"
        
        static let fallbackWeeklyProductIdentifier = "pantryproultraweekly" // TODO: Get the right one
        static let fallbackMonthlyProductIdentifier = "pantryproultramonthly" // TODO: Get the right one
        
        static let ideaRecipeInterstitialModuloFactor = 2
        
        static let pinterestCheckoutEventName = "checkout"
        static let pinterestCheckoutEventID = "checkout001"
        
        static let reviewFrequency = 2
        
        static let shareIdeaRecipeSuffix = "Made on ChefApp"
        
        private static let supportEmail = "pantryproapp@gmail.com"
        static let supportEmailURL = "mailto:\(supportEmail)"
        
    }
    
    struct File {
        
        static let panelImageDirectory = "panelImages"
        
    }
    
    struct FontName {
        
        private static let oblique = "Oblique"
        
        static let light = "avenir-light"
        static let lightOblique = light + oblique
        static let body = "avenir-book"
        static let bodyOblique = body + oblique
        static let medium = "avenir-medium"
        static let mediumOblique = medium + oblique
        static let heavy = "avenir-heavy"
        static let heavyOblique = heavy + oblique
        static let black = "avenir-black"
        static let blackOblique = black + oblique
        static let appname = "copperplate"
        
        static let damion = "Damion"
        
    }
    
    struct ImageName {
        
        static let cameraButtonNotPressed = "cameraButtonNotPressed"
        static let cameraButtonPressed = "cameraButtonPressed"
        static let cameraButtonPressedCheckmark = "cameraButtonPressedCheckmark"
        static let blurryOverlay = "Blurry Overlay"
        static let navBarLogoImage = "NavBarLogoImage"
        static let sparkleWhiteGif = "sparkleWhiteGif"
        static let ultraButtonImage = "UltraButtonImage"
        static let ultraTitle = "UltraTitle"
        
        
    }
    
    struct Generation {
        
        static let freeAutomaticRecipeGenerationLimit = 2
        static let premiumAutomaticRecipeGenerationLimit = 4
        
    }
    
    struct HTTPSConstants {
        #if DEBUG
            static let chitChatServer = "https://chitchatserver.com:800/v1"
        #else
            static let chitChatServer = "https://chitchatserver.com:800/v1"
        #endif
        
        static let chitChatServerStaticFiles = "https://chitchatserver.com"
        
        static let addOrRemoveLikeOrDislike = "/addOrRemoveLikeOrDislike"
        static let categorizeIngredients = "/categorizeIngredients"
        static let createRecipeIdea = "/createRecipeIdea"
        static let getAllTags = "/getAllTags"
        static let getAndDuplicateRecipe = "/getAndDuplicateRecipe"
        static let getCreatePanels = "/getCreatePanels"
        static let getIAPStuff = "/getIAPStuff"
        static let getIsPremium = "/getIsPremium"
        static let getRecipe = "/getRecipe"
        static let getRemaining = "/getRemaining"
        static let logPinterestConversion = "/logPinterestConversion"
        static let makeRecipeFromIdea = "/makeRecipeFromIdea"
        static let parsePantryItems = "/parsePantryItems"
        static let regenerateRecipeDirectionsAndIdeaRecipeIngredients = "/regenerateRecipeDirectionsAndUpdateMeasuredIngredients"
        static let registerAPNS = "/registerAPNS"
        static let registerTransaction = "/registerTransaction"
        static let registerUser = "/registerUser"
        static let tagRecipeIdea = "/tagRecipeIdea"
        static let tikApiGetVideoInfo = "/tikApiGetVideoInfo"
        static let tikTokSearch = "/tikTokSearch"
        static let transcribeSpeech = "/transcribeSpeech"
        static let updateRecipeImageURL = "/updateRecipeImageURL"
        static let validateAuthToken = "/validateAuthToken"
    //    static let getGenerateImage = "/getImageUrlFromGenerateUrl"

        static let getImportantConstants = "/getImportantConstants"
        static let privacyPolicy = "/privacyPolicy.html"
        static let termsAndConditions = "/termsAndConditions.html"
    }
    
    struct Images {
        static let giftGifName = "giftGif"
        static let ideaRecipeNoImageName = "IdeaRecipeNoImage"
        static let intro1DarkPhoto = "Intro 1 Dark"
        static let intro1LightPhoto = "Intro 1 Light"
        static let navBarLogoImageName = "NavBarLogoImage"
        static let recipeNoImage = "RecipeNoImage"
        static let sheetArrowUpImageName = "SheetArrowUp"
        static let sparkleLightGif = "SparkleLightGif"
        static let sparkleDarkGif = "SparkleDarkGif"
        static let ultraTitle = "UltraTitle"
        
        static let tikTokLogo = "TikTokLogo"
    }
    
    struct UI {
        static let borderWidth = CGFloat(0.0)
        static let cornerRadius = 14.0
    }
    
    struct UserDefaults {
        struct Tutorial {
            static let sheetShown = "tutorialSheetShown"
        }
        
        static let captureCropViewEnabled = "captureCropViewEnabled"
        static let createPanelsJSON = "createPanelsJSON"
        static let hasFinishedIntro = "hasFinishedIntro"
        static let pinterestConversionLoggedOnce = "pinterestConversionLoggedOnce"
        
        static let storedAuthTokenKey = "storedAuthTokenKey"
        static let storedEncodedBingAPIKey = "encodedBingAPIKey"
        static let storedCategorizeIngredientsCount = "categorizeIngredientsCount"
        static let storedFreeIdeaRecipeCap = "freeIdeaRecipeCap"
        static let storedHasFinishedIntro = "hasFinishedIntro"
        static let storedIsPremium = "storedIsPremium"
        static let storedMonthlyProductID = "monthlyProductID"
        static let storedNotFirstLaunchEver = "notFirstLaunchEver"
        static let storedPremiumLastCheckDate = "premiumLastCheckDate"
        static let storedRecipeDirectionsAndIdeaRecipeIngredientsRegenerationsCount = "recipeDirectionsAndIdeaRecipeIngredientsRegenerationsCount"
        static let storedRecipesRemaining = "recipesRemaining"
        static let storedShareURL = "shareURL"
        static let storedWeeklyProductID = "weeklyProductID"
    }
    
    struct Videos {
        static let intro2DarkVideo = ("Intro 2 Dark", "mp4")
        static let intro2LightVideo = ("Intro 2 Light", "mp4")
    }
    
}

struct Colors {
    static let background = Color("BackgroundColor")
    static let bottomBarBackground = Color("BottomBarBackgroundColor")
    static let elementBackground = Color("ElementBackgroundColor")
    static let elementText = Color("ElementTextColor")
    static let foreground = Color("ForegroundColor")
    static let foregroundText = Color("ForegroundTextColor")
    static let ingredientRow = Color("IngredientRowColor")
    static let ingredientToBeDeletedRow = Color("IngredientToBeDeletedRowColor")
    static let navigationItemColor = Color("NavigationItemColor")
    static let secondaryBackground = Color("SecondaryBackgroundColor")
    static let topForegroundPlaceholderText = Color("TopForegroundPlaceholderTextColor")
    static let videoMatchedColor = Color("VideoMatchedColor")
    
    static let alertTint = secondaryBackground
}
