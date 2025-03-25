//
//  MainView.swift
//  Barback
//
//  Created by Alex Coundouriotis on 9/16/23.
//

import SwiftUI
import CoreData
import Combine

class MainViewModel: ObservableObject {
    
    /// Controls visibility of the entry prompt card
    @Published var isDisplayingEntryPromptCard = true
    
    /// Controls visibility of the navigation header
    @Published var isDisplayingHeader = true
    
    /// Tracks if the easy pantry update container should be shown
    @Published var isShowingEasyPantryUpdateContainer: Bool = false
    
    /// Controls visibility of the panel view
    @Published var isShowingPanelView: Bool = false
    
    /// Determines if panel presentation is allowed
    @Published var canPresentPanel: Bool = true
    
    /// ViewModel for camera-first pantry addition flow
    @Published var presentingAddToPantryDirectlyToCameraPopupViewModel: AddToPantryViewModel?
    
    /// ViewModel for standard pantry addition flow
    @Published var presentingAddToPantryPopupViewModel: AddToPantryViewModel?
    
    /// ViewModel for full pantry management view
    @Published var presentingPantryViewModel: PantryViewModel?
    
    /// ViewModel for recipe generation swipe interface
    @Published var presentingRecipeSaveGenerationSwipeViewModel: RecipeSaveGenerationSwipeViewModel?
    
    /// ViewModel for detailed recipe view
    @Published var presentingRecipeViewModel: RecipeViewModel?
    
    /// Controls settings view visibility
    @Published var isShowingSettingsView: Bool = false
    
    /// Controls premium features view visibility
    @Published var isShowingUltraView: Bool = false
    
    /// Handles recipe generation state and logic
    @Published var recipeGenerationViewModel: RecipeGenerationViewModel = RecipeGenerationViewModel(
        pantryItems: [],
        suggestions: [],
        input: "",
        generationAdditionalOptions: .normal)
    
    var recipeGenerator = RecipeGenerator()
    
    /// Determines if sheet craft text should be displayed
    var shouldShowSheetCraftText: Bool {
        true
    }
    
    /// Handles deep link URLs for recipe sharing
    /// - Parameters:
    ///   - url: The incoming URL to process
    ///   - recipeGenerator: Recipe generation service
    ///   - recipeBingImageGenerator: Image generation service
    ///   - managedContext: Core Data context
    func handleOnOpenURL(
        url: URL,
        recipeGenerator: RecipeGenerator,
        recipeBingImageGenerator: RecipeBingImageGenerator,
        in managedContext: NSManagedObjectContext
    ) {
        if url.host == "recipe" || (url.host == "chitchatserver.com" && url.pathComponents[safe: 1] == "chefappdeeplink" && url.pathComponents[safe: 2] == "recipe") {
            let recipeIDString = url.lastPathComponent
            guard let recipeID = Int(recipeIDString) else {
                // TODO: Handle Errors
                print("Could not unwrap recipeID in MainContainer!")
                return
            }
            
            Task {
                // Ensure authToken
                let authToken: String
                do {
                    authToken = try await AuthHelper.ensure()
                } catch {
                    // TODO: Handle Errors
                    print("Error ensuring authToken in MainContainer... \(error)")
                    return
                }
                
                // Get recipe
                do {
                    let _ = try await ChefAppNetworkPersistenceManager.shared.getAndDuplicateAndSaveRecipe(
                        authToken: authToken,
                        recipeID: recipeID,
                        recipeGenerator: recipeGenerator,
                        recipeBingImageGenerator: recipeBingImageGenerator,
                        in: managedContext)
                } catch {
                    // TODO: Handle Errors
                    print("Error getting and duplicating and saving recipe in MainContainer... \(error)")
                }
            }
        }
    }
    
}

struct MainView: View {
    
    // Initialization Variables
    
    @ObservedObject var viewModel: MainViewModel
    @StateObject var recipeGenerator: RecipeGenerator = RecipeGenerator()
    @StateObject var recipeBingImageGenerator: RecipeBingImageGenerator = RecipeBingImageGenerator()
    let loadingTikTokRecipeProgress: TikTokSourceRecipeGenerator.LoadingProgress?
    
    // Instance Variables
    
    @Environment(\.managedObjectContext) private var viewContext
    @Namespace private var panelNamespace
    
    @EnvironmentObject private var constantsUpdater: ConstantsUpdater
    @EnvironmentObject private var premiumUpdater: PremiumUpdater
    @EnvironmentObject private var productUpdater: ProductUpdater
    @EnvironmentObject private var remainingUpdater: RemainingUpdater
    
    // Fetch requests for pantry items and recipes
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \PantryItem.updateDate, ascending: false)],
        animation: .default
    ) private var pantryItems: FetchedResults<PantryItem>
    
    // State objects and variables for various functionalities
    @StateObject private var keyboardResponder = KeyboardResponder()
    
    
    var body: some View {
        ZStack {
            let _ = Self._printChanges()
            ScrollView(.vertical) {
                VStack(spacing: 0.0) {
                    // Is Loading TikTok Source Recipe Insert
                    if let loadingTikTokRecipeProgress {
                        LoadingTikTokRecipeView(progress: loadingTikTokRecipeProgress)
                    }
                    
                    // Recipe of The Day Swipe View
                    RecipeOfTheDaySwipeView(
                        onSelect: { viewModel.presentingRecipeViewModel = RecipeViewModel(recipe: $0) },
                        onOpenAddToPantry: { viewModel.presentingAddToPantryPopupViewModel = AddToPantryViewModel() })
                    .padding(.vertical)
                    
                    // Pantry Controls
                    MainPantryControls(
                        showAddPantryItemDirectlyToCameraPopup: {
                            withAnimation {
                                viewModel.presentingAddToPantryDirectlyToCameraPopupViewModel = AddToPantryViewModel()
                            }
                        },
                        showPantry: {
                            withAnimation {
                                viewModel.presentingPantryViewModel = PantryViewModel()
                            }
                        }
                    )
                    .padding([.leading, .trailing])
                    
                    // Easy Pantry Update Button
                    // - only shows when updateDate is in the past
                    if pantryItems.contains(where: {
                        if let updateDate = $0.updateDate {
                            return updateDate <= Calendar.current.date(byAdding: .day, value: -constantsUpdater.easyPantryUpdateContainerOlderThanDays, to: Date())!
                        }
                        
                        return false
                    }) {
                        MainEasyPantryUpdateButton(
                            showEasyPantryUpdateContainer: {
                                viewModel.isShowingEasyPantryUpdateContainer.toggle()
                            }
                        )
                    }
                    
                    Spacer(minLength: 24.0)
                    
                    // Recipes List
                    HStack {
                        Text("Recipes")
                            .font(.custom(Constants.FontName.heavy, size: 20.0))
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                    
                    // Recipes View
                    RecipesView(
                        onSelect: { viewModel.presentingRecipeViewModel = RecipeViewModel(recipe: $0) })
                    
                    Spacer(minLength: 214.0)
                }
            }
            .background(Colors.background)
        }
        .background(Colors.background)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // Settings Button
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    HapticHelper.doLightHaptic()
                    
                    viewModel.isShowingSettingsView = true
                }) {
                    Image(systemName: "gear")
                        .font(.custom(Constants.FontName.heavy, size: 17.0))
                        .foregroundStyle(Colors.elementBackground)
                }
            }
            
            // Logo
            LogoToolbarItem(foregroundColor: Colors.elementBackground)
            
            // Premium Button
            if !premiumUpdater.isPremium {
                UltraToolbarItem(color: Colors.elementBackground)
            }
        }
        .toolbar(viewModel.isDisplayingHeader ? .visible : .hidden)
        .toolbarBackground(Colors.background, for: .navigationBar)
        
        // Settings View
        .navigationDestination(isPresented: $viewModel.isShowingSettingsView) {
            SettingsView(
                premiumUpdater: premiumUpdater,
                isShowing: $viewModel.isShowingSettingsView
            )
        }
        
        // Generate Recipe button
        .safeAreaInset(edge: .bottom) {
            MainGenerateRecipeButton(viewModel: viewModel)
        }
        
        // Add to pantry popup
        .addToPantryPopup(viewModel: $viewModel.presentingAddToPantryDirectlyToCameraPopupViewModel, showCameraOnAppear: true)
        .addToPantryPopup(viewModel: $viewModel.presentingAddToPantryPopupViewModel, showCameraOnAppear: false)
        
        // EasyPantryUpdateContainer popup
        .easyPantryUpdatePopup(isPresented: $viewModel.isShowingEasyPantryUpdateContainer)
        
        // All Pantry Items popup
        .pantryViewPopup(
            pantryViewModel: $viewModel.presentingPantryViewModel,
            onDismiss: {
                viewModel.presentingPantryViewModel = nil
            },
            onCreateRecipe: {
                DispatchQueue.main.async {
                    viewModel.presentingPantryViewModel = nil
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.59) {
                    viewModel.presentingRecipeSaveGenerationSwipeViewModel = RecipeSaveGenerationSwipeViewModel(
                        recipeGenerationSwipeViewModel: RecipeGenerationSwipeViewModel(
                            pantryItems: [],
                            suggestions: [],
                            input: "",
                            generationAdditionalOptions: .normal))
                }
            })
        
        // Recipe View
        .sheet(item: $viewModel.presentingRecipeViewModel) { recipeViewModel in
            RecipeView(
                viewModel: recipeViewModel,
                onDismiss: { viewModel.presentingRecipeViewModel = nil }
            )
            .background(Colors.background)
            .presentationCompactAdaptation(.fullScreenCover)
        }
        
        // Recipe Save Generation Swipe View
        .fullScreenCover(item: $viewModel.presentingRecipeSaveGenerationSwipeViewModel) { recipeSaveGenerationSwipeViewModel in
            NavigationStack {
                RecipeSaveGenerationSwipeView(
                    viewModel: recipeSaveGenerationSwipeViewModel,
                    onClose: {
                        viewModel.presentingRecipeSaveGenerationSwipeViewModel = nil
                    })
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    LogoToolbarItem(foregroundColor: Colors.elementBackground)
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            viewModel.presentingRecipeSaveGenerationSwipeViewModel = nil
                        }) {
                            Text("Close")
                                .font(.heavy, 17)
                                .foregroundStyle(Colors.elementBackground)
                        }
                    }
                }
            }
        }
        
        // Handle onOpenURL
        .onOpenURL(perform: {
            viewModel.handleOnOpenURL(
                url: $0,
                recipeGenerator: recipeGenerator,
                recipeBingImageGenerator: recipeBingImageGenerator,
                in: viewContext)
        })
    }
    
}

#Preview {
    MainView(
        viewModel: MainViewModel(),
        loadingTikTokRecipeProgress: nil
    )
    .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
    .environmentObject(ConstantsUpdater())
    .environmentObject(PremiumUpdater())
    .environmentObject(ProductUpdater())
    .environmentObject(RemainingUpdater())
}
