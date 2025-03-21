////
////  ConfigurableRecipeSwipeCardsView.swift
////  ChefApp-SwiftUI
////
////  Created by Alex Coundouriotis on 12/11/24.
////
//
//import SwiftUI
//
//struct ConfigurableRecipeSwipeCardsView: View {
//    
//    @ObservedObject private var model: RecipeSwipeCardsView.Model
//    let onTap: (_ card: RecipeSwipeCardView.Model) -> Void
//    let onSwipe: (_ card: RecipeSwipeCardView.Model, _ swipeDirection: RecipeSwipeCardView.SwipeDirection) -> Void
//    let onSwipeComplete: () -> Void
////    let onUndo: (_ card: RecipeSwipeCardView.Model) -> Void
//    let onClose: () -> Void
//    
//    var body: some View {
//        RecipeSwipeCardsView(
//            model: model,
//            onTap: onTap,
//            onSwipe: onSwipe,
//            onSwipeComplete: onSwipeComplete,
////            onUndo: onUndo,
//            onClose: onClose)
//    }
//}
//
//#Preview {
//    ConfigurableRecipeSwipeCardsView()
//}
