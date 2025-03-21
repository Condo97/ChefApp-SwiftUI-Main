//
//  RecipeSwipeCardView.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 12/7/24.
//

import SwiftUI

struct RecipeSwipeCardView: View {
    
    class Model: ObservableObject, Identifiable {
        
        let id = UUID()
        
        let recipe: Recipe?
//        @Published var uiImage: UIImage?
        @Published var imageURL: URL?
        var name: String?
        var summary: String?
        var swipeDirection: RecipeSwipeCardView.SwipeDirection = .none
        
        init(recipe: Recipe?, imageURL: URL?, name: String?, summary: String?) {
            self.recipe = recipe
            self.imageURL = imageURL
            self.name = name
            self.summary = summary
        }
        
    }
    
    enum SwipeDirection {
        case left, right, none
    }
    
    @ObservedObject var model: Model
    var size: CGSize
//    var dragOffset: CGSize
//    var isTopCard: Bool
//    var isSecondCard: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
//            if let recipe = model.recipe {
                RecipeSwipeCardRecipeDisplayView(
                    imageURL: model.imageURL,
//                    recipe: recipe,
//                    cachedImage: model.cachedImage,
//                    uiImage: model.uiImage,
                    name: model.name,
                    summary: model.summary,
                    size: size)
//            } else {
//                Text("Loading")
//                ProgressView()
//            }
        }
        .background(Colors.foreground)
        .cornerRadius(15)
    }
    
}

#Preview {
    
    let recipe = try! CDClient.mainManagedObjectContext.fetch(Recipe.fetchRequest()).first!
    
    return GeometryReader { geometry in
        RecipeSwipeCardView(
            model: RecipeSwipeCardView.Model(
                recipe: recipe,
                imageURL: AppGroupLoader(appGroupIdentifier: Constants.Additional.appGroupID).fileURL(for: recipe.imageAppGroupLocation!),
                name: recipe.name,
                summary: recipe.summary),
            size: geometry.size
        )
    }
    .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
    
}
