//
//  RecipeDirectionCDClient.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 6/18/24.
//

import CoreData
import Foundation

class RecipeDirectionCDClient {
    
    /***
     Append  Direction
     
     Appends and saves a direction for a recipe
     */
    
    static func appendDirection(index: Int16, string: String, to recipeObjectID: NSManagedObjectID, in managedContext: NSManagedObjectContext) async throws {
        let recipe: Recipe = try await CDClient.getByObjectID(objectID: recipeObjectID, in: managedContext)
        
        try await appendDirection(index: index, string: string, to: recipe, in: managedContext)
    }
    
    static func appendDirections(content: [(index: Int16, string: String)], to recipeObjectID: NSManagedObjectID, in managedContext: NSManagedObjectContext) async throws {
        let recipe: Recipe = try await CDClient.getByObjectID(objectID: recipeObjectID, in: managedContext)
        
        try await appendDirections(content: content, to: recipe, in: managedContext)
    }
    
    
    private static func appendDirection(index: Int16, string: String, to recipe: Recipe, in managedContext: NSManagedObjectContext) async throws {
        try await managedContext.perform {
            let recipeDirection = RecipeDirection(context: managedContext)
            
            recipeDirection.index = index
            recipeDirection.string = string
            recipeDirection.recipe = recipe
            
            try managedContext.save()
        }
    }
        
    private static func appendDirections(content: [(index: Int16, string: String)], to recipe: Recipe, in managedContext: NSManagedObjectContext) async throws {
        try await managedContext.perform {
            for contentItem in content {
                let recipeDirection = RecipeDirection(context: managedContext)
                
                recipeDirection.index = contentItem.index
                recipeDirection.string = contentItem.string
                recipeDirection.recipe = recipe
            }
            
            try managedContext.save()
        }
    }
    
    /***
     Delete All Directions
     
     Deletes all directions for a recipe
     */
    
    static func deleteAllDirections(for recipeObjectID: NSManagedObjectID, in managedContext: NSManagedObjectContext) async throws {
        let recipe: Recipe = try await CDClient.getByObjectID(objectID: recipeObjectID, in: managedContext)
        
        try await deleteAllDirections(for: recipe, in: managedContext)
    }
    
    
    private static func deleteAllDirections(for recipe: Recipe, in managedContext: NSManagedObjectContext) async throws {
        let fetchRequest = RecipeDirection.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(RecipeDirection.recipe), recipe)
        
        try await CDClient.delete(fetchRequest: fetchRequest, in: managedContext)
    }
    
}
