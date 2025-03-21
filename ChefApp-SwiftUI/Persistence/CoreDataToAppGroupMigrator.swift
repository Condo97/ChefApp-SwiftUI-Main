////
////  CoreDataToAppGroupMigrator.swift
////  ChefApp-SwiftUI
////
////  Created by Alex Coundouriotis on 11/30/24.
////
//
//import CoreData
//import Foundation
//
//class CoreDataToAppGroupMigrator {
//    
//    func needsMigration() async -> Bool {
//        // Check if old model has and new model does not have different entities
//        if await checkIfOldModelHasEntityEntryAndNewModelDoesNot(entityType: Recipe.self) {
//            return true
//        }
//        if await checkIfOldModelHasEntityEntryAndNewModelDoesNot(entityType: PantryItem.self) {
//            return true
//        }
//        // TODO: Make sure more checks are not needed
//        return false
//    }
//    
//    private func checkIfOldModelHasEntityEntryAndNewModelDoesNot<T: NSManagedObject>(entityType: T.Type) async -> Bool {
//        do {
//            let oldModelHasEntity: Bool = try await CDClient.oldManagedObjectContext.perform { try CDClient.oldManagedObjectContext.fetch(NSFetchRequest(entityName: "Recipe")).count > 0 }
//            let newModelHasEntity: Bool = try await CDClient.mainManagedObjectContext.perform { try CDClient.mainManagedObjectContext.fetch(T.fetchRequest()).count > 0 }
//            
//            if oldModelHasEntity && !newModelHasEntity {
//                return true
//            }
//        } catch {
//            print("Error checking entity entries in CoreDataToAppGroupMigrator... \(error)")
//        }
//        return false
//    }
//    
//    func migrate() async {
//        guard await needsMigration() else {
//            return
//        }
//        
//        // Migrate each entity
//        await migrateEntity(entityType: Pantry.self)
//        await migrateEntity(entityType: PantryItem.self)
//        await migrateEntity(entityType: Recipe.self)
//        await migrateEntity(entityType: RecipeDirection.self)
//        await migrateEntity(entityType: RecipeMeasuredIngredient.self)
//        await migrateEntity(entityType: RecipeTag.self)
//        await migrateEntity(entityType: ShoppingList.self)
//        await migrateEntity(entityType: ShoppingListIngredient.self)
//    }
//    
//    func migrateEntity<T: NSManagedObject>(entityType: T.Type) async {
//        do {
//            // Fetch existing objects from the old context
//            let fetchRequest = T.fetchRequest()
//            let oldModelResults = try await CDClient.oldManagedObjectContext.perform {
//                try CDClient.oldManagedObjectContext.fetch(fetchRequest) as! [T]
//            }
//            
//            // Migrate objects to the new context
//            try await CDClient.mainManagedObjectContext.perform {
//                guard let entityDescription = T.entity() as NSEntityDescription? else {
//                    print("Entity description not found for \(T.self).")
//                    return
//                }
//                
//                let attributes = entityDescription.attributesByName
//                let relationships = entityDescription.relationshipsByName
//                
//                var oldToNewMapping: [NSManagedObjectID: NSManagedObject] = [:]
//                
//                // First, copy attribute values
//                for oldObject in oldModelResults {
//                    // Create a new object in the new context
//                    let newObject = T(context: CDClient.mainManagedObjectContext)
//                    
//                    // Map old object ID to new object for relationships
//                    oldToNewMapping[oldObject.objectID] = newObject
//                    
//                    // Copy attribute values
//                    for (attributeName, _) in attributes {
//                        let value = oldObject.value(forKey: attributeName)
//                        newObject.setValue(value, forKey: attributeName)
//                    }
//                }
//                
//                // Then, set up relationships
//                for oldObject in oldModelResults {
//                    if let newObject = oldToNewMapping[oldObject.objectID] {
//                        for (relationshipName, relationshipDescription) in relationships {
//                            if relationshipDescription.isToMany {
//                                let oldRelatedObjects = oldObject.mutableSetValue(forKey: relationshipName)
//                                let newRelatedObjects = NSMutableSet()
//                                for oldRelatedObject in oldRelatedObjects {
//                                    if let oldRelatedManagedObject = oldRelatedObject as? NSManagedObject,
//                                       let newRelatedObject = oldToNewMapping[oldRelatedManagedObject.objectID] {
//                                        newRelatedObjects.add(newRelatedObject)
//                                    }
//                                }
//                                newObject.setValue(newRelatedObjects, forKey: relationshipName)
//                            } else {
//                                if let oldRelatedObject = oldObject.value(forKey: relationshipName) as? NSManagedObject,
//                                   let newRelatedObject = oldToNewMapping[oldRelatedObject.objectID] {
//                                    newObject.setValue(newRelatedObject, forKey: relationshipName)
//                                }
//                            }
//                        }
//                    }
//                }
//                
//                // Save the new context after migration
//                if CDClient.mainManagedObjectContext.hasChanges {
//                    try CDClient.mainManagedObjectContext.save()
//                }
//            }
//        } catch {
//            print("Error migrating entity in CoreDataToAppGroupMigrator... \(error)")
//        }
//    }
//    
//}
