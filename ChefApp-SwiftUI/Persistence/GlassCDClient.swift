////
////  GlassCDClient.swift
////  Barback
////
////  Created by Alex Coundouriotis on 9/19/23.
////
//
//import CoreData
//import Foundation
//
//class GlassCDClient {
//    
//    static let glassEntityName = String(describing: Glass.self)
//    
//    static func appendGlass(name: String, imageData: Data) async throws {
//        // Build and save new glass
//        try await CDClient.buildAndSave(named: glassEntityName) { managedObject in
//            guard let glass = managedObject as? Glass else {
//                // TODO: Handle errors
//                return
//            }
//            
//            glass.name = name
//            glass.imageData = imageData
//        }
//    }
//    
//    static func deleteGlasses(named name: String) async throws {
//        // Create fetch request to get Glass by name
//        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: glassEntityName)
//        fetchRequest.predicate = NSPredicate(format: "%k = %@", #keyPath(Glass.name), name)
//        
//        // Get permanentIDs for fetch request
//        let permanentIDs = try await CDClient.getPermanentIDs(fetchRequest)
//        
//        // Loop through and delete each object ID in permanentIDs
//        for permanentID in permanentIDs {
//            try await CDClient.delete(managedObjectID: permanentID)
//        }
//    }
//    
//    static func getImageDataBy(name: String) async throws -> Data? {
//        // Create fetch request to get Glass by name
//        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: glassEntityName)
//        fetchRequest.predicate = NSPredicate(format: "%k = %@", #keyPath(Glass.name), name)
//        
//        // Get permanent ID for fetch request
//        let permanentIDs = try await CDClient.getPermanentIDs(fetchRequest)
//        
//        // Ensure there are not 0 permanent IDs, otherwise return nil
//        guard permanentIDs.count > 0 else {
//            // TODO: Handle errors
//            print("No image data found for name in getImageDataBy in GlassCDClient!")
//            return nil
//        }
//        
//        // If there are more than 1 permanent ID, print to console and maybe handle error
//        if permanentIDs.count > 1 {
//            print("Multiple images' data found for name in getImageDataBy in GlassCDClient!")
//        }
//        
//        // Get the image by the first permanent ID in context and return its imageData
//        return try await CDClient.doInContext(managedObjectID: permanentIDs[0])  { managedObject in
//            guard let glass = managedObject as? Glass else {
//                // TODO: Handle errors
//                print("Could not unwrap managedObject as GLass in getImageDataBy in GlassCDClient!")
//                return nil
//            }
//            
//            return glass.imageData
//        }
//    }
//    
//}
