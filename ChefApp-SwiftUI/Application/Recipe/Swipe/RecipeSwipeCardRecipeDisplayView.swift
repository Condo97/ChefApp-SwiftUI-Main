//
//  RecipeSwipeCardRecipeDisplayView.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 12/7/24.
//

import SwiftUI

struct RecipeSwipeCardRecipeDisplayView: View {
    
//    @ObservedObject var recipe: Recipe
    let imageURL: URL?
    let name: String?
    let summary: String?
    let size: CGSize
    
    var body: some View {
//        if let uiImage {
            if let imageURL {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size.width, height: size.width)
                            .aspectRatio(contentMode: .fill)
                    case .failure(let error):
                        ProgressView()
                    }
                }
//            }
//            Image(uiImage: uiImage)
//                .resizable()
//                .aspectRatio(contentMode: .fill)
//                .frame(width: size.width, height: size.width)
//                .aspectRatio(contentMode: .fill)
        } else {
            VStack {
                ProgressView()
            }
            .frame(width: size.width, height: size.width)
            .background(Colors.background.opacity(0.6))
        }
        
        VStack(alignment: .leading) {
            Text(name ?? "")
                .font(.heavy, 17.0)
//            .padding(.horizontal)
            
            Text(summary ?? "")
                .font(.body, 14.0)
            //            .padding(.horizontal)
        }
        .padding()
//        .frame(width: size.width)
        .frame(maxWidth: .infinity)
        .background(Colors.foreground)
    }
}

#Preview {
    
    RecipeSwipeCardRecipeDisplayView(
//        recipe: try! CDClient.mainManagedObjectContext.fetch(Recipe.fetchRequest()).first!,
        imageURL: nil,
        name: "name",
        summary: "summary",
        size: CGSize(width: 250.0, height: 250.0)
    )
    .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
    
}
