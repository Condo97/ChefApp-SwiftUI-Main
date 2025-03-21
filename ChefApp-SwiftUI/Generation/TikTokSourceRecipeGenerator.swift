//
//  TikTokSourceRecipeGenerator.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 12/21/24.
//

import CoreData
import Foundation
import UIKit

class TikTokSourceRecipeGenerator: ObservableObject {
    
    enum LoadingProgress {
        case preparing
        case transcribingVideo
        case generatingRecipe
    }
    
    @Published var loadingProgress: LoadingProgress?
    
    func generate(tikTokUrl: URL, recipeGenerator: RecipeGenerator, in managedContext: NSManagedObjectContext) async throws -> Recipe {
        defer { DispatchQueue.main.async { self.loadingProgress = nil } }
        await MainActor.run { loadingProgress = .preparing }
        
        // Ensure authToken
        let authToken: String
        do {
            authToken = try await AuthHelper.ensure()
        } catch {
            // TODO: Handle Errors
            print("Error ensuring authToken in ChefAppApp... \(error)")
            throw TikTokSourceRecipeGeneratorError.invalidAuthToken
        }
        
        // Set tikTokVideoID to extracted video ID from URL or the entire URL if the extraction is nil
        let tikTokVideoID: String
        if let extractedTikTokVideoID = TikTokVideoIDExtractor.extract(from: tikTokUrl) {
            tikTokVideoID = extractedTikTokVideoID
        } else {
            tikTokVideoID = tikTokUrl.absoluteString
        }
        
        // Get TikAPIGetVideoInfoResponse
        let tikApiGetVideoInfoResponse = try await ChefAppNetworkService.tikApiGetVideoInfoRequest(
            request: TikAPIGetVideoInfoRequest(
                authToken: authToken,
                videoID: tikTokVideoID))
        
        // Ensure not error status, otherwise throw error
        guard tikApiGetVideoInfoResponse.body.apiResponse.status != "error" else {
            throw TikTokSourceRecipeGeneratorError.tikApiErrorResponse
        }
        
        // Ensure unwrap playAddrURLString, otherwise throw missingPlayAddr
        guard let playAddrURLString = tikApiGetVideoInfoResponse.body.apiResponse.itemInfo?.itemStruct?.video?.playAddr else {
            throw TikTokSourceRecipeGeneratorError.missingPlayAddr
        }
        
        // Ensure unwrap playAddr, otherwise throw invalidPlayAddr
        guard let playAddr = URL(string: playAddrURLString) else {
            throw TikTokSourceRecipeGeneratorError.invalidPlayAddr
        }
        
        // Ensure unwrap cookie, otherwise throw missingCookie
        guard let cookie = tikApiGetVideoInfoResponse.body.apiResponse.other?.videoLinkHeaders?.cookie else {
            throw TikTokSourceRecipeGeneratorError.missingCookie
        }
        
        // Get origin and referer
        let origin = tikApiGetVideoInfoResponse.body.apiResponse.other?.videoLinkHeaders?.origin
        let referer = tikApiGetVideoInfoResponse.body.apiResponse.other?.videoLinkHeaders?.referer
        
        await MainActor.run { loadingProgress = .transcribingVideo }
        
        // Ensure unwrap transcribe TikTok video, otherwise return
        guard let transcription = try await TikTokTranscriber.transcribe(
//                tikTokVideoID: tikTokVideoID,
            authToken: authToken,
            playAddr: playAddr,
            videoLinkHeadersCookie: cookie,
            videoLinkHeadersOrigin: origin,
            videoLinkHeadersReferer: referer) else {
            // TODO: Handle Errors
            print("Could not unwrap tiktok video transcription in TikTokSourceRecipeGenerator!")
            throw TikTokSourceRecipeGeneratorError.invalidTranscription
        }
        
        await MainActor.run { loadingProgress = .generatingRecipe }
        
        // Create Recipe with transcription TODO: This should be moved
        let recipe = try await recipeGenerator.create(
                ingredients: transcription,
                modifiers: nil,
                expandIngredientsMagnitude: 0,
                dailyRecipe_isDailyRecipe: false,
                dailyRecipe_timeFrameID: nil,
                authToken: authToken,
                in: managedContext)
        
        // Update Recipe saved
        try await RecipeCDClient.updateRecipe(recipe, saved: true, in: managedContext)
        
        // Get thumbnail image from URL and update Recipe
        if let thumbnailImageUrlString = tikApiGetVideoInfoResponse.body.apiResponse.itemInfo?.itemStruct?.video?.cover,
           let thumbnailImageUrl = URL(string: thumbnailImageUrlString) {
            let thumbnailImageData = try Data(contentsOf: thumbnailImageUrl)
            
            // Update Recipe image with thumbnail
            if let thumbnailImage = UIImage(data: thumbnailImageData) {
                try await RecipeCDClient.updateRecipe(recipe, uiImage: thumbnailImage, in: managedContext)
            }
        }
        
        // Update Recipe tikTokSourceURL
        try await RecipeCDClient.updateRecipe(recipe, sourceTikTokVideoID: tikTokVideoID, in: managedContext)
        
        // Return Recipe
        return recipe
    }
    
}
