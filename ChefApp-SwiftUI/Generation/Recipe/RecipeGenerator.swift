//
//  RecipeGenerator.swift
//  Barback
//
//  Created by Alex Coundouriotis on 9/25/23.
//

import CoreData
import Foundation
import SwiftUI

class RecipeGenerator: ObservableObject {
    
    enum Errors: Error {
        case capReached
    }
    
    
    @Published var isCreating: Bool = false
    
    func create(
        ingredients: String,
        modifiers: String?,
        expandIngredientsMagnitude: Int,
        authToken: String,
        in viewContext: NSManagedObjectContext
    ) async throws -> Recipe {
        defer {
            Task {
                await MainActor.run { [weak self] in
                    self?.isCreating = false
                }
            }
        }
        
        await MainActor.run { [weak self] in
            self?.isCreating = true
        }
        
        return try await create(
            ingredients: ingredients,
            modifiers: modifiers,
            expandIngredientsMagnitude: expandIngredientsMagnitude,
            dailyRecipe_isDailyRecipe: false,
            dailyRecipe_timeFrameID: nil,
            authToken: authToken,
            in: viewContext)
    }
    
    func create(
        ingredients: String,
        modifiers: String?,
        expandIngredientsMagnitude: Int,
        dailyRecipe_isDailyRecipe: Bool,
        dailyRecipe_timeFrameID: String?,
        authToken: String,
        in viewContext: NSManagedObjectContext
    ) async throws -> Recipe {
        defer {
            Task {
                await MainActor.run { [weak self] in
                    self?.isCreating = false
                }
            }
        }
        
        await MainActor.run { [weak self] in
            self?.isCreating = true
        }
        
        // Create and save and return recipe
        return try await ChefAppNetworkPersistenceManager.shared.createSaveRecipe(
            authToken: authToken,
            ingredients: ingredients,
            modifiers: modifiers,
            expandIngredientsMagnitude: expandIngredientsMagnitude,
            dailyRecipe_isDailyRecipe: dailyRecipe_isDailyRecipe,
            dailyRecipe_timeFrameID: dailyRecipe_timeFrameID,
            in: viewContext)
    }
    
}
