//
//  LoadingTikTokRecipeView.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 3/15/25.
//

import SwiftUI

// TODO: This should be moved to where TikTokSourceRecipeGenerator is or something like that, maybe a new folder is needed
struct LoadingTikTokRecipeView: View {
    
    var progress: TikTokSourceRecipeGenerator.LoadingProgress
    
    var progressText: String {
        switch progress {
        case .preparing:
            "Preparing TikTok data..."
        case .transcribingVideo:
            "Transcribing video..."
        case .generatingRecipe:
            "Generating recipe..."
        }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Loading TikTok Recipe...")
                    .font(.heavy, 20)
                Text(progressText)
                    .font(.body, 14)
                    .italic()
                    .opacity(0.6)
            }
            Spacer()
            ProgressView()
        }
        .foregroundStyle(Colors.foregroundText)
        .padding()
        .background(Colors.foreground)
        .clipShape(RoundedRectangle(cornerRadius: 14.0))
        .padding(.top)
        .padding(.horizontal)
    }
    
}
