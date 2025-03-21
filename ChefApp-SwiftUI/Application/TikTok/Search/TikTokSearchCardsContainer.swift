//
//  TikTokSearchCardsContainer.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 12/3/24.
//

import SwiftUI

struct TikTokSearchCardsContainer: View {
    
    let query: String
    let height: CGFloat
    let maxCardWidth: CGFloat
    @ObservedObject var tikTokSearchGenerator: TikTokSearchGenerator
    @Binding var tikTokSearchResponse: TikAPISearchResponse?
    
//    @StateObject private var tikTokSearchGenerator = TikTokSearchGenerator()
//    
//    @State private var tikTokSearchResponse: TikTokSearchResponse?
    
    var body: some View {
        Group {
            if let tikTokSearchResponse {
                TikTokSearchCardsView(
                    tikTokSearchResponse: tikTokSearchResponse,
                    maxCardWidth: maxCardWidth)
                .frame(height: height)
            } else {
                ProgressView()
            }
        }
        .task {
            // Ensure tikTokSearchResponse is nil, otherwise return
            guard tikTokSearchResponse == nil else {
                return
            }
            
            // Ensure authToken
            let authToken: String
            do {
                authToken = try await AuthHelper.ensure()
            } catch {
                // TODO: Handle Errors
                print("Error ensuring authToken in TikTokSearchCardscontainer... \(error)")
                return
            }
            
            // Get search response
            do {
                tikTokSearchResponse = try await tikTokSearchGenerator.search(
                    authToken: authToken,
                    category: .videos,
                    query: query)
                print("Hi")
            } catch {
                // TODO: Handle Errors
                print("Error getting tikTokSearchResponse in TikTokSearchCardsContainer... \(error)")
            }
        }
    }
    
}

#Preview {
    
    TikTokSearchCardsContainer(
        query: "lilyachty",
        height: 100.0,
        maxCardWidth: 240.0,
        tikTokSearchGenerator: TikTokSearchGenerator(),
        tikTokSearchResponse: .constant(nil))
    
}
