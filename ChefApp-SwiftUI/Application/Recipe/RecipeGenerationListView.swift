//
//  RecipeGenerationListView.swift
//  Barback
//
//  Created by Alex Coundouriotis on 10/3/23.
//

// Generates and lists between 1-2 for free and 3-5 for premium names and summaries, with a button to generate another for premium and some blank "tap to unlock" premium promotional locked name and summary rows

import CoreData
import SwiftUI

class RecipeGenerationListViewModel: RecipeGenerationViewModel {
    
    @Published fileprivate var createdRecipes: [Recipe] = []
    
    @Published fileprivate var lockedRecipePanelsShowing: Int = 0
    
    @Published fileprivate var isLoadingLockedRecipePanels: Bool = false
    
    @Published fileprivate var isDisplayingCapReachedCard: Bool = false
    
    @Published fileprivate var isShowingUltraView: Bool = false
    
    @Published fileprivate var recipeGeneratorCapReached: Bool = false
    
    fileprivate let lockedRecipePanelCount: Int = Int.random(in: 2...5)
    fileprivate let lockedRecipePanelShowDelay: CGFloat = 0.5
    
    fileprivate func getMaxAutoGenerate(premiumUpdater: PremiumUpdater) -> Int {
        premiumUpdater.isPremium ? Constants.Generation.premiumAutomaticRecipeGenerationLimit : Constants.Generation.freeAutomaticRecipeGenerationLimit
    }
    
    fileprivate var parsedInput: String {
        // TODO: Should I add anything else to the input string if selectedPantryItems is not empty?
        // Create parsedInput starting with input
        var parsedInput = input
        
        // If selectedPantryItems is not empty add generationAdditionalOptions additional string and selectedPantryItems separated by commas
        if !pantryItems.isEmpty {
            parsedInput += generationAdditionalOptions == .boostCreativity ? "\nIngredients: " : generationAdditionalOptions == .useOnlyGivenIngredients ? "\nSelect From: " : "\nIngredients: "
            parsedInput += pantryItems.compactMap({$0.name}).joined(separator: ", ") // TODO: Should there be anything else if the name cannot be unwrapped? Since that is the only attribute besides category it's most likely always going to be filled, right, or at least it's expected behaviour to be filled, so it's probably fine to just compactmap filtering with just the name
        }
        
        return parsedInput
    }
    
    fileprivate var parsedInputDifferentThanNewRecipes: String {
        parsedInput + (createdRecipes.count > 0 ? "\nDifferent than: " + createdRecipes.compactMap({$0.name != nil && $0.summary != nil ? "\($0.name!), \($0.summary!)" : nil}).joined(separator: "\nAnd different than: ") : "")
    }
    
    fileprivate var parsedModifiers: String? {
        // Right now if selectedSuggestions is empty nil, otherwise just the selectedSuggestions separated by commas
        suggestions.isEmpty ? nil : suggestions.joined(separator: ", ")
    }
    
}

struct RecipeGenerationListView: View {
    
    @ObservedObject var viewModel: RecipeGenerationListViewModel
    let onDismiss: () -> Void
    let didSaveRecipe: (Recipe) -> Void
    
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject private var premiumUpdater: PremiumUpdater
    
    @StateObject private var recipeGenerator: RecipeGenerator = RecipeGenerator()
    @StateObject private var recipeBingImageGenerator: RecipeBingImageGenerator = RecipeBingImageGenerator()
    
    @State private var presentingRecipeViewModel: RecipeViewModel?
    
    
    var body: some View {
        ZStack {
            VStack(spacing: 0.0) {
                //            header
                
                generatingList
            }
        }
        .chefAppHeader(
            showsDivider: true,
            left: {
                Button(action: {
                    HapticHelper.doLightHaptic()
                    
                    onDismiss()
                }) {
                    Text("Close")
                        .font(.custom(Constants.FontName.heavy, size: 20.0))
                        .foregroundStyle(Colors.elementText)
                        .padding(.leading)
                        .padding(.bottom, 10)
                }
            },
            right: {
                
            })
        .ignoresSafeArea()
        .saveRecipePopup(
            viewModel: $presentingRecipeViewModel,
            didSaveRecipe: { recipe in
                didSaveRecipe(recipe)
            })
        .ultraViewPopover(isPresented: $viewModel.isShowingUltraView)
        .task {
            do {
                // Clear recipeGenerator createdRecipes
                await MainActor.run {
                    viewModel.createdRecipes = []
                }
                
                // Generate next
                try await generateNext()
                
                // Do light haptic
                HapticHelper.doLightHaptic()
                
                // If not premium, show locked recipe panels
                if !premiumUpdater.isPremium {
                    try await showLockedRecipePanels()
                }
            } catch {
                // TODO: Handle errors
                print("Could not generate next recipe in RecipeGenerationView... \(error)")
            }
        }
        .onChange(of: viewModel.isShowingUltraView, perform: { value in
            // If ultra view is dismissed, generateNext in case the user has upgraded to premium
            if !value {
                Task {
                    do {
                        // Generate next if newRecipeIDs is less than maxAutoGenerate, which may happen if the user upgrades to premium and therefore has more recipes that can be generated
                        if viewModel.createdRecipes.count < viewModel.getMaxAutoGenerate(premiumUpdater: premiumUpdater) {
                            // Generate next
                            try await generateNext()
                            
                            // Do light haptic
                            HapticHelper.doLightHaptic()
                        }
                        
                    } catch {
                        // TODO: Handle errors
                        print("Could not generate next recipe in RecipeGenerationView... \(error)")
                    }
                }
            }
        })
        .onChange(of: viewModel.recipeGeneratorCapReached) { newValue in
            if !premiumUpdater.isPremium {
                viewModel.isDisplayingCapReachedCard = newValue
            }
        }
    }
    
    var generatingList: some View {
        ZStack {
            ScrollView {
                // Instructional text at the top
                if !viewModel.isDisplayingCapReachedCard {
                    Text("Tap a preview to finish generating...")
                        .font(.custom(Constants.FontName.bodyOblique, size: 17.0))
                        .padding()
                        .opacity(0.8)
                }
                
                // Cap reached card
                if viewModel.isDisplayingCapReachedCard {
                    CapReachedCard()
                        .padding()
                }
                
                // Recipe Panels
                ForEach(viewModel.createdRecipes) { recipe in
                    if let name = recipe.name {
                        Button(action: {
                            HapticHelper.doLightHaptic()
                            
                            presentingRecipeViewModel = RecipeViewModel(recipe: recipe)
                        }) {
                            VStack {
                                RecipeMiniView(
                                    viewModel: RecipeMiniViewModel(
                                        title: recipe.name ?? "unnamed",
                                        summary: recipe.summary,
                                        image: recipe.imageFromAppData,
                                        date: recipe.updateDate ?? Date.distantPast,
                                        isFromTikTok: recipe.sourceTikTokVideoID != nil))
                                if let ingredients = recipe.measuredIngredients?.allObjects as? [RecipeMeasuredIngredient] {
                                    ScrollView(.horizontal) {
                                        HStack {
                                            ForEach(ingredients) { ingredient in
                                                if let ingredientNameAndAmount = ingredient.nameAndAmount {
                                                    Text(ingredientNameAndAmount) // TODO: Parse out ingredient names
                                                        .font(.custom(Constants.FontName.body, size: 12.0))
                                                        .padding([.leading, .trailing])
                                                        .padding([.top, .bottom], 2)
                                                        .background(Colors.background)
                                                        .clipShape(RoundedRectangle(cornerRadius: 15.0))
                                                        .lineLimit(1)
                                                }
                                            }
                                            
                                            Spacer()
                                        }
                                    }
                                }
                            }
                            .tint(Colors.foregroundText)
                            
                            Text(Image(systemName: "chevron.right"))
                                .font(.custom(Constants.FontName.body, size: 17.0))
                                .foregroundStyle(Colors.foregroundText)
                        }
                        .padding()
                        .background(Colors.foreground)
                        .clipShape(RoundedRectangle(cornerRadius: 28.0))
                        .padding([.leading, .trailing])
                    }
                }
                
                // Premium Locked Panels
                if !premiumUpdater.isPremium {
                    ForEach(0..<viewModel.lockedRecipePanelsShowing, id: \.self) { i in
                        Button(action: {
                            HapticHelper.doLightHaptic()
                            
                            viewModel.isShowingUltraView = true
                        }) {
                            ZStack {
                                HStack {
                                    Spacer()
                                    Text(Image(systemName: "chevron.right"))
                                        .font(.custom(Constants.FontName.body, size: 17.0))
                                        .foregroundStyle(Colors.foregroundText)
                                }
                                
                                VStack {
                                    HStack {
                                        Spacer()
                                        VStack {
                                            Text(Image(systemName: "lock"))
                                                .font(.custom(Constants.FontName.medium, size: 24.0))
                                                .foregroundStyle(Colors.foregroundText)
                                            Text("Tap to Unlock More")
                                                .font(.custom(Constants.FontName.medium, size: 17.0))
                                                .foregroundStyle(Colors.foregroundText)
                                        }
                                        Spacer()
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Colors.foreground)
                        .clipShape(RoundedRectangle(cornerRadius: 28.0))
                        .padding([.leading, .trailing])
                    }
                }
                
                // Loading Recipe Panel
                if recipeGenerator.isCreating || viewModel.isLoadingLockedRecipePanels {
                    ZStack {
                        HStack {
                            Spacer()
                            VStack(spacing: 0.0) {
                                Text("Creating...")
                                    .font(.custom(Constants.FontName.black, size: 24.0))
                                    .foregroundStyle(Colors.foregroundText)
                                ProgressView()
                                    .foregroundStyle(Colors.foregroundText)
                            }
                            Spacer()
                        }
                    }
                    .padding()
                    .background(Colors.foreground)
                    .clipShape(RoundedRectangle(cornerRadius: 28.0))
                    .padding([.leading, .trailing])
                }
                
                // Tap to Craft Another Panel
                if recipeGenerator.isCreating && !viewModel.isLoadingLockedRecipePanels && !viewModel.isDisplayingCapReachedCard {
                    ZStack {
                        Button(action: {
                            HapticHelper.doLightHaptic()
                            
                            if premiumUpdater.isPremium {
                                Task {
                                    do {
                                        try await generateNext()
                                        
                                        HapticHelper.doSuccessHaptic()
                                    } catch {
                                        // TODO: Handle errors
                                        print("Could not generate next recipe in RecipeGenerationView... \(error)")
                                    }
                                }
                            } else {
                                viewModel.isShowingUltraView = true
                            }
                        }) {
                            Spacer()
                            Text("Tap to Craft Another...")
                                .font(.custom(Constants.FontName.heavy, size: 24.0))
                                .foregroundStyle(Colors.elementBackground)
                            if !premiumUpdater.isPremium {
                                Text(Image(systemName: "lock"))
                                    .font(.custom(Constants.FontName.heavy, size: 24.0))
                                    .foregroundStyle(Colors.elementBackground)
                            }
                            Spacer()
                        }
                    }
                    .padding()
                    .background(Colors.foreground)
                    .clipShape(RoundedRectangle(cornerRadius: 28.0))
                    .padding([.leading, .trailing])
                    .disabled(recipeGenerator.isCreating || viewModel.isLoadingLockedRecipePanels)
                    .opacity(recipeGenerator.isCreating || viewModel.isLoadingLockedRecipePanels ? 0.4 : 1.0)
                }
                
                Spacer(minLength: 80.0)
            }
            .scrollIndicators(.never)
        }
    }
    
    func generateNext() async throws {
        print(viewModel.parsedInputDifferentThanNewRecipes)
        
        // Ensure authToken
        let authToken = try await AuthHelper.ensure()
        
        // If recipeID can be unwrapped from creating a recipe with recipeGenerator, get recipe ingredients preview, update remaining, and generateNext
        let recipe = try await recipeGenerator.create(
            ingredients: viewModel.parsedInputDifferentThanNewRecipes,
            modifiers: viewModel.parsedModifiers,
            expandIngredientsMagnitude: viewModel.generationAdditionalOptions.rawValue, // TODO: This should also be some string value on the server instead of expandIngredientsMagnitude as the advanced options could have more functionality this way :)
            authToken: authToken,
            in: viewContext)
        
        viewModel.createdRecipes.append(recipe)
        
        // Generate bing image
        try await recipeBingImageGenerator.generateBingImage(
            recipeObjectID: recipe.objectID,
            authToken: authToken,
            in: viewContext)
        
        // Set isLoadingRecipe to false and generate next if it is auto generating
        if viewModel.createdRecipes.count < viewModel.getMaxAutoGenerate(premiumUpdater: premiumUpdater) {
            HapticHelper.doLightHaptic()
            
            try await generateNext()
        }
    }
    
    func showLockedRecipePanels() async throws {
        // Ensure user is not premium, otherwise return
        guard !premiumUpdater.isPremium else {
            // TODO: Handle errors
            return
        }
        
        // Defer setting lockedPanelsLoading to false to ensure it is set when the function finishes
        defer {
            viewModel.isLoadingLockedRecipePanels = false
        }
        
        // Set lockedPanelsLoading to true to get the loading indicator back
        viewModel.isLoadingLockedRecipePanels = true
        
        for i in 0..<viewModel.lockedRecipePanelCount {
            try await Task.sleep(nanoseconds: UInt64(1_000_000_000 * viewModel.lockedRecipePanelShowDelay))
            
            viewModel.lockedRecipePanelsShowing += 1
        }
    }
    
}

#Preview {
    
    let recipe = {
        let context = CDClient.mainManagedObjectContext
        
        let recipe = Recipe(context: context)
        
        recipe.name = "Test recipe name"
        
        try! context.save()
        
        return recipe
    }()
    
    return RecipeGenerationListView(
        viewModel: RecipeGenerationListViewModel(
            pantryItems: [],
            suggestions: [],
            input: "something delicious with coca cola",
            generationAdditionalOptions: .normal),
        onDismiss: {
            
        },
        didSaveRecipe: { recipe in
            
        })
    .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
    .environmentObject(PremiumUpdater())
    .environmentObject(ProductUpdater())
    .environmentObject(RemainingUpdater())
    .background(Colors.background)
}

