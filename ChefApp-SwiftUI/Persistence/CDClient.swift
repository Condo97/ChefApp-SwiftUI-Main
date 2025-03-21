//
//  CDClient.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/18/23.
//

import CoreData
import Foundation
import UIKit

class CDClient: Any {
    
    internal static let modelName: String = Constants.Additional.coreDataModelName
    
    private static let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: modelName)

        // New store location (app group URL)
        guard let appGroupStoreURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.Additional.appGroupID)?.appendingPathComponent("\(modelName)") else {
            fatalError("Could not find CoreData model!")
        }

        // Old store location (default URL)
        let defaultStoreURL = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("\(modelName).sqlite")

        // Determine which store URL to use
        let storeURL: URL
        let fileManager = FileManager.default

        if fileManager.fileExists(atPath: appGroupStoreURL.path) {
            // Use the new store URL if it exists
            storeURL = appGroupStoreURL
        } else if fileManager.fileExists(atPath: defaultStoreURL.path) {
            // Use the old store URL to perform migration
            storeURL = defaultStoreURL
        } else {
            // Neither store exists; set to new store URL
            storeURL = appGroupStoreURL
        }

        let description = NSPersistentStoreDescription(url: storeURL)
        container.persistentStoreDescriptions = [description]

        // Perform migration if needed
        do {
            try migrateStoreIfNeeded(for: container, storeURL: storeURL, appGroupStoreURL: appGroupStoreURL, defaultStoreURL: defaultStoreURL)
        } catch {
            // TODO: Handle Errors
            print("Error migrating store, using old store... \(error)")
        }

        // Load the persistent stores
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
            }
        })

        return container

    }()

    private static func migrateStoreIfNeeded(for container: NSPersistentContainer, storeURL: URL, appGroupStoreURL: URL, defaultStoreURL: URL) throws {
        let fileManager = FileManager.default

        // Check if migration is needed (old store exists and new store does not)
        if storeURL == defaultStoreURL && fileManager.fileExists(atPath: defaultStoreURL.path) {
            // Initialize a persistent store coordinator with your model
            let coordinator = NSPersistentStoreCoordinator(managedObjectModel: container.managedObjectModel)
            
            // Add the old store to the coordinator
            let oldStore = try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: defaultStoreURL, options: nil)
            
            // Migrate the store to the new location
            let _ = try coordinator.migratePersistentStore(oldStore, to: appGroupStoreURL, options: nil, withType: NSSQLiteStoreType)
            
            // Remove old store files
            try coordinator.destroyPersistentStore(at: defaultStoreURL, ofType: NSSQLiteStoreType, options: nil)
            let shmFile = defaultStoreURL.deletingPathExtension().appendingPathExtension("sqlite-shm")
            let walFile = defaultStoreURL.deletingPathExtension().appendingPathExtension("sqlite-wal")
            if fileManager.fileExists(atPath: shmFile.path) {
                try fileManager.removeItem(at: shmFile)
            }
            if fileManager.fileExists(atPath: walFile.path) {
                try fileManager.removeItem(at: walFile)
            }
            
            // Update the store description to point to the new store URL
            container.persistentStoreDescriptions.first?.url = appGroupStoreURL
        }
    }
    
    public static let mainManagedObjectContext: NSManagedObjectContext = persistentContainer.viewContext
    
    private static let oldPersistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: modelName)
        container.loadPersistentStores(completionHandler: {description, error in
            if let error = error as? NSError {
                fatalError("Couldn't load persistent stores!\n\(error)\n\(error.userInfo)")
            }
        })
        return container
    }()
    
    public static let oldManagedObjectContext: NSManagedObjectContext = oldPersistentContainer.viewContext
    
    
    internal static func count<O: NSManagedObject>(fetchRequest: NSFetchRequest<O>, in managedContext: NSManagedObjectContext) async throws -> Int {
        return try await managedContext.perform {
            // Get count and return
            let count = try managedContext.count(for: fetchRequest)
            return count
        }
    }

    internal static func count(entityName: String, in managedContext: NSManagedObjectContext) async throws -> Int {
        return try await managedContext.perform {
            // Create fetch request
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
            // Get count and return
            let count = try managedContext.count(for: fetchRequest)
            return count
        }
    }

    internal static func doInContext<T>(managedObjectID: NSManagedObjectID, in managedContext: NSManagedObjectContext, block: @escaping (NSManagedObject) -> T?) async throws -> T? {
        return try await managedContext.perform {
            let managedObject = try managedContext.existingObject(with: managedObjectID)
            return block(managedObject)
        }
    }

    internal static func getPermanentIDs(_ fetchRequest: NSFetchRequest<NSManagedObject>, in managedContext: NSManagedObjectContext) async throws -> [NSManagedObjectID] {
        return try await managedContext.perform {
            // Perform fetchRequest
            let managedObjects = try managedContext.fetch(fetchRequest)
            // Obtain permanent IDs for all managedObjects
            try managedContext.obtainPermanentIDs(for: managedObjects)
            // Return managedObjects mapped to array of their objectIDs
            return managedObjects.map({ $0.objectID })
        }
    }

    internal static func delete(_ managedObject: NSManagedObject, in managedContext: NSManagedObjectContext) async throws {
        // Delete
        try await managedContext.perform {
            // Delete managedObject
            managedContext.delete(managedObject)
            
            // Save managedContext
            try managedContext.save()
        }
    }
    
    static func delete<T: NSManagedObject>(fetchRequest: NSFetchRequest<T>, in managedContext: NSManagedObjectContext) async throws {
        try await managedContext.perform {
            for result in try managedContext.fetch(fetchRequest) {
                managedContext.delete(result)
                
                try managedContext.save()
            }
        }
    }
    
    static func getByObjectID<T: NSManagedObject>(objectID: NSManagedObjectID, in managedContext: NSManagedObjectContext) async throws -> T {
        return try await managedContext.perform {
            // Get and return managedObject as existing object with managedObjectID
            guard let object = try managedContext.existingObject(with: objectID) as? T else {
                throw CDClientErrors.invalidObjectCast
            }
            
            return object
        }
    }

    internal static func update(managedObjectID: NSManagedObjectID, in managedContext: NSManagedObjectContext, updater: @escaping (NSManagedObject) -> Void) async throws {
        return try await managedContext.perform {
            // Get managedObject as existing object with managedObjectID
            let managedObject = try managedContext.existingObject(with: managedObjectID)
            // Do updater
            updater(managedObject)
            // Save managedContext
            try managedContext.save()
        }
    }

    private static func parsePredicateFromWhereColValMap(whereColValMap: [String: CVarArg]) -> NSPredicate {
        // Create predicate array
        var predicates: [NSPredicate] = []
        // Append to predicates
        whereColValMap.forEach { key, value in
            predicates.append(NSPredicate(format: "%K = %@", key, value as! CVarArg))
        }
        // Return NSCompoundPredicate with the predicates in the array
        return NSCompoundPredicate(type: .and, subpredicates: predicates)
    }
    
    
}

