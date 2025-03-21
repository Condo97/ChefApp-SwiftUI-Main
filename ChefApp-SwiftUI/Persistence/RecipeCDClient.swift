//
//  RecipeCDClient.swift
//  Barback
//
//  Created by Alex Coundouriotis on 9/17/23.
//

import CoreData
import Foundation
import SwiftUI

class RecipeCDClient {
    
    static let recipeEntityName = String(describing: Recipe.self)
    static let recipeMeasuredIngredientEntityName = String(describing: RecipeMeasuredIngredient.self)
    static let recipeDirectionEntityName = String(describing: RecipeDirection.self)
    
    /***
     Append Recipe
     
     Appends and saves recipe
     */
    
    static func appendRecipe(recipeID: Int64, input: String?, saved: Bool = false, dailyRecipe_isDailyRecipe: Bool, dailyRecipe_timeFrameID: String?, name: String?, summary: String?, feasibility: Int16?, tastiness: Int16?, in managedContext: NSManagedObjectContext) async throws -> Recipe {
        // Build and save new recipe
        try await managedContext.perform {
            let recipe = Recipe(context: managedContext)
            
            recipe.recipeID = recipeID
            recipe.input = input
            recipe.saved = saved
            recipe.dailyRecipe_isDailyRecipe = dailyRecipe_isDailyRecipe
            recipe.dailyRecipe_timeFrameID = dailyRecipe_timeFrameID
            recipe.name = name
            recipe.summary = summary
            recipe.creationDate = Date()
            recipe.updateDate = Date()
            
            if let feasibility = feasibility {
                recipe.feasibility = feasibility
            }
            
            if let tastiness = tastiness {
                recipe.tastiness = tastiness
            }
            
            try managedContext.save()
            
            return recipe
        }
    }
    
    /***
     Count By
     
     Counts recipes by recipe ID and recipe object ID
     */
    static func countBy(recipeID: Int64, in managedContext: NSManagedObjectContext) async throws -> Int {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: recipeMeasuredIngredientEntityName)
        fetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(Recipe.recipeID), recipeID)
        
        return try await CDClient.count(fetchRequest: fetchRequest, in: managedContext)
    }
    
    /***
     Update Recipe
     
     Updates a recipe
     */
    
    static func updateRecipe(_ recipe: Recipe, dailyRecipe_isDailyRecipe: Bool, in managedContext: NSManagedObjectContext) async throws {
        try await update(recipe, updater: { $0.dailyRecipe_isDailyRecipe = dailyRecipe_isDailyRecipe }, in: managedContext)
    }
    
    static func updateRecipe(_ recipe: Recipe, dailyRecipe_timeFrameID: String?, in managedContext: NSManagedObjectContext) async throws {
        try await update(recipe, updater: { $0.dailyRecipe_timeFrameID = dailyRecipe_timeFrameID }, in: managedContext)
    }
    
    static func updateRecipe(_ recipe: Recipe, saved: Bool, in managedContext: NSManagedObjectContext) async throws {
        try await update(recipe, updater: { $0.saved = saved }, in: managedContext)
    }
    
    static func updateRecipe(_ recipe: Recipe, sourceTikTokVideoID: String, in managedContext: NSManagedObjectContext) async throws {
        try await update(recipe, updater: { $0.sourceTikTokVideoID = sourceTikTokVideoID }, in: managedContext)
    }

    static func updateRecipe(_ recipe: Recipe, recipeID: Int64, in managedContext: NSManagedObjectContext) async throws {
        try await update(recipe, updater: { $0.recipeID = recipeID }, in: managedContext)
    }

    static func updateRecipe(_ recipe: Recipe, input: String, in managedContext: NSManagedObjectContext) async throws {
        try await update(recipe, updater: { $0.input = input }, in: managedContext)
    }

    static func updateRecipe(_ recipe: Recipe, name: String, in managedContext: NSManagedObjectContext) async throws {
        try await update(recipe, updater: { $0.name = name }, in: managedContext)
    }

    static func updateRecipe(_ recipe: Recipe, summary: String, in managedContext: NSManagedObjectContext) async throws {
        try await update(recipe, updater: { $0.summary = summary }, in: managedContext)
    }

    static func updateRecipe(_ recipe: Recipe, estimatedServings: Int16, in managedContext: NSManagedObjectContext) async throws {
        try await update(recipe, updater: { $0.estimatedServings = estimatedServings }, in: managedContext)
    }
    
    static func updateRecipe(_ recipe: Recipe, estimatedTotalCalories: Int16, in managedContext: NSManagedObjectContext) async throws {
        try await update(recipe, updater: { $0.estimatedTotalCalories = estimatedTotalCalories }, in: managedContext)
    }
    
    static func updateRecipe(_ recipe: Recipe, estimatedTotalMinutes: Int16, in managedContext: NSManagedObjectContext) async throws {
        try await update(recipe, updater: { $0.estimatedTotalMinutes = estimatedTotalMinutes }, in: managedContext)
    }

    static func updateRecipe(_ recipe: Recipe, expandIngredientsMagnitude: Int16, in managedContext: NSManagedObjectContext) async throws {
        try await update(recipe, updater: { $0.expandIngredientsMagnitude = expandIngredientsMagnitude }, in: managedContext)
    }

    static func updateRecipe(_ recipe: Recipe, feasibility: Int16, in managedContext: NSManagedObjectContext) async throws {
        try await update(recipe, updater: { $0.feasibility = feasibility }, in: managedContext)
    }

    static func updateRecipe(_ recipe: Recipe, tastiness: Int16, in managedContext: NSManagedObjectContext) async throws {
        try await update(recipe, updater: { $0.tastiness = tastiness }, in: managedContext)
    }
    
    static func updateRecipe(_ recipe: Recipe, uiImage: UIImage, in managedContext: NSManagedObjectContext) async throws {
        guard let imageData = uiImage.jpegData(compressionQuality: 7) else {
            // TODO: Handle errors
            print("Could not unwrap imageData when updating recipe image in RecipeCDClient!")
            return
        }
        
        let dataLocation = UUID().uuidString
        AppGroupSaver(appGroupIdentifier: Constants.Additional.appGroupID).saveData(imageData, to: dataLocation)
        try await update(recipe, updater: { $0.imageAppGroupLocation = dataLocation }, in: managedContext)
    }

    static func updateRecipe(_ recipe: Recipe, updateDate: Date, in managedContext: NSManagedObjectContext) async throws {
        try await update(recipe, updater: { $0.updateDate = updateDate }, in: managedContext)
    }
    
    static func updateRecipe(_ recipe: Recipe, likeState: RecipeLikeState, in managedContext: NSManagedObjectContext) async throws {
        try await update(recipe, updater: { $0.likeState = Int16(likeState.rawValue) }, in: managedContext)
    }
    
    static func update(_ recipe: Recipe, updater: @escaping (Recipe) -> Void, in managedContext: NSManagedObjectContext) async throws {
        try await managedContext.perform {
            updater(recipe)
            try managedContext.save()
        }
    }
    
}

