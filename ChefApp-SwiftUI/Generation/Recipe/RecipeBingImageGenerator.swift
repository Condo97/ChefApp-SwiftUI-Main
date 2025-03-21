//
//  RecipeBingImageGenerator.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 3/15/25.
//

import CoreData
import Foundation
import UIKit

class RecipeBingImageGenerator: ObservableObject {
    
    @Published var isGenerating: Bool = false
    
    
    enum Errors: Error {
        case invalidQuery
        case invalidImageResult
    }
    
    
    func generateBingImage(
        recipeObjectID: NSManagedObjectID,
        authToken: String,
        in managedContext: NSManagedObjectContext
    ) async throws {
        defer {
            Task {
                await MainActor.run { [weak self] in
                    self?.isGenerating = false
                }
            }
        }
        
        await MainActor.run { [weak self] in
            self?.isGenerating = true
        }
        
        // Get recipe
        let recipe: Recipe = try await CDClient.getByObjectID(objectID: recipeObjectID, in: managedContext)
        
        // Ensure unwrap query as recipe name
        guard let query = recipe.name else {
            // TODO: [Error Handling] Handle Errors
            print("No name for recipe therefore no query in RecipeBingImageGenerator!")
            throw Errors.invalidQuery
        }
        
        // Get four images for the recipe name, and save the first image received if any
        let (imageURLs, queryCount) = try await BingSearchClient.getImages(
            query: query,
            count: 4,
            offset: 0)
        
        var validImage: UIImage?
        var validImageURL: URL?
        for imageURL in imageURLs {
            let urlRequest = URLRequest(url: imageURL)
            
            do {
                // Do request
                let (data, response) = try await URLSession.shared.data(for: urlRequest)
                
                // Parse data to image and save if successful
                if let image = UIImage(data: data) {
                    // Set validImage and validImageURL since they are successfully found
                    validImage = image
                    validImageURL = imageURL
                    
                    // Break for loop
                    break
                }
            } catch {
                print("Error getting response when getting images from Bing search response in ChefAppNetworkPersistenceManager: \(error)")
            }
        }
        
        guard let validImage, let validImageURL else {
            // If image or image URL is invalid throw invalidImageResult
            throw Errors.invalidImageResult
        }
        
        // Save and upload to server
        try await ChefAppNetworkPersistenceManager.shared.saveAndUploadRecipeImageURLToServer(
            recipeObjectID: recipeObjectID,
            image: validImage,
            imageExternalURL: validImageURL,
            authToken: authToken,
            in: managedContext)
    }
    
}
