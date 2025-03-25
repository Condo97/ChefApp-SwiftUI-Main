//
//  RecipeOfTheDayGenerationSwipeView.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 12/7/24.
//

import CoreData
import SwiftUI

class RecipeGenerationSwipeViewModel: RecipeGenerationViewModel {
    
    /// Flag indicating whether the next recipe is currently being generated
    @Published var isGeneratingNext: Bool = false
    
    /// View model for the pantry view presented as a sheet
    @Published var presentingPantryViewModel: PantryViewModel?
    /// View model for the entry view presented as a sheet
    @Published var presentingEntryViewModel: EntryViewModel?
    
    /// Default pantry items used for demo purposes when user has no pantry items
    let demoPantryItems: String = "Salt, pepper, olive oil, butter, garlic, onion, tomato, chicken, flour, sugar, eggs, milk, cheese, basil, oregano, paprika, cumin, ginger, soy sauce, honey, lemon, beef, pork, rice, pasta, potatoes, carrots, celery, mushrooms, spinach, cilantro, parsley, vinegar, baking powder, baking soda, vanilla extract, cinnamon, nutmeg, canola oil, chicken broth, beef broth, bell peppers, zucchini, corn, beans, shrimp, tofu, yogurt, maple syrup, tahini, mustard, cilantro"
    
    /// Returns selected suggestions joined by commas or nil if no suggestions are selected
    var parsedModifiers: String? {
        // Right now if selectedSuggestions is empty nil, otherwise just the selectedSuggestions separated by commas
        suggestions.isEmpty ? nil : suggestions.joined(separator: ", ")
    }
    
    /// Returns the maximum number of recipes that can be automatically generated based on premium status
    /// - Parameter premiumUpdater: The premium status updater to check premium status
    /// - Returns: The maximum number of recipes that can be auto-generated
    func getMaxAutoGenerate(premiumUpdater: PremiumUpdater) -> Int {
        (premiumUpdater.isPremium ? Constants.Generation.premiumAutomaticRecipeGenerationLimit : Constants.Generation.freeAutomaticRecipeGenerationLimit)
        +
        2
    }
    
    /// Fetches all pantry items from Core Data
    /// - Parameter managedContext: The NSManagedObjectContext to fetch from
    /// - Returns: Array of PantryItem objects or nil if fetching fails
    func getAllPantryItems(in managedContext: NSManagedObjectContext) -> [PantryItem]? {
        do {
            return try managedContext.performAndWait { try managedContext.fetch(PantryItem.fetchRequest()) }
        } catch {
            // TODO: Handle Errors
            print("Error fetching pantry items in RecipeGenerationSwipeView... \(error)")
            return nil
        }
    }
    
    /// Creates a formatted input string for recipe generation based on current pantry items
    /// - Parameter managedContext: The NSManagedObjectContext to fetch additional data from if needed
    /// - Returns: A formatted string to use as input for recipe generation
    func getParsedInput(in managedContext: NSManagedObjectContext) -> String {
        // TODO: Should I add anything else to the input string if selectedPantryItems is not empty?
        // Create parsedInput starting with input
        var parsedInput = input
        
        // If selectedPantryItems is not empty add generationAdditionalOptions additional string and selectedPantryItems separated by commas
        if !pantryItems.isEmpty {
            parsedInput += generationAdditionalOptions == .boostCreativity ? "\nIngredients: " : (generationAdditionalOptions == .useOnlyGivenIngredients ? "\nSelect From: " : "\nChoose from Ingredients: ")
            parsedInput += "\n\n"
        }
        
        // If pantryItems is empty or generationAdditionalOptions is useAllGivenIngredients add all pantry items, otherwise add pantry items
        if pantryItems.isEmpty {
            if let allPantryItems = getAllPantryItems(in: managedContext),
               !allPantryItems.isEmpty {
                parsedInput += allPantryItems.shuffled().compactMap({$0.name}).joined(separator: ", ")
            } else {
                // Append demo text TODO: Make sure this cannot be shown unless user enters ingredients, or handle in a better way
                parsedInput += demoPantryItems.split(separator: ", ").shuffled().joined(separator: ", ")//"<No ingredients, the user is demoing the recipe creation ability.> Imagine there are common ingredients included here."
            }
        } else {
            parsedInput += pantryItems.shuffled().compactMap({$0.name}).joined(separator: ", ") // TODO: Should there be anything else if the name cannot be unwrapped? Since that is the only attribute besides category it's most likely always going to be filled, right, or at least it's expected behaviour to be filled, so it's probably fine to just compactmap filtering with just the name
        }
        
        return parsedInput
    }
    
    /// Creates an input string that includes instructions to make the generated recipe different from existing recipes
    /// - Parameters:
    ///   - recipeSwipeCardsViewModel: The view model containing existing recipes
    ///   - managedContext: The NSManagedObjectContext to fetch additional data from if needed
    /// - Returns: A formatted string with instructions to generate a different recipe
    func getParsedInputDifferentThanNewRecipes(recipeSwipeCardsViewModel: RecipeSwipeCardsView.Model, in managedContext: NSManagedObjectContext) -> String {
        let allCards = recipeSwipeCardsViewModel.swipedCards + recipeSwipeCardsViewModel.unswipedCards
        return getParsedInput(in: managedContext) + (allCards.count > 0 ? "\nDIFFERENT THAN RECIPE: " + allCards.compactMap({$0.name != nil && $0.summary != nil ? "\($0.name!), \($0.summary!)" : nil}).joined(separator: "\nAND DIFFERENT THAN: ") : "")
    }
    
    /// Handles actions when the generate button is pressed
    /// - Parameter recipeSwipeCardsViewModel: The view model to reset
    func onGenerate(recipeSwipeCardsViewModel: RecipeSwipeCardsView.Model) {
        // Reset swipe cards
        recipeSwipeCardsViewModel.reset()
        
        // Dismiss presenting entry view model
        presentingEntryViewModel = nil
    }
    
    /// Asynchronously generates the next recipe and its image, then adds it to the swipe cards
    /// - Parameters:
    ///   - recipeGenerator: The generator used to create the recipe
    ///   - recipeBingImageGenerator: The generator used to create the recipe image
    ///   - recipeSwipeCardsViewModel: The view model to add the new recipe card to
    ///   - managedContext: The NSManagedObjectContext to use for persistence
    /// - Throws: Errors from recipe generation, image generation, or authentication
    func generateNext(
        recipeGenerator: RecipeGenerator,
        recipeBingImageGenerator: RecipeBingImageGenerator,
        recipeSwipeCardsViewModel: RecipeSwipeCardsView.Model,
        in managedContext: NSManagedObjectContext
    ) async throws {
        defer { Task { await MainActor.run { [weak self] in self?.isGeneratingNext = false } } }
        await MainActor.run { isGeneratingNext = true }
        
        let authToken = try await AuthHelper.ensure()
        
        // If recipeID can be unwrapped from creating a recipe with recipeGenerator, get recipe ingredients preview, update remaining, and generateNext
        let recipe = try await recipeGenerator.create(
            ingredients: getParsedInputDifferentThanNewRecipes(
                recipeSwipeCardsViewModel: recipeSwipeCardsViewModel,
                in: managedContext),
            modifiers: parsedModifiers,
            expandIngredientsMagnitude: generationAdditionalOptions.rawValue, // TODO: This should also be some string value on the server instead of expandIngredientsMagnitude as the advanced options could have more functionality this way :)
            authToken: authToken,
            in: managedContext)
        
        // Generate bing image
        try await recipeBingImageGenerator.generateBingImage(
            recipeObjectID: recipe.objectID,
            authToken: authToken,
            in: managedContext)
        
        // Set isGeneratingNext to false to ensure the next one can be updated since the recipe is already generated, though this function should really just return the recipe and its caller should append the recipe
        await MainActor.run { isGeneratingNext = false }
        
        // Add to unswiped cards
        await MainActor.run {
            withAnimation {
                recipeSwipeCardsViewModel.unswipedCards.append(RecipeSwipeCardView.Model(
                    recipe: recipe,
                    imageURL: recipe.imageAppGroupLocation == nil ? nil : AppGroupLoader(appGroupIdentifier: Constants.Additional.appGroupID).fileURL(for: recipe.imageAppGroupLocation!),
                    name: recipe.name,
                    summary: recipe.summary))
            }
        }
    }
    
    /// Checks if more recipes should be generated and triggers generation if needed
    /// - Parameters:
    ///   - premiumUpdater: The premium status updater to check limits
    ///   - recipeGenerator: The generator used to create the recipe
    ///   - recipeBingImageGenerator: The generator used to create the recipe image
    ///   - recipeSwipeCardsViewModel: The view model containing current recipe cards
    ///   - managedContext: The NSManagedObjectContext to use for persistence
    func generateNextIfQueueHasFewerThanMaxAutoGenerate(
        premiumUpdater: PremiumUpdater,
        recipeGenerator: RecipeGenerator,
        recipeBingImageGenerator: RecipeBingImageGenerator,
        recipeSwipeCardsViewModel: RecipeSwipeCardsView.Model,
        in managedContext: NSManagedObjectContext) {
            if recipeSwipeCardsViewModel.unswipedCards.count < getMaxAutoGenerate(premiumUpdater: premiumUpdater) {
            // Request generation
            Task {
                // Generate if is not generating next TODO: Test if this needs to be faster and if so add a count to the amount of recipes that can be generating at once
                if !isGeneratingNext {
                    do {
                        try await generateNext(
                            recipeGenerator: recipeGenerator,
                            recipeBingImageGenerator: recipeBingImageGenerator,
                            recipeSwipeCardsViewModel: recipeSwipeCardsViewModel,
                            in: managedContext)
                    } catch {
                        // TODO: Handle errors
                        print("Could not generate next recipe in RecipeOfTheDayGenerationSwipeView... \(error)")
                    }
                }
            }
        }
    }
    
}

struct RecipeGenerationSwipeView: View {
    
    // Required
    /// The view model controlling recipe generation and swipe functionality
    @ObservedObject var viewModel: RecipeGenerationSwipeViewModel
    /// Callback triggered when a recipe is swiped left or right
    let onSwipe: (_ recipe: Recipe, _ swipeDirection: RecipeSwipeCardView.SwipeDirection) -> Void
    /// Callback triggered when a recipe is saved from the detail view
    let onDetailViewSave: (Recipe) -> Void
    /// Callback triggered when an undo action is performed on a previously swiped recipe
    let onUndo: (_ recipe: Recipe, _ previousSwipeDirection: RecipeSwipeCardView.SwipeDirection) -> Void
    /// Callback triggered when the view is closed
    let onClose: () -> Void
    
    // Optional
    /// Object responsible for generating recipes
    @StateObject var recipeGenerator: RecipeGenerator = RecipeGenerator()
    /// Object responsible for generating recipe images using Bing
    @StateObject var recipeBingImageGenerator: RecipeBingImageGenerator = RecipeBingImageGenerator()
    /// View model that manages the swipeable recipe cards
    @StateObject var recipeSwipeCardsViewModel: RecipeSwipeCardsView.Model = RecipeSwipeCardsView.Model(cards: []) // Handles cards
    
    // Private
    /// Core Data managed object context from the environment
    @Environment(\.managedObjectContext) private var viewContext
    
    /// Object that tracks the user's premium status
    @EnvironmentObject private var premiumUpdater: PremiumUpdater
    
    /// Returns true if a recipe or image is currently being generated
    var isLoadingRecipe: Bool {
        recipeGenerator.isCreating || recipeBingImageGenerator.isGenerating
    }
    
    var body: some View {
        VStack {
            // Recipe Cards
            RecipeSwipeView(
                recipeGenerator: recipeGenerator,
                recipeSwipeCardsViewModel: recipeSwipeCardsViewModel,
                isLoading: isLoadingRecipe,
                onSwipe: onSwipe,
                onDetailViewSave: onDetailViewSave,
                onClose: onClose)
            
            // Swipe right to save label
            Text("swipe right to save")
                .font(.body, 14)
                .foregroundStyle(Colors.foregroundText)
                .opacity(0.6)
            
            // Control Buttons
            HStack {
                // Undo
                Button(action: {
                    withAnimation {
                        if let lastSwipedCard = recipeSwipeCardsViewModel.undo() {
                            if let recipe = lastSwipedCard.recipe { // TODO: Research and analyze use cases to see if this is a good way to handle this
                                onUndo(recipe, lastSwipedCard.swipeDirection)
                            }
                        }
                    }
                }) {
                    Image(systemName: "arrow.uturn.backward")
                        .padding()
                        .foregroundStyle(Color(.systemBlue))
                        .background(Colors.foreground)
                        .clipShape(Circle())
                        .font(.body, 24.0)
                }
                .disabled(recipeSwipeCardsViewModel.swipedCards.isEmpty)
                .opacity(recipeSwipeCardsViewModel.swipedCards.isEmpty ? 0.2 : 1.0)
                
                // Skip
                Button(action: {
                    if let topCard = recipeSwipeCardsViewModel.unswipedCards.reversed().first,
                       let recipe = topCard.recipe {
                        recipeSwipeCardsViewModel.updateTopCardSwipeDirection(.left)
                        recipeSwipeCardsViewModel.removeTopCard()
                        onSwipe(recipe, .left)
                    }
                }) {
                    Image(systemName: "xmark")
                        .padding()
                        .foregroundStyle(Color(.systemRed))
                        .background(Colors.foreground)
                        .clipShape(Circle())
                        .font(.body, 40.0)
                }
                
                // Save
                Button(action: {
                    if let topCard = recipeSwipeCardsViewModel.unswipedCards.reversed().first,
                       let recipe = topCard.recipe {
                        recipeSwipeCardsViewModel.updateTopCardSwipeDirection(.right)
                        recipeSwipeCardsViewModel.removeTopCard()
                        onSwipe(recipe, .right)
                    }
                }) {
                    Image(systemName: "checkmark")
                        .padding()
                        .foregroundStyle(Color(.systemGreen))
                        .background(Colors.foreground)
                        .clipShape(Circle())
                        .font(.body, 40.0)
                }
                
                // Pantry
                Button(action: {
                    viewModel.presentingPantryViewModel = PantryViewModel(
                        showsEditButton: true,
                        selectedItems: viewModel.pantryItems)
                }) {
                    Image(systemName: "list.bullet")
                        .padding()
                        .foregroundStyle(Color(.systemYellow))
                        .background(Colors.foreground)
                        .clipShape(Circle())
                        .font(.body, 24.0)
                }
            }
            
            // Entry Mini View
            Button(action: {
                viewModel.presentingEntryViewModel = EntryViewModel(
                    subtitleMessage: "Tap a suggestion or ingredients to create.",
                    selectedPantryItems: viewModel.pantryItems,
                    generationAdditionalOptions: viewModel.generationAdditionalOptions,
                    selectedSuggestions: viewModel.suggestions,
                    showsTitle: false)
            }) {
                RecipeGenerationSwipeEntryMini(viewModel: viewModel)
            }
        }
        .background(Colors.background)
        .sheet(item: $viewModel.presentingEntryViewModel) { entryViewModel in
            NavigationStack {
                VStack {
                    EntryView(
                        viewModel: entryViewModel,
                        onGenerate: {
                            // Move values to viewModel
                            viewModel.pantryItems = entryViewModel.selectedPantryItems
                            viewModel.input = entryViewModel.promptText
                            viewModel.suggestions = entryViewModel.selectedSuggestions
                            viewModel.generationAdditionalOptions = entryViewModel.isDisplayingAdvancedOptions ? entryViewModel.generationAdditionalOptions : .normal
                            
                            // Call onGenerate
                            viewModel.onGenerate(recipeSwipeCardsViewModel: recipeSwipeCardsViewModel)
                        },
                        onDismiss: { viewModel.presentingEntryViewModel = nil })
                }
                .background(Colors.background)
            }
        }
        .fullScreenCover(item: $viewModel.presentingPantryViewModel) { presentingPantryViewModel in
            NavigationStack {
                PantryView(
                    viewModel: presentingPantryViewModel,
                    onDismiss: {
                        // Set pantry items to selected items in selection view model
                        viewModel.pantryItems = presentingPantryViewModel.selectedItems
                        
                        viewModel.presentingPantryViewModel = nil
                    })
                .background(Colors.background)
            }
        }
        .onReceive(recipeSwipeCardsViewModel.$unswipedCards) { newValue in
            // When unswipedCards is changed, which happens when the user either swipes a card or a new card is added, generate next if queue has fewer than max auto generate TODO: Is this two-purpose logic bad implementation? Probably, so fix it... or research it at least
            viewModel.generateNextIfQueueHasFewerThanMaxAutoGenerate(
                premiumUpdater: premiumUpdater,
                recipeGenerator: recipeGenerator,
                recipeBingImageGenerator: recipeBingImageGenerator,
                recipeSwipeCardsViewModel: recipeSwipeCardsViewModel,
                in: viewContext)
        }
    }
    
}

#Preview {
    RecipeGenerationSwipeView(
        viewModel: RecipeGenerationSwipeViewModel(
            pantryItems: [],
            suggestions: [],
            input: "",
            generationAdditionalOptions: .normal),
        onSwipe: { recipe, direction in
            
        },
        onDetailViewSave: { recipe in
            
        },
        onUndo: { recipe, previousSwipeDirection in
            
        },
        onClose: {
            
        })
    .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
    .environmentObject(PremiumUpdater())
    .environmentObject(ProductUpdater())
    .environmentObject(RemainingUpdater())
    .environmentObject(ScreenIdleTimerUpdater())
}
