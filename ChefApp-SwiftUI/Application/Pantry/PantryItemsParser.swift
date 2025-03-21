//
//  PantryItemsParser.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 6/22/24.
//

import CoreData
import Foundation
import UIKit

class PantryItemsParser: ObservableObject {
    
    @Published var isLoadingGetPantryItemsFromImage: Bool = false
    @Published var isLoadingParseSavePantryItems: Bool = false
    
    func parseGetPantryItemsFromImage(image: UIImage, input: String?) async throws -> [(name: String, category: String?)] {
        // Defer setting isLoading to false
        defer {
            DispatchQueue.main.async {
                self.isLoadingGetPantryItemsFromImage = false
            }
        }
        
        // Set isLoading to true
        await MainActor.run {
            isLoadingGetPantryItemsFromImage = true
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
        
        // Create parse pantry items request with image and input
        let parsePantryItemsRequest = ParsePantryItemsRequest(
            authToken: authToken,
            input: input,
            imageDataInput: ImageResizer.resizedJpegDataTo(size: .size_1536, from: image))
        
        // Do parse pantry items request and get parse pantry items response
        let parsePantryItemsResponse = try await ChefAppNetworkService.parsePantryItems(request: parsePantryItemsRequest)
        
        // Return pantry items received
        return parsePantryItemsResponse.body.pantryItems.compactMap({
            if let name = $0.item {
                return (name: name.capitalized, category: $0.category?.capitalized)
            } else {
                return nil
            }
        })
    }
    
//    func parseSavePantryItems(image: UIImage, input: String?, in managedContext: NSManagedObjectContext) async throws {
//        // Defer setting isLoading to false
//        defer {
//            DispatchQueue.main.async {
//                self.isLoadingParseSavePantryItems = false
//            }
//        }
//        
//        // Parse get pantry items from image
//        let pantryItems = try await parseGetPantryItemsFromImage(image: image, input: input)
//        
//        // Set isLoading to true TODO: Is this good practice since isLoading is also used by parseGetPantryItemsFromImage, is it fine, or should I just have a different variable?
//        await MainActor.run {
//            isLoadingParseSavePantryItems = true
//        }
//        
//        // Create duplicatePantryItemNames to track duplicate pantry items when inserting
//        var duplicatePantryItemNames: [String] = []
//        
//        // Save to persistence
//        for pantryItem in pantryItems {
//            do {
//                try await PantryItemCDClient.appendPantryItem(name: pantryItem.name.capitalized, category: pantryItem.category?.capitalized, in: managedContext)
//            } catch PersistenceError.duplicateObject {
//                print("Duplicate PantryItem found when appending pantry item")
//                duplicatePantryItemNames.append(pantryItem.name.capitalized)
//            }
//        }
//        
//        // Throw duplicate error if duplicate items were found TODO: Is this good practice?
//        if !duplicatePantryItemNames.isEmpty {
//            throw PantryItemPersistenceError.duplicatePantryItemNames(duplicatePantryItemNames)
//        }
//    }
    
    // TODO: This being here is disorganized, find a better place and move it
    func parseSavePantryItems(input: String?, in managedContext: NSManagedObjectContext) async throws {
        // Defer setting isLoading to false
        defer {
            DispatchQueue.main.async {
                self.isLoadingParseSavePantryItems = false
            }
        }
        
        // Set isLoading to true
        await MainActor.run {
            isLoadingParseSavePantryItems = true
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
        
        // Parse save pantry items
        try await ChefAppNetworkPersistenceManager.shared.parseSavePantryItems(
            authToken: authToken,
            input: input,//automaticEntryItems.joined(separator: ", ") + "\n" + automaticEntryText,
            in: managedContext)
    }
    
    
}
