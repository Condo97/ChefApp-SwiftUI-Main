//
//  TikTokSearchGenerator.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 12/3/24.
//

import Foundation

class TikTokSearchGenerator: ObservableObject {
    
    @Published var isLoading: Bool = false
    @Published var nextCursor: String?
    
    func search(authToken: String, category: TikTokSearchRequest.Category, query: String) async throws -> TikAPISearchResponse {
        await MainActor.run { nextCursor = nil }
        
        return try await executeSearch(
            authToken: authToken,
            category: category,
            query: query,
            nextCursor: nil)
    }
    
    func nextPage(authToken: String, category: TikTokSearchRequest.Category, query: String) async throws -> TikAPISearchResponse {
        guard let nextCursor else {
            throw TikTokSearchGeneratorError.nilCursor
        }
        
        return try await executeSearch(
            authToken: authToken,
            category: category,
            query: query,
            nextCursor: nextCursor)
    }
    
    private func executeSearch(authToken: String, category: TikTokSearchRequest.Category, query: String, nextCursor: String?) async throws -> TikAPISearchResponse {
        return try await ChefAppNetworkService.tikTokSearch(
            request: TikTokSearchRequest(
                authToken: authToken,
                category: category,
                query: query,
                nextCursor: nextCursor))
    }
    
}
