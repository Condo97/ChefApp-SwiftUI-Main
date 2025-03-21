//
//  TikTokGetVideoInfoGenerator.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 12/20/24.
//

import Foundation

class TikTokGetVideoInfoGenerator: ObservableObject {
    
    @Published var isLoading: Bool = false
    
    func getVideoInfo(authToken: String, videoID: String) async throws -> TikAPIGetVideoInfoResponse {
        defer { DispatchQueue.main.async { self.isLoading = false } }
        await MainActor.run { isLoading = true }
        
        return try await ChefAppNetworkService.tikApiGetVideoInfoRequest(
            request: TikAPIGetVideoInfoRequest(
                authToken: authToken,
                videoID: videoID))
    }
    
}
