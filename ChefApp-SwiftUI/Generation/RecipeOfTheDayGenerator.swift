//
//  RecipeOfTheDayGenerator.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 11/30/24.
//

import CoreData
import Foundation
import SwiftUI

class RecipeOfTheDayGenerator: RecipeGenerator {

    @Published var isLoadingPreGeneration: Bool = false
    @Published var isLoading: Bool = false

    func reloadDailyRecipe(
        dailyRecipes: any Collection<Recipe>,
        pantryItems: any Collection<PantryItem>,
        recipe: Recipe,
        timeFrame: RecipeOfTheDayView.TimeFrames,
        authToken: String,
        in managedContext: NSManagedObjectContext
    ) async {
        defer {
            Task {
                await MainActor.run { [weak self] in
                    self?.isLoadingPreGeneration = false
                }
            }
        }
        
        await MainActor.run { [weak self] in
            self?.isLoadingPreGeneration = true
        }
        
        // *Note: isLoadingPreGeneration is set to false when generating TODO: Is this good behavior I don't think so, make it better
        
        // Get name of previous recipe so that the new one can be different than it
        let previousRecipeName = recipe.name ?? ""

        // Delete or save and update recipe
        await deleteOrSaveAndUpdateRecipe(recipe, in: managedContext)

        // Generate new daily recipe
        do {
            try await generateDailyRecipe(
                dailyRecipes: dailyRecipes,
                pantryItems: pantryItems,
                timeFrame: timeFrame,
                additionalModifiers: "\n\nMake it different than \(previousRecipeName).",
                authToken: authToken,
                in: managedContext)
        } catch {
            // TODO: Handle Errors if Necessary
            print(
                "Error generating daily recipe in reload process in RecipeOfTheDayContainer, continuing... \(error)"
            )
        }
    }

    func processDailyRecipes(
        dailyRecipes: any Collection<Recipe>,
        pantryItems: any Collection<PantryItem>,
        authToken: String,
        in managedContext: NSManagedObjectContext
    ) async {
        defer {
            Task {
                await MainActor.run { [weak self] in
                    self?.isLoadingPreGeneration = false
                }
            }
        }
        
        await MainActor.run { [weak self] in
            self?.isLoadingPreGeneration = true
        }
        
        // *Note: isLoadingPreGeneration is set to false when generating TODO: Is this good behavior I don't think so, make it better
        
        // Scrub yesterday and previous days' recipes that are not saved and save ones that should be
        for dailyRecipe in dailyRecipes {
            if let creationDate = dailyRecipe.creationDate {
                if !Calendar.current.isDateInToday(creationDate) {
                    // Delete or save and update recipe because not today
                    await deleteOrSaveAndUpdateRecipe(
                        dailyRecipe, in: managedContext)
                }
            } else {
                // Delete or save and update recipe because no creationDate TODO: Should this just outright delete it?
                await deleteOrSaveAndUpdateRecipe(
                    dailyRecipe, in: managedContext)
            }
        }
        
        let dailyRecipeTimeframes: [RecipeOfTheDayView.TimeFrames] = [
            .breakfast,
            .lunch,
            .dinner
        ]
        
        for dailyRecipeTimeframe in dailyRecipeTimeframes {
            // Generate new daily breakfast, lunch, and dinner recipes as necessary
            do {
                try await generateDailyRecipe(
                    dailyRecipes: dailyRecipes,
                    pantryItems: pantryItems.shuffled(),
                    timeFrame: dailyRecipeTimeframe,
                    additionalModifiers: nil,
                    authToken: authToken,
                    in: managedContext)
            } catch RecipeOfTheDayError.recipeOfTheDayExistsForTimeframe(let recipe) {
                // Check for imgae existence and add image if necessary
                if recipe.imageData == nil {
                    do {
                        try await RecipeBingImageGenerator().generateBingImage(
                            recipeObjectID: recipe.objectID,
                            authToken: authToken,
                            in: managedContext)
                    } catch {
                        // TODO: [Error Handling] Handle Errors
                    }
                }
            } catch {
                // TODO: [Error Handling] Handle Errors
                print(
                    "Error generating daily breakfast recipe in RecipeOfTheDayContainer, continuing... \(error)"
                )
            }
        }
    }

    func deleteOrSaveAndUpdateRecipe(
        _ recipe: Recipe, in managedContext: NSManagedObjectContext
    ) async {
        if recipe.saved {
            // Save by setting isDailyRecipe and isSavedToRecipes to false
            do {
                try await RecipeCDClient.updateRecipe(
                    recipe, dailyRecipe_isDailyRecipe: false, in: managedContext
                )
            } catch {
                // TODO: Handle Errors
                print(
                    "Error updating recipe isDailyRecipe in RecipeOfTheDayContainer... \(error)"
                )
            }
        } else {
            // Delete
            do {
                try await CDClient.delete(recipe, in: managedContext)
            } catch {
                // TODO: Handle Errors
                print(
                    "Error deleting recipe in RecipeOfTheDayContainer, continuing... \(error)"
                )
            }
        }
    }

    func generateDailyRecipe(
        dailyRecipes: any Collection<Recipe>,
        pantryItems: any Collection<PantryItem>,
        timeFrame: RecipeOfTheDayView.TimeFrames,
        additionalModifiers: String?,
        authToken: String,
        in managedContext: NSManagedObjectContext
    ) async throws -> Recipe {
        defer {
            Task {
                await MainActor.run { [weak self] in
                    self?.isLoading = false
                }
            }
        }
        
        await MainActor.run { [weak self] in
            self?.isLoading = true
        }
        
        // Set isLoadingPreGeneration to false since pre-generation loading is complete
        await MainActor.run { isLoadingPreGeneration = false }

        // Create if no dailyRecipe for timeFrame
        if let existingDailyRecipe = dailyRecipes.first(where: {
            guard let dailyRecipeTimeFrameID = $0.dailyRecipe_timeFrameID,
                let dailyRecipeTimeFrame = RecipeOfTheDayView.TimeFrames(
                    rawValue: dailyRecipeTimeFrameID)
            else {
                // TODO: Delete recipe? Handle this
                print(
                    "Could not unwrap timeFrameID or timeFrame in RecipeOfTheDayContainer!"
                )
                return false
            }

            return timeFrame == dailyRecipeTimeFrame
        }) {
            // Handle daily recipe existing by throwing recipeOfTheDayExistsForTimeframe with existing daily recipe
            throw RecipeOfTheDayError.recipeOfTheDayExistsForTimeframe(recipe: existingDailyRecipe)
        } else {
            // Generate daily recipe and image for current time frame
            do {
                let recipe = try await create(
                    ingredients: pantryItems.compactMap(\.name).joined(
                        separator: ", "),
                    modifiers:
                        "Select from this list and create a delicious \(timeFrame.displayString)."
                        + (additionalModifiers ?? ""),
                    expandIngredientsMagnitude: 0,
                    dailyRecipe_isDailyRecipe: true,
                    dailyRecipe_timeFrameID: timeFrame.rawValue,
                    authToken: authToken,
                    in: managedContext)
                
                // Check for imgae existence and add image if necessary
                if recipe.imageData == nil {
                    do {
                        try await RecipeBingImageGenerator().generateBingImage(
                            recipeObjectID: recipe.objectID,
                            authToken: authToken,
                            in: managedContext)
                    } catch {
                        // TODO: [Error Handling] Handle Errors
                    }
                }
                
                return recipe
            } catch {
                // TODO: [Error Handling] Handle Errors
                print("Error creating recipe in RecipeOfTheDayContainer... \(error)")
                throw error
            }
        }
    }

}
