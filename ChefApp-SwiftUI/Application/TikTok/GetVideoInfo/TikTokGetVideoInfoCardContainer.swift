//
//  TikTokGetVideoInfoCardContainer.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 12/20/24.
//

import SwiftUI

struct TikTokGetVideoInfoCardContainer: View {
    
    let tikTokVideoID: String
    @ObservedObject var tikTokGetVideoInfoGenerator: TikTokGetVideoInfoGenerator
    @Binding var tikApiGetVideoInfoResponse: TikAPIGetVideoInfoResponse?
    
    var body: some View {
        Group {
            if let tikApiGetVideoInfoResponse {
                TikTokGetVideoInfoCardView(tikAPIGetVideoInfoResponse: tikApiGetVideoInfoResponse)
            } else {
                ProgressView()
            }
        }
        .task {
            // Ensure tikApiGetVideoInfoResponse is nil, otherwise return
            guard tikApiGetVideoInfoResponse == nil else { return }
            
            // Ensure authToken
            let authToken: String
            do {
                authToken = try await AuthHelper.ensure()
            } catch {
                // TODO: Handle Errors
                print("Error ensuring authToken in TikTokSearchCardsContainer... \(error)")
                return
            }
            
            // Get video info response
            do {
                tikApiGetVideoInfoResponse = try await tikTokGetVideoInfoGenerator.getVideoInfo(
                    authToken: authToken,
                    videoID: tikTokVideoID)
            } catch {
                // TODO: Handle Errors
                print("Error getting video info in TikTokSearchCardsContainer... \(error)")
                return
            }
        }
    }
}

@available(iOS 17, *)
#Preview {
    
    @Previewable @State var tikApiGetVideoInfoResponse: TikAPIGetVideoInfoResponse?
    
    TikTokGetVideoInfoCardContainer(
        tikTokVideoID: "7257879974500109611",
        tikTokGetVideoInfoGenerator: TikTokGetVideoInfoGenerator(),
        tikApiGetVideoInfoResponse: $tikApiGetVideoInfoResponse
    )
    
}
