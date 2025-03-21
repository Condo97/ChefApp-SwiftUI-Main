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
                Button(action: { withAnimation(.bouncy(duration: 0.5)) { isDisplayingRelatedVideos.toggle() } }) {
                    HStack {
                        Text("Related Videos")
                            .font(.heavy, 17.0)
                        Spacer()
                        Image(systemName: isDisplayingRelatedVideos ? "chevron.up" : "chevron.down")
                            .font(.body, 17.0)
                    }
                    .padding(.horizontal)
                }
                .foregroundStyle(Colors.foregroundText)
                .padding(.bottom, 8)
                
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
