//
//  RecipeOfTheDayGenerationSwipeView.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 12/7/24.
//

import CoreData
import SwiftUI

class RecipeOfTheDayGenerationSwipeViewModel: ObservableObject, Identifiable {
    
    @Published var recipeToOverwriteDailyRecipeWith: Recipe?
    @Published var recipeGenerationTimeFrame: RecipeOfTheDayView.TimeFrames
    @Published var recipeGenerationSwipeViewModel: RecipeGenerationSwipeViewModel
    
    init(
        recipeToOverwriteDailyRecipeWith: Recipe? = nil,
        recipeGenerationTimeFrame: RecipeOfTheDayView.TimeFrames,
        recipeGenerationSwipeViewModel: RecipeGenerationSwipeViewModel
    ) {
        self.recipeToOverwriteDailyRecipeWith = recipeToOverwriteDailyRecipeWith
        self.recipeGenerationTimeFrame = recipeGenerationTimeFrame
        self.recipeGenerationSwipeViewModel = recipeGenerationSwipeViewModel
    }
    
    var alertShowingOverwriteRecipe: Binding<Bool> {
        Binding(
            get: { [weak self] in
                self?.recipeToOverwriteDailyRecipeWith != nil
            },
            set: { [weak self] value in
                if !value {
                    self?.recipeToOverwriteDailyRecipeWith = nil
                }
            })
    }
    
    func handleSwipe(recipe: Recipe, direction: RecipeSwipeCardView.SwipeDirection) {
        HapticHelper.doLightHaptic()
        
        if direction == .right {
            saveOrLoadSaveAlert(recipe: recipe)
        }
    }
    
    func saveOrLoadSaveAlert(recipe: Recipe) {
        // Right now it is always overwriting a recipe so always show the alert
        recipeToOverwriteDailyRecipeWith = recipe
    }
    
    func saveRecipe(
        recipe: Recipe,
        dailyRecipes: FetchedResults<Recipe>,
        recipeGenerationTimeFrame: RecipeOfTheDayView.TimeFrames,
        recipeOfTheDayGenerator: RecipeOfTheDayGenerator,
        in managedContext: NSManagedObjectContext
    ) {
        Task {
            // Delete or save and update current recipe of the day for time frame
            let existingRecipesForTimeFrame = dailyRecipes.filter({ $0.dailyRecipe_timeFrameID == recipeGenerationTimeFrame.rawValue })
            for existingRecipeForTimeFrame in existingRecipesForTimeFrame {
                await recipeOfTheDayGenerator.deleteOrSaveAndUpdateRecipe(existingRecipeForTimeFrame, in: managedContext)
            }
            
            // Set to recipe of the day for the time frame
            do {
                try await RecipeCDClient.updateRecipe(recipe, dailyRecipe_isDailyRecipe: true, in: managedContext)
            } catch {
                // TODO: Handle Errors
                print("Error updating recipe dailyRecipe_isDailyRecipe in RecipeOfTheDayContainer, continuing... \(error)")
            }
            do {
                try await RecipeCDClient.updateRecipe(recipe, dailyRecipe_timeFrameID: recipeGenerationTimeFrame.rawValue, in: managedContext)
            } catch {
                // TODO: Handle Errors
                print("Error updating recipe dailyRecipe_timeFrameID in RecipeOfTheDayContainer, continuing... \(error)")
            }
        }
    }
    
}

struct RecipeOfTheDayGenerationSwipeView: View {
    
    @ObservedObject var viewModel: RecipeOfTheDayGenerationSwipeViewModel
    @FetchRequest var dailyRecipes: FetchedResults<Recipe>
    let onDismiss: () -> Void
    
    @Environment(\.managedObjectContext) private var viewContext
    
    var recipeOfTheDayGenerator = RecipeOfTheDayGenerator()
    @StateObject private var recipeSwipeCardsViewModel = RecipeSwipeCardsView.Model(cards: [])
    
    
    var body: some View {
        RecipeGenerationSwipeView(
            viewModel: viewModel.recipeGenerationSwipeViewModel,
            onSwipe: viewModel.handleSwipe,
            onDetailViewSave: viewModel.saveOrLoadSaveAlert,
            onUndo: { recipe, previousSwipeDirection in
                // There should be nothing here becuase it dismisses on swipe right and there is no CoreData modification to be done
            },
            onClose: onDismiss,
            recipeGenerator: recipeOfTheDayGenerator)
        .alert("Save \(viewModel.recipeGenerationTimeFrame.displayString.uppercased())?", isPresented: viewModel.alertShowingOverwriteRecipe, actions: {
            Button("Save") {
                if let recipeToOverwriteDailyRecipeWith = viewModel.recipeToOverwriteDailyRecipeWith {
                    viewModel.saveRecipe(
                        recipe: recipeToOverwriteDailyRecipeWith,
                        dailyRecipes: dailyRecipes,
                        recipeGenerationTimeFrame: viewModel.recipeGenerationTimeFrame,
                        recipeOfTheDayGenerator: recipeOfTheDayGenerator,
                        in: viewContext)
                }
                onDismiss()
            }
            Button("Cancel", role: .cancel) {
                withAnimation {
                    let _ = recipeSwipeCardsViewModel.undo()
                }
            }
        }) {
            Text("This will overwrite your current \(viewModel.recipeGenerationTimeFrame.displayString.lowercased())")
        }
    }
    
}

#Preview {
    
    
    
    RecipeOfTheDayGenerationSwipeView(
        viewModel: RecipeOfTheDayGenerationSwipeViewModel(
            recipeGenerationTimeFrame: .breakfast,
            recipeGenerationSwipeViewModel: RecipeGenerationSwipeViewModel(
                pantryItems: [],
                suggestions: [],
                input: "",
                generationAdditionalOptions: .normal)),
        dailyRecipes: FetchRequest<Recipe>(
            sortDescriptors: [NSSortDescriptor(keyPath: \Recipe.creationDate, ascending: false)],
            predicate: NSPredicate(format: "%K = %d", #keyPath(Recipe.dailyRecipe_isDailyRecipe), true),
            animation: .default),
        onDismiss: {
            
        })
    
}
