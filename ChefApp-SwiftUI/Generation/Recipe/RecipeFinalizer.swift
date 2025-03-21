//
//  RecipeFinalizer.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 3/16/25.
//

import CoreData
import Foundation

class RecipeFinalizer: ObservableObject {
    
    @Published var isFinalizing: Bool = false
    
    func finalize(
        recipeObjectID: NSManagedObjectID,
        additionalInput: String?,
        authToken: String,
        in viewContext: NSManagedObjectContext
    ) async throws {
        defer {
            Task {
                await MainActor.run { [weak self] in
                    self?.isFinalizing = false
                }
            }
        }
        
        await MainActor.run { [weak self] in
            self?.isFinalizing = true
        }
        
        // Finalize and save recipe
        try await ChefAppNetworkPersistenceManager.shared.finalizeUpdateRecipe(
            authToken: authToken,
            recipeObjectID: recipeObjectID,
            additionalInput: additionalInput,
            in: viewContext)
    }
    
}
