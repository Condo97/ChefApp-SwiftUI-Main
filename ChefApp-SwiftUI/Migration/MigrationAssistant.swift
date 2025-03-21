//
//  MigrationAssistant.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 12/10/24.
//

import CoreData
import Foundation
import UIKit

class MigrationAssistant {
    
    static func migrateCoreDataImagesToAppGroupSaveLocations(in managedContext: NSManagedObjectContext) async {
        // Get Recipes
        let recipes: [Recipe]
        do {
            let fetchRequest = Recipe.fetchRequest()
            fetchRequest.fetchLimit = 15
            fetchRequest.predicate = NSPredicate(format: "%K != nil", #keyPath(Recipe.imageData))
            recipes = try await managedContext.perform { try managedContext.fetch(fetchRequest) }
        } catch {
            // TODO: Handle Errors
            print("Error fetching recipes in MigrationAssistant... \(error)")
            return
        }
        
        // If no more recipes return
        if recipes.isEmpty {
            return
        }
        
        // Migrate each Recipe's image and delete the imageData
        for recipe in recipes {
            let image = await managedContext.perform {
                if let imageData = recipe.imageData {
                    return UIImage(data: imageData)
                }
                
                return nil
            }
            
            if let image {
                do {
                    try await RecipeCDClient.updateRecipe(recipe, uiImage: image, in: managedContext)
                } catch {
                    // TODO: Handle Errors
                    print("Error updating recipe with image in app group location in MigrationAssistant, continuing... \(error)")
                }
            }
            
            do {
                try await managedContext.perform {
                    recipe.imageData = nil
                    
                    try managedContext.save()
                }
            } catch {
                // TODO: Handle Errors
                print("Error updating and saving recipe imageData in MigrationAssistant, continuing... \(error)")
            }
        }
        
        // Call recursively
        await migrateCoreDataImagesToAppGroupSaveLocations(in: managedContext)
    }
    
}
