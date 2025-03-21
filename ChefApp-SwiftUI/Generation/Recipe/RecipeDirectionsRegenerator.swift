//
//  RecipeRegenerator.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 3/16/25.
//

import CoreData
import Foundation

class RecipeDirectionsRegenerator: ObservableObject {

    @Published var isRegeneratingDirections: Bool = false

    func regenerateDirectionsAndResolveUpdatedIngredients(
        for recipeObjectID: NSManagedObjectID,
        additionalInput: String,
        authToken: String,
        in managedContext: NSManagedObjectContext
    ) async throws {
        defer {
            Task {
                await MainActor.run { [weak self] in
                    self?.isRegeneratingDirections = false
                }
            }
        }

        await MainActor.run { [weak self] in
            self?.isRegeneratingDirections = true
        }

        // Get and save regenerated directions
        try await ChefAppNetworkPersistenceManager.shared.regenerateSaveMeasuredIngredientsAndDirectionsAndResolveUpdatedIngredients(
                authToken: authToken,
                recipeObjectID: recipeObjectID,
                additionalInput: additionalInput,
                in: managedContext)
    }

}
