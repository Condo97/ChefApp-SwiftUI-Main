//
//  RecipeInstructionsContainer.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 3/16/25.
//

import SwiftUI

struct RecipeDetailsContainer: View {
    
    @ObservedObject var recipe: Recipe
    @ObservedObject var recipeFinalizer: RecipeFinalizer
    let isLoadingRegenerateDirections: Bool
    let cardColor: Color
    let finishUpdatingRecipe: () async -> Void
    let shouldRegenerateDirections: () -> Void
    
    @State private var ingredientsScrollOffset: Int = .zero
    
    @EnvironmentObject private var premiumUpdater: PremiumUpdater
    
    var shouldDisplayCapReachedCard: Bool {
        !premiumUpdater.isPremium && (recipe.measuredIngredients == nil || recipe.measuredIngredients!.count == 0) && (recipe.directions == nil || recipe.directions!.count == 0) && recipeFinalizer.isFinalizing
    }
    
    var body: some View {
        VStack {
            if recipeFinalizer.isFinalizing {
                    ZStack {
                        HStack {
                            Spacer()
                            VStack {
                                Spacer()
                                Text("Creating Ingredients & Directions...")
                                    .font(.custom(Constants.FontName.bodyOblique, size: 17.0))
                                ProgressView()
                                    .foregroundStyle(Colors.foregroundText)
                                Spacer()
                            }
                            Spacer()
                        }
                    }
                    .padding()
                    .background(cardColor)
                    .clipShape(RoundedRectangle(cornerRadius: 24.0))
            } else if shouldDisplayCapReachedCard {
                CapReachedCard()
            } else {
                RecipeIngredientsList(
                    recipe: recipe,
                    isLoadingRegenerateDirections: isLoadingRegenerateDirections,
                    shouldRegenerateDirections: shouldRegenerateDirections,
                    cardColor: cardColor,
                    ingredientsScrollOffset: ingredientsScrollOffset)
                
                RecipeInstructionsList(
                    recipe: recipe,
                    cardColor: cardColor,
                    finishUpdatingRecipe: finishUpdatingRecipe)
            }
            
        }
        .padding()
    }
    
}
