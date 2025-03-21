////
////  RecipeGenerationSwipeContainer.swift
////  ChefApp-SwiftUI
////
////  Created by Alex Coundouriotis on 12/11/24.
////
//
//import SwiftUI
//
//struct RecipeGenerationSwipeContainer: View {
//    
//    @ObservedObject var recipeGenerationSpec: RecipeGenerationSpec
//    let onSwipe: (_ recipe: Recipe, _ swipeDirection: RecipeSwipeCardView.SwipeDirection) -> Void
//    let onDetailViewSave: (Recipe) -> Void
//    let onUndo: (_ recipe: Recipe, _ previousSwipeDirection: RecipeSwipeCardView.SwipeDirection) -> Void
//    let onClose: () -> Void
//    
//    @StateObject var recipeGenerator: RecipeGenerator = RecipeGenerator()
//    
//    @StateObject var recipeSwipeCardsViewModel: RecipeSwipeCardsView.Model = RecipeSwipeCardsView.Model(cards: [])
//    
//    var body: some View {
//        RecipeGenerationSwipeView(
//            recipeGenerator: recipeGenerator,
//            recipeSwipeCardsViewModel: recipeSwipeCardsViewModel,
//            recipeGenerationSpec: recipeGenerationSpec,
//            onSwipe: onSwipe,
//            onDetailViewSave: onDetailViewSave,
//            onUndo: onUndo,
//            onClose: onClose)
//    }
//}
//
////#Preview {
////    
////    RecipeGenerationSwipeContainer()
////    
////}
