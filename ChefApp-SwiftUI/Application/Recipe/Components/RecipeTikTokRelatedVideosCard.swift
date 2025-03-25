//
//  RecipeTikTokRelatedVideosCard.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 3/16/25.
//

import SwiftUI

struct RecipeTikTokRelatedVideosCard: View {
    
    @ObservedObject var recipe: Recipe
    
    @StateObject private var tikTokSearchGenerator: TikTokSearchGenerator = TikTokSearchGenerator()
    
    @State private var tikTokSearchResponse: TikAPISearchResponse?
    
    @State private var isDisplayingRelatedVideos: Bool = false
    
    var body: some View {
        VStack(spacing: 0.0) {
            if let name = recipe.name,
               let summary = recipe.summary {
                
                if isDisplayingRelatedVideos {
                    TikTokSearchCardsContainer(
                        query: name + " " + summary,
                        height: 200.0,
                        maxCardWidth: 150.0,
                        tikTokSearchGenerator: tikTokSearchGenerator,
                        tikTokSearchResponse: $tikTokSearchResponse)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 8)
                }
                
                Divider()
            }
        }
    }
    
}
