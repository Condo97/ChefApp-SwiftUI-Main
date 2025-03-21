//
//  RecipeOfTheDayGenerationSwipeView.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 12/7/24.
//

import CoreData
import SwiftUI

class RecipeGenerationSwipeViewModel: RecipeGenerationViewModel {
    
    @Published var isGeneratingNext: Bool = false
    
    @Published var presentingPantryViewModel: PantryViewModel?
    @Published var presentingEntryViewModel: EntryViewModel?
    
    let demoPantryItems: String = "Salt, pepper, olive oil, butter, garlic, onion, tomato, chicken, flour, sugar, eggs, milk, cheese, basil, oregano, paprika, cumin, ginger, soy sauce, honey, lemon, beef, pork, rice, pasta, potatoes, carrots, celery, mushrooms, spinach, cilantro, parsley, vinegar, baking powder, baking soda, vanilla extract, cinnamon, nutmeg, canola oil, chicken broth, beef broth, bell peppers, zucchini, corn, beans, shrimp, tofu, yogurt, maple syrup, tahini, mustard, cilantro"
    
    var parsedModifiers: String? {
        // Right now if selectedSuggestions is empty nil, otherwise just the selectedSuggestions separated by commas
        suggestions.isEmpty ? nil : suggestions.joined(separator: ", ")
    }
    
    func getMaxAutoGenerate(premiumUpdater: PremiumUpdater) -> Int {
        (premiumUpdater.isPremium ? Constants.Generation.premiumAutomaticRecipeGenerationLimit : Constants.Generation.freeAutomaticRecipeGenerationLimit)
        +
        2
    }
    
    func getAllPantryItems(in managedContext: NSManagedObjectContext) -> [PantryItem]? {
        do {
            return try managedContext.performAndWait { try managedContext.fetch(PantryItem.fetchRequest()) }
        } catch {
            // TODO: Handle Errors
            print("Error fetching pantry items in RecipeGenerationSwipeView... \(error)")
            return nil
        }
    }
    
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
            do {
                if let allPantryItems = getAllPantryItems(in: managedContext),
                   !allPantryItems.isEmpty {
                    parsedInput += allPantryItems.shuffled().compactMap({$0.name}).joined(separator: ", ")
                } else {
                    // Append demo text TODO: Make sure this cannot be shown unless user enters ingredients, or handle in a better way
                    parsedInput += demoPantryItems.split(separator: ", ").shuffled().joined(separator: ", ")//"<No ingredients, the user is demoing the recipe creation ability.> Imagine there are common ingredients included here."
                }
            } catch {
                // TODO: Handle Errors
                print("Error getting all pantry items for parsedInput in RecipeGenerationSwipeView... \(error)")
            }
        } else {
            parsedInput += pantryItems.shuffled().compactMap({$0.name}).joined(separator: ", ") // TODO: Should there be anything else if the name cannot be unwrapped? Since that is the only attribute besides category it's most likely always going to be filled, right, or at least it's expected behaviour to be filled, so it's probably fine to just compactmap filtering with just the name
        }
        
        return parsedInput
    }
    
    func getParsedInputDifferentThanNewRecipes(recipeSwipeCardsViewModel: RecipeSwipeCardsView.Model, in managedContext: NSManagedObjectContext) -> String {
        let allCards = recipeSwipeCardsViewModel.swipedCards + recipeSwipeCardsViewModel.unswipedCards
        return getParsedInput(in: managedContext) + (allCards.count > 0 ? "\nDIFFERENT THAN RECIPE: " + allCards.compactMap({$0.name != nil && $0.summary != nil ? "\($0.name!), \($0.summary!)" : nil}).joined(separator: "\nAND DIFFERENT THAN: ") : "")
    }
    
    func onGenerate(recipeSwipeCardsViewModel: RecipeSwipeCardsView.Model) {
        // Reset swipe cards
        recipeSwipeCardsViewModel.reset()
        
        // Dismiss presenting entry view model
        presentingEntryViewModel = nil
    }
    
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
    
    /* Check if */
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
    @ObservedObject var viewModel: RecipeGenerationSwipeViewModel
    let onSwipe: (_ recipe: Recipe, _ swipeDirection: RecipeSwipeCardView.SwipeDirection) -> Void
    let onDetailViewSave: (Recipe) -> Void
    let onUndo: (_ recipe: Recipe, _ previousSwipeDirection: RecipeSwipeCardView.SwipeDirection) -> Void
    let onClose: () -> Void
    
    // Optional
    @StateObject var recipeGenerator: RecipeGenerator = RecipeGenerator()
    @StateObject var recipeBingImageGenerator: RecipeBingImageGenerator = RecipeBingImageGenerator()
    @StateObject var recipeSwipeCardsViewModel: RecipeSwipeCardsView.Model = RecipeSwipeCardsView.Model(cards: []) // Handles cards
    
    // Private
    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject private var premiumUpdater: PremiumUpdater
    
    var isLoadingRecipe: Bool {
        recipeGenerator.isCreating || recipeBingImageGenerator.isGenerating
    }
    
    var body: some View {
        VStack {
            RecipeSwipeView(
                recipeGenerator: recipeGenerator,
                recipeSwipeCardsViewModel: recipeSwipeCardsViewModel,
                isLoading: isLoadingRecipe,
                onSwipe: onSwipe,
                onDetailViewSave: onDetailViewSave,
                onClose: onClose)
            
            Text("swipe right to save")
                .font(.body, 14)
                .foregroundStyle(Colors.foregroundText)
                .opacity(0.6)
            
            HStack {
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
            
            Button(action: {
                viewModel.presentingEntryViewModel = EntryViewModel(
                    subtitleMessage: "Tap a suggestion or ingredients to create.",
                    selectedPantryItems: viewModel.pantryItems,
                    generationAdditionalOptions: viewModel.generationAdditionalOptions,
                    selectedSuggestions: viewModel.suggestions,
                    showsTitle: false)
            }) {
                // TODO: Entry Mini View
                HStack {
                    Spacer()
                    
                    VStack {
                        if !viewModel.pantryItems.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(viewModel.pantryItems) { pantryItem in
                                        if let name = pantryItem.name {
                                            Text(name)
                                                .font(.custom(Constants.FontName.body, size: 12.0))
                                                .padding(.horizontal, 4)
                                                .padding(.vertical, 2)
                                                .background(Colors.background)
                                                .clipShape(Capsule())
                                        }
                                    }
                                }
                            }
                        } else {
                            if let allPantryItems = viewModel.getAllPantryItems(in: viewContext), !allPantryItems.isEmpty {
                                Text("Using all ingredients")
                                    .font(.custom(Constants.FontName.heavy, size: 12.0))
                            } else {
                                Text("Using Demo Ingredients")
                                    .font(.heavy, 12)
                            }
                        }
                        
                        Group {
                            if viewModel.input.isEmpty {
                                Text("*Tap to Add Prompt*")
                                    .opacity(0.6)
                            } else {
                                Text(viewModel.input)
                            }
                        }
                        .font(.custom(Constants.FontName.body, size: 14.0))
                        
                        if viewModel.suggestions.count > 0 {
                            Text(viewModel.suggestions.joined(separator: ", "))
                                .font(.custom(Constants.FontName.heavy, size: 10.0))
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.up")
                }
                .padding()
                .foregroundStyle(Colors.foregroundText)
                .frame(maxWidth: .infinity)
                .background(Colors.foreground)
                .clipShape(RoundedRectangle(cornerRadius: 14.0))
                .padding(.horizontal)
            }
        }
        .background(Colors.background)
        .sheet(item: $viewModel.presentingEntryViewModel) { entryViewModel in
            NavigationStack {
                VStack {
                    EntryView(
                        viewModel: entryViewModel,
                        onGenerate: { viewModel.onGenerate(recipeSwipeCardsViewModel: recipeSwipeCardsViewModel) },
                        onDismiss: { viewModel.presentingEntryViewModel = nil })
                    .padding(.horizontal)
                }
                .background(Colors.background)
            }
        }
        .fullScreenCover(item: $viewModel.presentingPantryViewModel) { presentingPantryViewModel in
            NavigationStack {
                PantryView(
                    viewModel: presentingPantryViewModel,
                    onDismiss: {
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
