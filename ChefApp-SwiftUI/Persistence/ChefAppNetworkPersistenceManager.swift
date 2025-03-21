//
//  ChefAppNetworkPersistenceManager.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 11/11/23.
//

import CoreData
import Foundation
import UIKit

class ChefAppNetworkPersistenceManager {
    
    public static var shared = ChefAppNetworkPersistenceManager()
    
    public func categorizeSaveUpdateAllPantryItems(authToken: String, in managedContext: NSManagedObjectContext) async throws {
        // Get all pantry items
        let pantryItemStrings = try await managedContext.perform {
            let fetchRequest = PantryItem.fetchRequest()
            
            let pantryItems = try managedContext.fetch(fetchRequest)
            
            return pantryItems.compactMap({$0.name})
        }
        
        // Build ciRequest and get ciReqsponse from ChefAppNetworkService
        let ciRequest = CategorizeIngredientsRequest(authToken: authToken, ingredients: pantryItemStrings)
        
        let ciResponse = try await ChefAppNetworkService.categorizeIngredients(request: ciRequest)
        
        // Update all pantry items in PantryItemCDClient
        try await PantryItemCDClient.updateAll(newPantryItems: ciResponse.body.ingredientCategories.map({(name: $0.ingredient.capitalized, category: $0.category.capitalized)}), in: managedContext)
    }
    
    public func createSaveRecipe(authToken: String, ingredients: String, modifiers: String?, expandIngredientsMagnitude: Int, dailyRecipe_isDailyRecipe: Bool, dailyRecipe_timeFrameID: String?, in managedContext: NSManagedObjectContext) async throws -> Recipe {
        // Build criRequest and get criResponse from ChefAppNetworkService
        let criRequest = CreateRecipeIdeaRequest(
            authToken: authToken,
            ingredients: ingredients,
            modifiers: modifiers,
            expandIngredientsMagnitude: expandIngredientsMagnitude)
        
        let criResponse = try await ChefAppNetworkService.createRecipeIdea(request: criRequest)
        
        let recipe = try await RecipeCDClient.appendRecipe(
            recipeID: Int64(criResponse.body.recipeID),
            input: modifiers == nil || modifiers!.isEmpty ? ingredients : ingredients + " " + modifiers!, // TODO: Make this better, maybe just store original ingredients and modifiers instead of the input since that part is done on the server, or just stop doing it on the server and do it in the app and save it like this
            dailyRecipe_isDailyRecipe: dailyRecipe_isDailyRecipe,
            dailyRecipe_timeFrameID: dailyRecipe_timeFrameID,
            name: criResponse.body.name,
            summary: criResponse.body.summary,
            feasibility: nil,
            tastiness: nil,
            in: managedContext)
        
        return recipe
    }
    
    public func finalizeUpdateRecipe(authToken: String, recipeObjectID: NSManagedObjectID, additionalInput: String?, in managedContext: NSManagedObjectContext) async throws {
        // Get recipe
        let recipe: Recipe = try await CDClient.getByObjectID(objectID: recipeObjectID, in: managedContext)
        
        // Build frRequest and get frResponse from ChefAppNetworkService TODO: Should be finalize recipe request
        let frReqeust = MakeRecipeFromIdeaRequest(
            authToken: authToken,
            ideaID: recipe.recipeID,
            additionalInput: additionalInput)
        
        let frResponse: MakeRecipeFromIdeaResponse = try await ChefAppNetworkService.makeRecipeFromIdea(request: frReqeust)
        
        // Update estimatedTotalCalories
        if let estimatedTotalCalories = frResponse.body.estimatedTotalCalories {
            try await RecipeCDClient.updateRecipe(recipe, estimatedTotalCalories: Int16(estimatedTotalCalories), in: managedContext)
        }
        
        // Update estimatedTotalMinutes
        if let estimatedTotalMinutes = frResponse.body.estimatedTotalMinutes {
            try await RecipeCDClient.updateRecipe(recipe, estimatedTotalMinutes: Int16(estimatedTotalMinutes), in: managedContext)
        }
        
        // Update estimatedServings
        if let estimatedServings = frResponse.body.estimatedServings {
            try await RecipeCDClient.updateRecipe(recipe, estimatedServings: Int16(estimatedServings), in: managedContext)
        }
        
        // Update feasibility
        if let feasibility = frResponse.body.feasibility {
            try await RecipeCDClient.updateRecipe(recipe, feasibility: Int16(feasibility), in: managedContext)
        }
        
        // Delete all measuredIngredients currently in recipe
        try await RecipeMeasuredIngredientCDClient.deleteAllMeasuredIngredients(for: recipeObjectID, in: managedContext)
        
        // Add new ingredients to recipe
        try await RecipeMeasuredIngredientCDClient.appendMeasuredIngredients(ingredientsAndMeasurements: frResponse.body.allIngredientsAndMeasurements, to: recipeObjectID, in: managedContext)
        
        // Delete all directions currently in recipe
        try await RecipeDirectionCDClient.deleteAllDirections(for: recipeObjectID, in: managedContext)
        
        // Add new directions to recipe
        try await RecipeDirectionCDClient.appendDirections(content: frResponse.body.directions.map({(index: Int16($0.key), string: $0.value)}), to: recipeObjectID, in: managedContext)
    }
    
    public func getSaveCreatePanels() async throws {
        let gcpResponse = try await ChefAppNetworkService.getCreatePanels()
        
        CreatePanelsJSONPersistenceManager.set(gcpResponse.body.createPanels)
    }
    
    /**
     Gets and duplicates a recipe from the server
     
     This funciton is primarily used to copy a recipe from the server when it's shared.
     
     TODO: Fix potential lag on generating bing image, since it has to create the bing image before this function completes
     */
    public func getAndDuplicateAndSaveRecipe(authToken: String, recipeID: Int, recipeGenerator: RecipeGenerator, recipeBingImageGenerator: RecipeBingImageGenerator, in managedContext: NSManagedObjectContext) async throws -> Recipe? {
        let gadrRequest = GetAndDuplicateRecipeRequest(
            authToken: authToken,
            recipeID: recipeID)
        
        let gadrResponse = try await ChefAppNetworkService.getAndDuplicateRecipe(request: gadrRequest)
        
        guard let newRecipeID = gadrResponse.body.recipe.recipeID else {
            // TODO: Handle Errors
            print("Could not unwrap newRecipeID in ChefAppNetworkPersistenceManger!")
            return nil
        }
        
        let recipe = try await RecipeCDClient.appendRecipe(
            recipeID: Int64(newRecipeID),
            input: gadrResponse.body.recipe.input,
            saved: true,
            dailyRecipe_isDailyRecipe: false,
            dailyRecipe_timeFrameID: nil,
            name: gadrResponse.body.recipe.name,
            summary: gadrResponse.body.recipe.summary,
            feasibility: gadrResponse.body.recipe.feasibility == nil ? nil : Int16(gadrResponse.body.recipe.feasibility!),
            tastiness: nil,
            in: managedContext)
        
        if let measuredIngredients = gadrResponse.body.recipe.measuredIngredients {
            do {
                try await RecipeMeasuredIngredientCDClient.appendMeasuredIngredients(
                    ingredientsAndMeasurements: measuredIngredients,
                    to: recipe.objectID,
                    in: managedContext)
            } catch {
                // TODO: Handle Errors
                print("Error appending measured ingredients in ChefAppNetworkPersistenceManager, continuing... \(error)")
            }
        }
        
        if let instructions = gadrResponse.body.recipe.instructions {
            do {
                try await RecipeDirectionCDClient.appendDirections(
                    content: instructions.compactMap({(index: Int16($0.key), string: $0.value)}),
                    to: recipe.objectID,
                    in: managedContext)
            } catch {
                // TODO: Handle Errors
                print("Error appending instructions in ChefAppNetworkPersistenceManager, continuing... \(error)")
            }
        }
        
        do {
            // TODO: Make it share the image as well!
            try await recipeBingImageGenerator.generateBingImage(
                recipeObjectID: recipe.objectID,
                authToken: authToken,
                in: managedContext)
        } catch {
            // TODO: Handle Errors
            print("Error generating bing image for recipe in ChefAppNetworkPersistenceManager... \(error)")
        }
        
        return recipe
    }
    
    public func generateSaveTags(authToken: String, recipe: Recipe, in managedContext: NSManagedObjectContext) async throws {
        // Build gtRequest and get gtResponse from ChefAppNetworkService
        let gtRequest = TagRecipeIdeaRequest(
            authToken: authToken,
            recipeID: recipe.recipeID)
        
        let gtResponse = try await ChefAppNetworkService.tagRecipeIdea(request: gtRequest)
        
        // Save tags
        try await managedContext.perform {
            for tagString in gtResponse.body.tags {
                let tag = RecipeTag(context: managedContext)
                
                tag.tag = tagString
                tag.recipe = recipe
            }
            
            try managedContext.save()
        }
    }
    
    public func parseSavePantryItems(authToken: String, input: String?, imageDataInput: Data? = nil, in managedContext: NSManagedObjectContext) async throws {
        // Build pbiRequest and get pbiResponse from BarbackNetworkService
        let ppiRequest = ParsePantryItemsRequest(
            authToken: authToken,
            input: input,
            imageDataInput: imageDataInput)
        
        let ppiResponse = try await ChefAppNetworkService.parsePantryItems(request: ppiRequest)
        
        // Create duplicate bar item names array which will throw a duplicatePantryItemNames PantryItemPersistenceError with any duplicates so the user can be notified.. TODO: Is this a good implementation?
        var duplicatePantryItemNames: [String] = []
        
        // Save all bar items, capitalized, if item can be unwrapped, setting isAlcohol to false if nil
        for pantryItem in ppiResponse.body.pantryItems {
            if let item = pantryItem.item {
                do {
                    try await PantryItemCDClient.appendPantryItem(
                        name: item.capitalized,
                        category: pantryItem.category?.capitalized,
//                        amount: nil,
//                        expiration: nil,
                        in: managedContext)
                } catch PersistenceError.duplicateObject {
                    // TODO: Handle errors if necessary, but this is so that the function doesn't fall through
                    print("Removed duplicate object when parsing saving bar items in ChefAppNetworkPersistenceManager!")
                    duplicatePantryItemNames.append(item)
                }
            }
        }
        
        // Throw duplicate error if will throw dupilcate error is true
        if !duplicatePantryItemNames.isEmpty {
            throw PantryItemPersistenceError.duplicatePantryItemNames(duplicatePantryItemNames)
        }
    }
    
    public func regenerateSaveMeasuredIngredientsAndDirectionsAndResolveUpdatedIngredients(authToken: String, recipeObjectID: NSManagedObjectID, additionalInput: String, in managedContext: NSManagedObjectContext) async throws {
        // Get recipe
        let recipe: Recipe = try await CDClient.getByObjectID(objectID: recipeObjectID, in: managedContext)
        
        // Ensure recipeMeasuredIngredients and ideaRecipe are not nil and recipe measuredIngredients count is greater than 0, otherwise throw GenerationError missingInput
        guard recipe.measuredIngredients != nil, recipe.measuredIngredients!.count > 0 else {
            throw GenerationError.missingInput
        }
        
        // Get and unwrap recipeMeasuredIngredientsArray, otherwise throw GenerationError request
        guard let recipeMeasuredIngredientsArray = recipe.measuredIngredients?.allObjects as? [RecipeMeasuredIngredient] else {
            throw GenerationError.request
        }
        
        // Delete any ingredients marked for deletion
        try await RecipeMeasuredIngredientCDClient.deleteMeasuredIngredientsMarkedForDeletion(for: recipe, in: managedContext)
        
        // Convert recipe measured ingredient array to string array using nameAndAmountModified if it can be unwrapped otherwise nameAndAmounts
        var recipeMeasuredIngredientStringArray: [String] = []
        for recipeMeasuredIngredient in recipeMeasuredIngredientsArray {
            // Ensure recipeManagedIngredient markedForDeletion is false, otherwise continue to ensure it is not appended to the string array TODO: I changed deleteOnRegenerate to markedForDeletion here, assuming they would have similar functionality or have the same functionality
            guard !recipeMeasuredIngredient.markedForDeletion else {
                continue
            }
            
            // Append nameAndAmountModified if it can be unwrapped, otherwise use nameAndAmount if it can be unwrapped
            if let nameAndAmountModified = recipeMeasuredIngredient.nameAndAmountModified {
                recipeMeasuredIngredientStringArray.append(nameAndAmountModified)
            } else if let nameAndAmount = recipeMeasuredIngredient.nameAndAmount {
                recipeMeasuredIngredientStringArray.append(nameAndAmount)
            }
        }
        
        // Create regenerateRecipeDirectionsAndIdeaRecipeIngredientsRequest
        let regenerateRecipeDirectionsAndIdeaRecipeIngredientsRequest = RegenerateRecipeMeasuredIngredientsAndDirectionsAndIdeaRecipeIngredientsRequest(
            authToken: authToken,
            recipeID: recipe.recipeID,
            newName: recipe.name,
            newSummary: recipe.summary,
            newServings: Int(recipe.estimatedServingsModified == 0 ? recipe.estimatedServings : recipe.estimatedServingsModified),
            measuredIngredients: recipeMeasuredIngredientStringArray,
            additionalInput: additionalInput)
        
        // Get regenerateRecipeDirectionsAndIdeaRecipeIngredientsResponse
        let regenerateRecipeDirectionsAndIdeaRecipeIngredientsResponse = try await ChefAppNetworkService.regenerateRecipeDirectionsAndIdeaRecipeIngredients(request: regenerateRecipeDirectionsAndIdeaRecipeIngredientsRequest)
        
        // Update estiamted servings
        if let estimatedServings = regenerateRecipeDirectionsAndIdeaRecipeIngredientsResponse.body.estimatedServings {
            try await RecipeCDClient.updateRecipe(recipe, estimatedServings: Int16(estimatedServings), in: managedContext)
        }
        
        // Update feasibility
        if let feasibility = regenerateRecipeDirectionsAndIdeaRecipeIngredientsResponse.body.feasibility {
            try await RecipeCDClient.updateRecipe(recipe, feasibility: Int16(feasibility), in: managedContext)
        }
        
        // Update measured ingredients
        let receivedMeasuredIngredients = regenerateRecipeDirectionsAndIdeaRecipeIngredientsResponse.body.allIngredientsAndMeasurements
        if !receivedMeasuredIngredients.isEmpty {
            try await RecipeMeasuredIngredientCDClient.deleteAllMeasuredIngredients(for: recipeObjectID, in: managedContext)
            try await RecipeMeasuredIngredientCDClient.appendMeasuredIngredients(ingredientsAndMeasurements: receivedMeasuredIngredients, to: recipeObjectID, in: managedContext)
        }
        
        // Update instructions
        let receivedDirections = regenerateRecipeDirectionsAndIdeaRecipeIngredientsResponse.body.instructions
        if !receivedDirections.isEmpty {
            // Map receivedDirections to index and string touple
            let receivedDirectionsWithIndices: [(index: Int16, string: String)] = receivedDirections.map({(index: Int16($0.key), string: $0.value)})//receivedDirections.enumerated().map { (index, string) in (index: Int16(index), string: string) }
            
            try await RecipeDirectionCDClient.deleteAllDirections(for: recipeObjectID, in: managedContext)
            try await RecipeDirectionCDClient.appendDirections(content: receivedDirectionsWithIndices, to: recipeObjectID, in: managedContext)
        }
    }
    
    public func saveAndUploadRecipeImageURLToServer(recipeObjectID: NSManagedObjectID, image: UIImage, imageExternalURL: URL, authToken: String, in managedContext: NSManagedObjectContext) async throws {
        // Get Recipe
        let recipe: Recipe = try await CDClient.getByObjectID(objectID: recipeObjectID, in: managedContext)
        
        // Update recipe with valid image
        try await RecipeCDClient.updateRecipe(recipe, uiImage: image, in: managedContext)
        
        // Save image URL to server
        do {
            // Save imageURL to server
            try await ChefAppNetworkService.updateRecipeImageURL(
                request: UpdateRecipeImageURLRequest(
                    authToken: authToken,
                    recipeID: Int(recipe.recipeID),
                    imageURL: imageExternalURL.absoluteString))
        } catch {
            // TODO: Handle Errors
            print("Error saving recipe image URL to server RecipeGenerator, continuing... \(error)")
        }
    }
    
//    public static func uploadRecipeImageURLToServer(authToken: String, imageURL: URL, to recipeObjectID: NSManagedObjectID, in managedContext: NSManagedObjectContext) async throws {
//        // Check if imageURL is valid
//        let isValid: Bool
//        do {
//            let (data, response) = try await URLSession.shared.data(from: imageURL)
//            if let httpResponse = response as? HTTPURLResponse,
//               httpResponse.statusCode == 200 {
//                isValid = true
//            } else {
//                isValid = false
//            }
//        } catch {
//            // TODO: Handle Errors
//            print("Error checking if image URL is valid in ChefAppNetworkPersistenceManager... \(error)")
//            throw error
//        }
//        
//        // Ensure isValid, otherwise return TODO: Research error handling in Swift and check if this should throw because it probably should
//        guard isValid else {
//            // TODO: Handle Errors
//            print("Image URL is not valid in ChefAppNetworkPersistenceManager!")
//            return
//        }
//        
//        // Save imageURL to server
//        try await ChefAppNetworkService.updateRecipeImageURL(
//            request: UpdateRecipeImageURLRequest(
//                authToken: authToken,
//                recipeID: Int(recipe.recipeID),
//                imageURL: imageURL.absoluteString))
//    }
    
}
