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
    
    @Published var isDisplayingEntryPromptCard = true
    @Published var isDisplayingHeader = true
    
    @Published var isShowingEasyPantryUpdateContainer: Bool = false
    
    @Published var isShowingPanelView: Bool = false
    @Published var canPresentPanel: Bool = true
    
    @Published var presentingAddToPantryDirectlyToCameraPopupViewModel: AddToPantryViewModel?
    @Published var presentingAddToPantryPopupViewModel: AddToPantryViewModel?
    @Published var presentingPantryViewModel: PantryViewModel?
    @Published var presentingRecipeSaveGenerationSwipeViewModel: RecipeSaveGenerationSwipeViewModel?
    @Published var presentingRecipeViewModel: RecipeViewModel?
    
    @Published var isShowingSettingsView: Bool = false
    @Published var isShowingUltraView: Bool = false
    
    @Published var recipeGenerationViewModel: RecipeGenerationViewModel = RecipeGenerationViewModel(
        pantryItems: [],
        suggestions: [],
        input: "",
        generationAdditionalOptions: .normal) // Shows RecipeGenerationView if filled
    
    var recipeGenerator = RecipeGenerator()
    
    var shouldShowSheetCraftText: Bool {
        true
    }
    
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
    
    @ObservedObject var viewModel: MainViewModel
    @StateObject var recipeGenerator: RecipeGenerator = RecipeGenerator()
    @StateObject var recipeBingImageGenerator: RecipeBingImageGenerator = RecipeBingImageGenerator()
    
    let loadingTikTokRecipeProgress: TikTokSourceRecipeGenerator.LoadingProgress? // TODO: Implement better initialization or put in ViewModel
    
    
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
                    
                    RecipeOfTheDayContainer(
                        onSelect: { viewModel.presentingRecipeViewModel = RecipeViewModel(recipe: $0) },
                        onOpenAddToPantry: { viewModel.presentingAddToPantryPopupViewModel = AddToPantryViewModel() })
                    .padding(.vertical)
                    
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
                    HStack {
                        Text("Recipes")
                            .font(.custom(Constants.FontName.heavy, size: 20.0))
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                    RecipesView(onSelect: { viewModel.presentingRecipeViewModel = RecipeViewModel(recipe: $0) })
                        .sheet(item: $viewModel.presentingRecipeViewModel) { recipeViewModel in
                            RecipeView(
                                viewModel: recipeViewModel,
                                onDismiss: { viewModel.presentingRecipeViewModel = nil }
                            )
                            .background(Colors.background)
                            .presentationCompactAdaptation(.fullScreenCover)
                        }
                    Spacer(minLength: 214.0)
                }
            }
            .background(Colors.background)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
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
            LogoToolbarItem(foregroundColor: Colors.elementBackground)
            if !premiumUpdater.isPremium {
                UltraToolbarItem(color: Colors.elementBackground)
            }
        }
        .toolbar(viewModel.isDisplayingHeader ? .visible : .hidden)
        .toolbarBackground(Colors.background, for: .navigationBar)
        .navigationDestination(isPresented: $viewModel.isShowingSettingsView) {
            SettingsView(
                premiumUpdater: premiumUpdater,
                isShowing: $viewModel.isShowingSettingsView
            )
        }
        .safeAreaInset(edge: .bottom) {
            Button(action: {
                // Do light haptic
                HapticHelper.doLightHaptic()
                
                // Show entry view
                withAnimation {
                    // TODO: Make sure to test this !!! This is important I'm making some changes now.. need to construct those
                    // TODO: It should just work correctly. Figure out what this button is specifically, pretty sure it's the recipe start gen button, and make sure that it works optimally
                    viewModel.presentingRecipeSaveGenerationSwipeViewModel = RecipeSaveGenerationSwipeViewModel(
                        recipeGenerationSwipeViewModel: RecipeGenerationSwipeViewModel(
                            pantryItems: [],
                            suggestions: [],
                            input: "",
                            generationAdditionalOptions: .normal))
                }
            }) {
                ZStack {
                    Spacer()
                    Text("Create Recipe")
                        .font(.custom("copperplate-bold", size: 24.0))
                        .foregroundStyle(Colors.elementText)
                    
                    HStack {
                        Spacer()
                        
                        Text(recipeGenerator.isCreating ? "" : "\(Image(systemName: "arrow.right"))")
                            .font(.custom("copperplate-bold", size: 17.0))
                            .foregroundStyle(Colors.elementText)
                        
                        if recipeGenerator.isCreating {
                            ProgressView()
                                .tint(Colors.elementText)
                        }
                    }
                    Spacer()
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 14.0)
                    .fill(Colors.elementBackground))
            .clipShape(RoundedRectangle(cornerRadius: 20.0))
            .bounceable()
            .padding()
            .background(Material.regular)
        }
        .background(Colors.background)
        // Add to pantry popup
        .addToPantryPopup(viewModel: $viewModel.presentingAddToPantryDirectlyToCameraPopupViewModel, showCameraOnAppear: true)
        .addToPantryPopup(viewModel: $viewModel.presentingAddToPantryPopupViewModel, showCameraOnAppear: false)
        // EasyPantryUpdateContainer popup
        .easyPantryUpdatePopup(isPresented: $viewModel.isShowingEasyPantryUpdateContainer)
        // Sheet for all pantry items view
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
        // Create recipe swipe cards
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

