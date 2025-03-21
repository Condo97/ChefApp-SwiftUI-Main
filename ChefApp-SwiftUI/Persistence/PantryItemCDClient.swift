//
//  PantryItemCDClient.swift
//  Barback
//
//  Created by Alex Coundouriotis on 9/18/23.
//

import CoreData
import Foundation

class PantryItemCDClient {
    
    static let pantryItemEntityName = String(describing: PantryItem.self)
    
    static func appendPantryItem(name: String, category: String?, in managedContext: NSManagedObjectContext) async throws {
        let fetchRequest = PantryItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(PantryItem.name), name)
        guard try await CDClient.count(fetchRequest: fetchRequest, in: managedContext) == 0 else {
            // TODO: Handle errors for duplication!
            print("Duplicate found and not saved in appendPantryItem!")
            throw PersistenceError.duplicateObject
        }
        
        // Build and save new pantry item
        try await managedContext.perform {
            let pantryItem = PantryItem(context: managedContext)
            
            pantryItem.name = name
            pantryItem.category = category
            pantryItem.updateDate = Date()
            
            try managedContext.save()
        }
    }
    
    static func updateAll(newPantryItems: [(name: String, category: String)], in managedContext: NSManagedObjectContext) async throws {
//        // Delete all pantry items
//        let fetchRequest = PantryItem.fetchRequest()
//        try await CDClient.delete(fetchRequest: fetchRequest, in: managedContext)
        
        // Get all pantry items
        let fetchRequest = PantryItem.fetchRequest()
        let pantryItems = try await managedContext.perform {
            try managedContext.fetch(fetchRequest)
        }
        
        // Attemt to match pantry items by name case insensitive
        for pantryItem in pantryItems {
            if let matchedNewPantryItem = newPantryItems.first(where: {$0.name == pantryItem.name}) {
                // For the matched items, update their category
                do {
                    try await PantryItemCDClient.updatePantryItem(pantryItem, category: matchedNewPantryItem.category, in: managedContext)
                } catch {
                    // TODO: Handle Errors
                    print("Error updating pantry item in PantryItemCDClient, continuing... \(error)")
                    continue
                }
            } else {
                // For the unmatched pantry items in the store originally, do nothing
                print("\(pantryItem.name ?? "Pantry Item") - Pantry item in store not matched to new pantry item when re-sorting, continuing...")
            }
        }
        
        // For the unmatched newPantryItems, add them
        let unmatchedNewPantryItems = newPantryItems.filter { newPantryItem in
            !pantryItems.contains(where: {$0.name == newPantryItem.name})
        }
        for unmatchedNewPantryItem in unmatchedNewPantryItems {
            do {
                print("\(unmatchedNewPantryItem.name) - Adding unmatched pantry item from newPantryItems")
                try await PantryItemCDClient.appendPantryItem(
                    name: unmatchedNewPantryItem.name,
                    category: unmatchedNewPantryItem.category,
                    in: managedContext)
            } catch {
                // TODO: Handle Errors
                print("Error appending pantry item in PantryItemCDClient, continuing... \(error)")
            }
        }
        
        
//        // Save all new pantry items
//        // Build and save new pantry item
//        try await managedContext.perform {
//            for newPantryItem in newPantryItems {
//                let pantryItem = PantryItem(context: managedContext)
//                
//                pantryItem.name = newPantryItem.name
//                pantryItem.category = newPantryItem.category
////                pantryItem.updateDate = Date()
//            }
//            
//            try managedContext.save()
//        }
    }
    
    static func updatePantryItem(_ pantryItem: PantryItem, name: String, in managedContext: NSManagedObjectContext) async throws {
        try await update(pantryItem, updater: {$0.name = name}, in: managedContext)
    }
    
    static func updatePantryItem(_ pantryItem: PantryItem, category: String?, in managedContext: NSManagedObjectContext) async throws {
        try await update(pantryItem, updater: {$0.category = category}, in: managedContext)
    }
    
    static func updatePantryItem(_ pantryItem: PantryItem, updateDate: Date, in managedContext: NSManagedObjectContext) async throws {
        try await update(pantryItem, setUpdateDate: false, updater: {$0.updateDate = updateDate}, in: managedContext)
    }
    
    
    private static func update(_ pantryItem: PantryItem, setUpdateDate: Bool = true, updater: @escaping ((PantryItem)->Void), in managedContext: NSManagedObjectContext) async throws {
        try await managedContext.perform {
            if setUpdateDate {
                pantryItem.updateDate = Date()
            }
            
            updater(pantryItem)
            
            try managedContext.save()
        }
    }
    
}
