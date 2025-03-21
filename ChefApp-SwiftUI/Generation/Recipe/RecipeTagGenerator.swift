//
//  RecipeTagGenerator.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 3/16/25.
//

import CoreData
import Foundation

class RecipeTagGenerator: ObservableObject {
    
    @Published var isGeneratingTags: Bool = false
    
    func generateTags(
        recipe: Recipe,
        authToken: String,
        in viewContext: NSManagedObjectContext
    ) async throws {
        defer {
            Task {
                await MainActor.run { [weak self] in
                    self?.isGeneratingTags = false
                }
            }
        }
        
        await MainActor.run { [weak self] in
            self?.isGeneratingTags = true
        }
        
        // Generate and save tags
        try await ChefAppNetworkPersistenceManager.shared.generateSaveTags(
            authToken: authToken,
            recipe: recipe,
            in: viewContext)
    }
    
}
