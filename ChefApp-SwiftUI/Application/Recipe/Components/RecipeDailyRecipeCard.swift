//
//  RecipeDailyRecipeCard.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 3/16/25.
//

import SwiftUI

struct RecipeDailyRecipeCard: View {
    
    @ObservedObject var recipe: Recipe
    
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        if recipe.dailyRecipe_isDailyRecipe {
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text(recipe.saved ? "Un-save daily recipe?" : "Save daily recipe?")
                            .font(.custom(Constants.FontName.heavy, size: 17.0))
                        Text(recipe.saved ? "Recipe is currently saved." : "Recipe will be deleted tomorrow.")
                            .font(.custom(Constants.FontName.body, size: 12.0))
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        // Save or unsave daily recipe
                        Task {
                            do {
                                try await RecipeCDClient.updateRecipe(recipe, saved: !recipe.saved, in: viewContext)
                            } catch {
                                // TODO: Handle Errors
                                print("Error updating recipe dailyRecipe_isSavedToRecipes in RecipeOfTheDayView... \(error)")
                            }
                        }
                    }) {
                        HStack(spacing: 6.0) {
                            Text(Image(systemName: recipe.saved ? "star.fill" : "star"))
                                .font(.body, 17.0)
                            Text(recipe.saved ? "Un-Save" : "Save")
                                .font(.custom(Constants.FontName.heavy, size: 14.0))
                        }
                            .foregroundStyle(recipe.saved ? Colors.elementBackground : Colors.elementText)
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(
                                ZStack {
                                    if recipe.saved {
                                        RoundedRectangle(cornerRadius: 14.0)
                                            .stroke(Colors.elementBackground, lineWidth: 2)
                                    } else {
                                        RoundedRectangle(cornerRadius: 14.0)
                                            .fill(Colors.elementBackground)
                                    }
                                }
                            )
                    }
                }
                .padding(.horizontal)
                
                Divider()
                    .foregroundStyle(Colors.elementBackground)
            }
        }
    }
    
}
