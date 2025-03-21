//#Preview {
//    
//    RecipeOfTheDayReloadButton()
//    
//}

////
////  RecipeOfTheDayReloadButton.swift
////  ChefApp-SwiftUI
////
////  Created by Alex Coundouriotis on 11/29/24.
////
//
//import SwiftUI
//
//struct RecipeOfTheDayReloadButton: View {
//    
//    let recipe: Recipe
//    let timeFrame: RecipeOfTheDayView.TimeFrames
////    let onReload: (_ recipe: Recipe, _ timeFrame: RecipeOfTheDayView.TimeFrames) -> Void
//    let onReload: () -> Void
//    
//    @State private var alertShowingConfirmReloadRecipe: Bool = false
//    
//    var body: some View {
//        Button(action: {
//            // If recipe is not saved, show alert
//            if !recipe.saved {
//                alertShowingConfirmReloadRecipe = true
//            } else {
//                onReload()
//            }
//        }) {
//            Image(systemName: "arrow.triangle.2.circlepath")
//        }
//        .alert("Reload Recipe?", isPresented: $alertShowingConfirmReloadRecipe, actions: {
//            Button("Reload") {
//                onReload()
//            }
//            Button("Cancel", role: .cancel) {
//                
//            }
//        }) {
//            Text("Create a new \(timeFrame.displayString.lowercased())? This will overrite the existing recipe.")
//        }
//    }
//    
//}
//
////#Preview {
////    
////    RecipeOfTheDayReloadButton()
////    
////}
