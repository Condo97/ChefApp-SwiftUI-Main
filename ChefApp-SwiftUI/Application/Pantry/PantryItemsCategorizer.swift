//
//  PantryItemsCategorizer.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 6/22/24.
//

import CoreData
import Foundation

class PantryItemsCategorizer: ObservableObject {
    
    @Published var isLoading: Bool = false
    
    
    func categorizePantryItems(in managedContext: NSManagedObjectContext) async throws {
        // Defer setting isLoading to false
        defer {
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
        
        // Set isLoading to true
        await MainActor.run {
            isLoading = true
        }
        
        // Get authToken with AuthHelper ensure
        let authToken: String
        do {
            authToken = try await AuthHelper.ensure()
        } catch {
            // TODO: Handle errors
            print("Error ensuring authToken when creating Recipe in RecipeGenerator... \(error)")
            throw GenerationError.auth
        }
        
        // Categorize save update all pantry items
        try await ChefAppNetworkPersistenceManager.shared.categorizeSaveUpdateAllPantryItems(authToken: authToken, in: managedContext)
    }
    
}
