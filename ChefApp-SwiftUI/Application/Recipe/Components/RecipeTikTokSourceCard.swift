//
//  RecipeTikTokSourceCard.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 12/20/24.
//

import SwiftUI

struct RecipeTikTokSourceCard: View {
    
//    let tikTokVideoID: String
    @ObservedObject var recipe: Recipe
    
    @StateObject private var tikTokGetVideoInfoGenerator = TikTokGetVideoInfoGenerator()
    
    @State private var isExpanded: Bool = false
    
    @State private var tikApiGetVideoInfoResponse: TikAPIGetVideoInfoResponse?
    
    var body: some View {
        if let sourceTikTokVideoID = recipe.sourceTikTokVideoID {
            VStack(alignment: .leading, spacing: 0.0) {
                Button(action: { withAnimation(.bouncy(duration: 0.5)) { isExpanded.toggle() } }) {
                    HStack {
                        Text("Source TikTok")
                            .font(.heavy, 17.0)
                        Spacer()
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.body, 17.0)
                    }
                    .padding(.horizontal)
                }
                .foregroundStyle(Colors.foregroundText)
                .padding(.bottom, 8)
                
                if isExpanded {
                    TikTokGetVideoInfoCardContainer(
                        tikTokVideoID: sourceTikTokVideoID,
                        tikTokGetVideoInfoGenerator: tikTokGetVideoInfoGenerator,
                        tikApiGetVideoInfoResponse: $tikApiGetVideoInfoResponse)
                    .frame(maxHeight: 250.0)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 8)
                }
                
                Divider()
            }
        } else {
            ZStack {
                
            }
        }
    }
    
}

#Preview {
    
//    RecipeTikTokSourceCardView(tikTokVideoID: "7257879974500109611")
    var recipe: Recipe = {
        let recipe = Recipe(context: CDClient.mainManagedObjectContext)
        
        recipe.sourceTikTokVideoID = "7257879974500109611"
        
        return recipe
    }()
    
    return RecipeTikTokSourceCard(recipe: recipe)
    
}
