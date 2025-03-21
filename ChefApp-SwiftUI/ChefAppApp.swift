//
//  ChefAppApp.swift
//  Barback
//
//  Created by Alex Coundouriotis on 9/16/23.
//

import GoogleMobileAds
import PDFKit
import SwiftUI

@main
struct ChefAppApp: App {
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.requestReview) private var requestReview
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    @StateObject private var constantsUpdater = ConstantsUpdater()
    @StateObject private var premiumUpdater = PremiumUpdater()
    @StateObject private var productUpdater = ProductUpdater()
    @StateObject private var remainingUpdater = RemainingUpdater()
    @StateObject private var screenIdleTimerUpdater = ScreenIdleTimerUpdater()
    @StateObject private var sharedDataReceiver = SharedDataReceiver()
    @StateObject private var cacheTikTokSourceRecipeGenerator = TikTokSourceRecipeGenerator()
    @StateObject private var tikTokSourceRecipeGenerator = TikTokSourceRecipeGenerator()
    
    private var cacheTikTokSource_recipeGenerator = RecipeGenerator()
    private var openURL_recipeGenerator = RecipeGenerator()
    private var tikTokSource_recipeGenerator = RecipeGenerator()
    
    @StateObject private var mainViewModel = MainViewModel()
    
    @State private var isShowingIntroView: Bool
    @State private var isShowingUltraView: Bool = false
//    @State private var openURL_presentingRecipe: Recipe?
    @State private var openURL_presentingRecipeViewModel: RecipeViewModel?
//    @State private var openURL_recipeGenerationListViewModel: RecipeGenerationListViewModel?
    
//    @State private var tikTokSource_presentingRecipe: Recipe?
    @State private var tikTokSource_presentingRecipeViewModel: RecipeViewModel?
    
    @State private var alertShowingErrorImportingTikTokRecipe: Bool = false
    
    @State private var isLoadingSharedDataViewModelBuilder: Bool = false
    
    
//    @State private var openURL_isLoadingExtensionAttachment: Bool = false
    
    
    init() {
//        UIView.appearance().tintColor = UIColor(Colors.elementBackground)
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(Colors.elementBackground)
        
        // Start Google Mobile Ads shared instance
        GADMobileAds.sharedInstance().start()
        
        // Ensure AuthHelper to get authToken TODO: Is this a good place to do this?
        Task {
            do {
                try await AuthHelper.ensure()
            } catch {
                // TODO: Handle errors
                print("Error ensuring authToken with AuthHelper in body in BarbackApp... \(error)")
            }
        }
        
        // Set initial variables
        _isShowingIntroView = State(initialValue: !IntroManager.isIntroComplete)
        
        // Start IAPManager transaction observer
        IAPManager()
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if isShowingIntroView {
                    // Intro
                    IntroPresenterView(
                        isShowing: $isShowingIntroView)
                } else {
                    // Main
                    NavigationStack {
                        MainView(
                            viewModel: mainViewModel,
                            loadingTikTokRecipeProgress: {
                            if let tikTokRecipeGeneratorProgress = tikTokSourceRecipeGenerator.loadingProgress {
                                // If tikTokSourceRecipeGenerator loadingProgress can be unwrapped use it first
                                return tikTokRecipeGeneratorProgress
                            } else if let cacheTikTokRecipeGeneratorProgress = cacheTikTokSourceRecipeGenerator.loadingProgress {
                                // If cacheTikTokSourceRecipeGenerator loadingProgress can be unwrapped use it
                                return cacheTikTokRecipeGeneratorProgress
                            }
                            return nil
                        }())
                    }
                }
            }
            .tint(Colors.elementBackground)
            // Ultra view popup
            .ultraViewPopover(isPresented: $isShowingUltraView)
            // Loading attachment view
            .clearFullScreenCover(isPresented: $isLoadingSharedDataViewModelBuilder) {
                // Is Loading Extension Attachment View
                ZStack {
                    Colors.foreground
                        .opacity(0.6)
                    VStack {
                        Text("Loading Attachment")
                        ProgressView()
                    }
                }
                .ignoresSafeArea()
            }
//            // Handle full-screen cover for recipe generation view
//            .fullScreenCover(item: $openURL_recipeGenerationListViewModel) { recipeGenerationListViewModel in
//                RecipeGenerationListView(
//                    viewModel: recipeGenerationListViewModel,
////                    recipeGenerator: openURL_recipeGenerator, // TODO: Ensure removing this does not mess with expected interface
//                    onDismiss: { openURL_recipeGenerationListViewModel = nil },
//                    didSaveRecipe: { _ in
//                        // Dismiss recipe generation view and entry view, set presenting panel to nil, and reset fields and selected items
//                        openURL_recipeGenerationListViewModel = nil
//                    }
//                )
//                .background(Colors.background)
//            }
            // Open URL presenting Recipe
            .recipePopup(
                recipeViewModel: $openURL_presentingRecipeViewModel)
            // TikTok Source presenting Recipe
            .recipePopup(
                recipeViewModel: $tikTokSource_presentingRecipeViewModel)
            // Error generating TikTok recipe alert
            .alert("Error Importing", isPresented: $alertShowingErrorImportingTikTokRecipe, actions: {
                Button("Close") {}
            }) {
                Text("TikTok recipe could not be imported. Will try again next launch.")
            }
            .onOpenURL(perform: { url in
                if url.absoluteString == "chefapp://sharedata" {
                    sharedDataReceiver.checkForAndGetSharedData()
                }
            })
            .onReceive(sharedDataReceiver.$sharedData) { newValue in
                if let newValue {
                    Task {
                        // If SharedData is received with url, determine if TikTok URL or not
                        if let urlString = newValue.url,
                           let url = URL(string: urlString) {
                            let urlType = SharedDataURLType.from(url: url)
                            if urlType == .tikTok {
                                do {
                                    let recipe = try await tikTokSourceRecipeGenerator.generate(
                                        tikTokUrl: url,
                                        recipeGenerator: tikTokSource_recipeGenerator,
                                        in: CDClient.mainManagedObjectContext)
                                    // Dismiss UltraView TODO: Implement or determine if it should be
                                    isShowingUltraView = false
                                    
                                    // If recipe can be unwrapped set presentingRecipe to recipe and return
                                    tikTokSource_presentingRecipeViewModel = RecipeViewModel(recipe: recipe)
                                    return
                                } catch TikTokSourceRecipeGeneratorError.invalidPlayAddr, TikTokSourceRecipeGeneratorError.missingPlayAddr, TikTokSourceRecipeGeneratorError.missingCookie, TikTokSourceRecipeGeneratorError.invalidTranscription {
                                    // If there was an issue generating relating to the TikApi resposne cache the TikTok url for later processing and show alert
                                    let cachedTikTokUrls: [String] = constantsUpdater.cachedTikTokUrlsCSV.split(separator: ",").map({ String($0) }) + [urlString]
                                    constantsUpdater.cachedTikTokUrlsCSV = cachedTikTokUrls.joined(separator: ",")
                                    
                                    alertShowingErrorImportingTikTokRecipe = true
                                    return
                                } catch {
                                    // TODO: Handle Errors if Necessary
                                    print("Error generating Recipe in ChefAppApp, continuing... \(error)")
                                }
                            }
                        }
                        
                        // Otherwise, build recipe generation spec
                        await MainActor.run { isLoadingSharedDataViewModelBuilder = true }
                        do {
                            try await SharedDataRecipeGenerationSpecBuilder.buildRecipeGenerationSpec(from: newValue)
                        } catch {
                            // TODO: Show alert
                            print("Error building recipe generation spec in ChefAppApp... \(error)")
                        }
                        await MainActor.run { isLoadingSharedDataViewModelBuilder = false }
                    }
                }
            }
            .task(priority: .background) {
                // Check cached TikTok URLs and process if not empty
                var cachedTikTokUrlStrings = constantsUpdater.cachedTikTokUrlsCSV.split(separator: "<<")
                
                // Process cached TikTok URL strings
                for cachedTikTokUrlString in cachedTikTokUrlStrings {
                    if let cachedTikTokUrl = URL(string: String(cachedTikTokUrlString)) {
                        do {
                            // Generate recipe
                            try await cacheTikTokSourceRecipeGenerator.generate(
                                tikTokUrl: cachedTikTokUrl,
                                recipeGenerator: cacheTikTokSource_recipeGenerator,
                                in: CDClient.mainManagedObjectContext)
                            
                            // If successfully generated, remove from cachedTikTokUrlStrings TODO: Ensure this logic is works correctly and does not mess up the for loop
                            cachedTikTokUrlStrings.removeAll(where: {$0 == cachedTikTokUrlString})
                        } catch TikTokSourceRecipeGeneratorError.missingCookie {
                            // If cookie is missing continue to keep recipe
                            print("Error generating Recipe in ChefAppApp because of missing cookie, keeping and continuing!")
                        } catch {
                            // TODO: Handle Errors
                            print("Error generating Recipe in ChefAppApp, continuing... \(error)")
                            
                            // If unsuccessfully generated, remove from cachedTikTokUrlStrings TODO: Ensure the video is not thrown out if TikAPI is just having issues
                            cachedTikTokUrlStrings.removeAll(where: {$0 == cachedTikTokUrlString})
                        }
                    }
                }
                
                // Set constantsUpdater cachedTikTokUrlsCSV to updated cachedTikTokUrlStrings
                constantsUpdater.cachedTikTokUrlsCSV = cachedTikTokUrlStrings.joined(separator: ",")
            }
            .task(priority: .background) {
                // Perform migration
                await MigrationAssistant.migrateCoreDataImagesToAppGroupSaveLocations(in: CDClient.mainManagedObjectContext)
            }
            .task {
                // Update constants
                do {
                    try await constantsUpdater.update()
                } catch {
                    print("Error updating constants in ChefAppApp... \(error)")
                }
                
                // Increment launchCount
                await MainActor.run {
                    constantsUpdater.launchCount += 1
                }
            }
            .task {
                // Ensure authToken
                let authToken: String
                do {
                    authToken = try await AuthHelper.ensure()
                } catch {
                    print("Error ensuring authToken in ChefAppApp, regenerating... \(error)")
                    
                    do {
                        try await AuthHelper.regenerate()
                    } catch {
                        // TODO: Handle Errors
                        print("Error regenerating authToken in ChefAppApp... \(error)")
                    }
                    
                    do {
                        authToken = try await AuthHelper.ensure()
                    } catch {
                        // TODO: Handle Errors
                        print("Error ensuring authToken after regenerating in ChefAppApp... \(error)")
                        return
                    }
                }
                
                // Update premium
                do {
                    try await premiumUpdater.update(authToken: authToken)
                } catch {
                    // TODO: Handle Errors
                    print("Error updating premium in ChefAppApp... \(error)")
                }
                
                // Update remaining
                do {
                    try await remainingUpdater.update(authToken: authToken)
                } catch {
                    // TODO: Handle Errors
                    print("Error updating remaining in ChefAppApp... \(error)")
                }
                
                // Show ultra view if necessary and intro is not showing
                if !premiumUpdater.isPremium && !isShowingIntroView {
                    isShowingUltraView = true
                }
            }
            .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
            .environmentObject(constantsUpdater)
            .environmentObject(premiumUpdater)
            .environmentObject(productUpdater)
            .environmentObject(remainingUpdater)
            .environmentObject(screenIdleTimerUpdater)
        }
    }
    
    
    
}
