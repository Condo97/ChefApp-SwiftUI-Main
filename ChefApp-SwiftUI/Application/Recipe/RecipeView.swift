//
//  RecipeView.swift
//  Barback
//
//  Created by Alex Coundouriotis on 9/20/23.
//

import CoreData
import Foundation
import SwiftUI

class RecipeViewModel: ObservableObject, Identifiable {
    
    @Published var recipe: Recipe
    
    @Published var expandedPercentage: CGFloat = 1.0
    @Published var scrollTopOffsetSpacerMinLength: CGFloat = 0.0
    
    @Published var isDisplayingRelatedVideos: Bool = false
    @Published var isEditingTitle: Bool = false
    @Published var isEditingIngredients: Bool = false
    @Published var isShowingRecipeImagePicker: Bool = false
    @Published var isShowingUltraView: Bool = false
    
    @Published var cardColor: Color = Colors.foreground
    
    @Published var alertShowingAllItemsMarkedForDeletion: Bool = false
    
    init(
        recipe: Recipe
    ) {
        self.recipe = recipe
    }
    
    func getEstimatedServings() -> Int {
        Int(recipe.estimatedServingsModified == 0 ? recipe.estimatedServings : recipe.estimatedServingsModified)
    }
    
    func setEstimatedServings(servings: Int, in managedContext: NSManagedObjectContext) {
        Task {
            do {
                try await RecipeCDClient.updateRecipe(recipe, estimatedServings: Int16(servings), in: managedContext)
            } catch {
                // TODO: [Error Handling] Handle Errors
                print("Error updating Recipe in RecipeView... \(error)")
                return
            }
        }
    }
    
    func regenerateBingImageIfNecessary(recipeBingImageGenerator: RecipeBingImageGenerator, in managedContext: NSManagedObjectContext) async {
        // Generate bing image if recipe imageData is nil
        if recipe.imageFromAppData == nil {
            // Ensure authToken
            let authToken: String
            do {
                authToken = try await AuthHelper.ensure()
            } catch {
                // TODO: [Error Handling] Handle Errors
                print("Error ensuring authToken in RecipeView... \(error)")
                return
            }
            
            // Generate bing image for recipe
            await generateBingImage(
                recipeBingImageGenerator: recipeBingImageGenerator,
                authToken: authToken,
                managedContext: managedContext
            )
        }
        
        // TODO: Also add an option for AI image!
    }
    
    func generateBingImage(recipeBingImageGenerator: RecipeBingImageGenerator, authToken: String, managedContext: NSManagedObjectContext) async {
        /* Bing Image */
        do {
            try await recipeBingImageGenerator.generateBingImage(
                recipeObjectID: recipe.objectID,
                authToken: authToken,
                in: managedContext)
        } catch {
            // TODO: Handle Errors
            print("Error generating bing image in RecipeView... \(error)")
        }
    }
    
    func resolveIngredientsAndRegenerateDirections(recipeDirectionsRegenerator: RecipeDirectionsRegenerator, in managedContext: NSManagedObjectContext) async {
        // Ensure authToken
        let authToken: String
        do {
            authToken = try await AuthHelper.ensure()
        } catch {
            // TODO: [Error Handling] Handle Errors
            print("Error ensuring authToken in RecipeView... \(error)")
            return
        }
        
        // Fetched measured ingredients
        let measuredIngredientsFetchRequest = RecipeMeasuredIngredient.fetchRequest()
        measuredIngredientsFetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \RecipeMeasuredIngredient.nameAndAmount, ascending: true)]
        measuredIngredientsFetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(RecipeMeasuredIngredient.recipe), recipe)
        let measuredIngredients: [RecipeMeasuredIngredient]
        do {
            measuredIngredients = try await managedContext.perform { try managedContext.fetch(measuredIngredientsFetchRequest) }
        } catch {
            // TODO: [Error Handling] Handle Errors
            print("Error fetching measured ingredients in RecipeView... \(error)")
            return
        }
        
        // Ensure all ingredients arent marekd for deletion, otherwise set showing alert to true and return TODO: Is this a good place and implementation for this?
        guard measuredIngredients.contains(where: {!$0.markedForDeletion}) else {
            await MainActor.run {
                alertShowingAllItemsMarkedForDeletion = true
            }
            return
        }
        
        // Regenerate directions and resolve updated ingredients
        do {
            try await recipeDirectionsRegenerator.regenerateDirectionsAndResolveUpdatedIngredients(
                for: recipe.objectID,
                additionalInput: "In the recipe's instructions but NOT measured ingredients, you may use **text** for bold (amounts and ingredients and emphesis) and *text* for italic (sparingly if at all), and other formats with LocalizedStringKey Swift 5.5+.",
                authToken: authToken,
                in: managedContext)
        } catch {
            // TODO: [Error Handling] Handle Errors
            print("Error regenerating directions in RecipeView... \(error)")
        }
    }
    
//    var isShowingIngredientEditorView: Binding<Bool> {
//        Binding(
//            get: {
//                editingIngredient != nil
//            },
//            set: { newValue in
//                if !newValue {
//                    self.editingIngredient = nil
//                }
//            })
//    }
    
}

struct RecipeView: View {
    
    @ObservedObject var viewModel: RecipeViewModel
    @StateObject var recipeBingImageGenerator: RecipeBingImageGenerator = RecipeBingImageGenerator()
    @State var showsCloseButton: Bool = true
    let onDismiss: () -> Void
    
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject private var premiumUpdater: PremiumUpdater
    @EnvironmentObject private var remainingUpdater: RemainingUpdater
    @EnvironmentObject private var screenIdleTimerUpdater: ScreenIdleTimerUpdater
    
    @StateObject private var tikTokSearchGenerator = TikTokSearchGenerator()
    
    @StateObject private var recipeFinalizer: RecipeFinalizer = RecipeFinalizer()
    @StateObject private var recipeDirectionsRegenerator: RecipeDirectionsRegenerator = RecipeDirectionsRegenerator()
    
    
    var body: some View {
        ZStack {
//            let _ = Self._printChanges()
            VStack(spacing: 0.0) {
                ScrollView {
                    Spacer()
                    
                    RecipeTopCard(
                        recipe: viewModel.recipe,
                        toggleRecipeImagePicker: {
                            
                        },
                        toggleEditingTitle: {
                            
                        })
                    
                    RecipeDailyRecipeCard(recipe: viewModel.recipe)
                    
                    RecipeTikTokSourceCard(recipe: viewModel.recipe)
                    
                    RecipeTikTokRelatedVideosCard(recipe: viewModel.recipe)
                    
                    RecipeDetailsContainer(
                        recipe: viewModel.recipe,
                        recipeFinalizer: recipeFinalizer,
                        cardColor: viewModel.cardColor,
                        finishUpdatingRecipe: finishUpdatingRecipeIfNeeded,
                        shouldRegenerateDirections: { Task { await viewModel.resolveIngredientsAndRegenerateDirections(
                            recipeDirectionsRegenerator: recipeDirectionsRegenerator,
                            in: viewContext) } })
                }
            }
            
            VStack {
                if showsCloseButton {
                    header
                }
                
                Spacer()
            }
        }
        .background(Colors.background)
        .recipeTitleEditorPopup(isPresented: $viewModel.isEditingTitle, recipe: viewModel.recipe)
        .recipeImagePickerPopup(isPresented: $viewModel.isShowingRecipeImagePicker, recipe: viewModel.recipe)
        .ultraViewPopover(isPresented: $viewModel.isShowingUltraView)
        .alert("No Ingredients", isPresented: $viewModel.alertShowingAllItemsMarkedForDeletion, actions: {
            Button("Close", role: .cancel, action: {
                
            })
        }) {
            Text("All ingredients are marked for deletion. Please ensure there is at least one ingredient before updating directions.")
        }
        .onAppear {
            screenIdleTimerUpdater.keepScreenOn = true
        }
        .task {
            // Finish updating recipe if needed
            //  this includes updating measured ingredients, instructions, and other stuff
            await finishUpdatingRecipeIfNeeded()
        }
        .task {
            await viewModel.regenerateBingImageIfNecessary(
                recipeBingImageGenerator: recipeBingImageGenerator,
                in: viewContext)
        }
        .onDisappear {
            screenIdleTimerUpdater.keepScreenOn = false
        }
        
    }
    
    var header: some View {
        ZStack {
            HStack {
                Spacer()
                
                VStack {
                    Button(action: {
                        HapticHelper.doLightHaptic()
                        
                        withAnimation {
                            onDismiss()
                        }
                    }) {
                        Text(Image(systemName: "xmark"))
                            .shadow(color: Colors.elementText, radius: 1)
                            .font(.custom(Constants.FontName.black, size: 34.0))
                            .foregroundStyle(Colors.elementBackground)
                            .padding()
                        
                    }
                    Spacer()
                }
            }
        }
        .frame(height: 100)
    }
    
    func finishUpdatingRecipeIfNeeded() async {
        // Ensure authToken
        let authToken: String
        do {
            authToken = try await AuthHelper.ensure()
        } catch {
            // TODO: [Error Handling] Handle Errors
            print("Error ensuring authToken in RecipeView... \(error)")
            return
        }
        
        // Get recipe
        let recipe: Recipe
        do {
            recipe = try await CDClient.getByObjectID(objectID: viewModel.recipe.objectID, in: viewContext)
        } catch {
            // TODO: [Error Handling] Handle Errors
            print("Error getting recipe in RecipeView... \(error)")
            return
        }
        
        // TODO: Maybe generate image here?
        // If no measuredIngredients or directions, finalize and update remaining
        if recipe.measuredIngredients == nil || recipe.measuredIngredients!.count == 0 || recipe.directions == nil || recipe.directions!.count == 0 {
            // Finalize recipe
            do {
                try await recipeFinalizer.finalize(
                    recipeObjectID: viewModel.recipe.objectID,
                    additionalInput: "In the recipe's instructions but NOT measured ingredients, you may use **text** for bold (amounts and ingredients and emphesis) and *text* for italic (sparingly if at all), and other formats with LocalizedStringKey Swift 5.5+.",
                    authToken: authToken,
                    in: viewContext)
            } catch NetworkingError.capReachedError {
                //                isDisplayingCapReachedCard //- This is handled by shouldDisplayCapReachedCard
            } catch {
                // TODO: Handle errors
                print("Error finalizing recipe in RecipeView... \(error)")
            }
            
            // Update remaining
            do {
                let authToken = try await AuthHelper.ensure()
                
                do {
                    try await remainingUpdater.update(authToken: authToken)
                } catch {
                    // TODO: Handle Errors
                    print("Error updating remaining in RecipeView... \(error)")
                }
            } catch {
                // TODO: Handle Errors
                print("Error ensuring authToken in RecipeView... \(error)")
            }
        }
    }
    
    func updateExpandedPercentage(offset: CGPoint) {
        let maxOffset: CGFloat = 100.0
        
        if offset.y > maxOffset {
            viewModel.expandedPercentage = 0.0
        } else if offset.y <= 0 {
            viewModel.expandedPercentage = 1.0
        } else {
            viewModel.expandedPercentage = 1 - offset.y / maxOffset
        }
    }
    
    
}

extension View {
    
    func recipePopup(recipeViewModel: Binding<RecipeViewModel?>) -> some View {
        self
            .popover(item: recipeViewModel) { unwrappedRecipeViewModel in
                RecipeView(
                    viewModel: unwrappedRecipeViewModel,
                    onDismiss: { recipeViewModel.wrappedValue = nil })
            }
    }
    
    func recipeFullScreenCover(recipeViewModel: Binding<RecipeViewModel?>) -> some View {
        self
            .fullScreenCover(item: recipeViewModel) { unwrappedRecipeViewModel in
                RecipeView(
                    viewModel: unwrappedRecipeViewModel,
                    onDismiss: { recipeViewModel.wrappedValue = nil })
                .background(Colors.background)
//                .presentationCompactAdaptation(.fullScreenCover)
            }
    }
    
}

#Preview {
    
    let viewContext = CDClient.mainManagedObjectContext
    
    var recipe = Recipe(entity: Recipe.entity(), insertInto: viewContext)
    recipe.input = "Recipe input"
    recipe.name = "Sparkling Mint Vodka"
    recipe.summary = "A refreshing and minty cocktail with a hint of vodka and a sparkling twist!"
    recipe.estimatedTotalCalories = 100
    recipe.estimatedTotalMinutes = 60
    recipe.imageData = UIImage(named: "AppIconNoBackground")?.pngData()
    recipe.recipeID = 0
    
    recipe.dailyRecipe_isDailyRecipe = true
    recipe.dailyRecipe_timeFrameID = RecipeOfTheDayView.TimeFrames.lunch.rawValue
//    recipe.dailyRecipe_isSavedToRecipes = false
    
    var recipeMeasuredIngredient1 = RecipeMeasuredIngredient(entity: RecipeMeasuredIngredient.entity(), insertInto: viewContext)
    recipeMeasuredIngredient1.nameAndAmount = "ingredient and measurement"
    recipeMeasuredIngredient1.recipe = recipe
    
    var recipeMeasuredIngredient2 = RecipeMeasuredIngredient(entity: RecipeMeasuredIngredient.entity(), insertInto: viewContext)
    recipeMeasuredIngredient2.nameAndAmount = "another ingredient 2 1/4 cup"
    recipeMeasuredIngredient2.recipe = recipe
    
    var recipeMeasuredIngredient3 = RecipeMeasuredIngredient(entity: RecipeMeasuredIngredient.entity(), insertInto: viewContext)
    recipeMeasuredIngredient3.nameAndAmount = "3 3/5 cup wow another ingredient"
    recipeMeasuredIngredient3.recipe = recipe
    
    var recipeDirection1 = RecipeDirection(entity: RecipeDirection.entity(), insertInto: viewContext)
    recipeDirection1.index = 1
    recipeDirection1.string = "First direction"
    recipeDirection1.recipe = recipe
    
    var recipeDirection2 = RecipeDirection(entity: RecipeDirection.entity(), insertInto: viewContext)
    recipeDirection2.index = 2
    recipeDirection2.string = "Second direction"
    recipeDirection2.recipe = recipe
    
    var recipeDirection3 = RecipeDirection(entity: RecipeDirection.entity(), insertInto: viewContext)
    recipeDirection3.index = 3
    recipeDirection3.string = "Third direction"
    recipeDirection3.recipe = recipe
    
    var recipeDirection4 = RecipeDirection(entity: RecipeDirection.entity(), insertInto: viewContext)
    recipeDirection4.index = 4
    recipeDirection4.string = "Fourth direction"
    recipeDirection4.recipe = recipe
    
    var recipeDirection5 = RecipeDirection(entity: RecipeDirection.entity(), insertInto: viewContext)
    recipeDirection5.index = 5
    recipeDirection5.string = "fifth direction"
    recipeDirection5.recipe = recipe
    
    var recipeDirection6 = RecipeDirection(entity: RecipeDirection.entity(), insertInto: viewContext)
    recipeDirection6.index = 6
    recipeDirection6.string = "Sixth direction"
    recipeDirection6.recipe = recipe
    
    var recipeDirection7 = RecipeDirection(entity: RecipeDirection.entity(), insertInto: viewContext)
    recipeDirection7.index = 7
    recipeDirection7.string = "Seventh direction"
    recipeDirection7.recipe = recipe
    
    var recipeDirection8 = RecipeDirection(entity: RecipeDirection.entity(), insertInto: viewContext)
    recipeDirection8.index = 8
    recipeDirection8.string = "Eigth direction"
    recipeDirection8.recipe = recipe
    
    try! viewContext.save()
    
    return RecipeView(
        viewModel: RecipeViewModel(recipe: recipe),
        onDismiss: {
            
        })
    .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
    .environmentObject(PremiumUpdater())
    .environmentObject(ProductUpdater())
    .environmentObject(RemainingUpdater())
    .environmentObject(ScreenIdleTimerUpdater())
    .background(Colors.background)
}
