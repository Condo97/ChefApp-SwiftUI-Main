//
//  RecipeCapReachedCard.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 3/16/25.
//

import SwiftUI

struct RecipeInstructionsList: View {
    
    @ObservedObject var recipe: Recipe
    let cardColor: Color
    var finishUpdatingRecipe: () async -> Void
    
    @State var isLoadingRecipeFinalizer: Bool = false
    
    private var recipeNeedsFinalization: Bool {
        recipe.measuredIngredients == nil || recipe.measuredIngredients!.count == 0 || recipe.directions == nil || recipe.directions!.count == 0
    }
    
    var body: some View {
        VStack {
            // Directions
            if let unsortedDirections = (recipe.directions?.allObjects as? [RecipeDirection]), unsortedDirections.count > 0 {
                let directions = unsortedDirections.sorted(by: {$0.index < $1.index})
                ForEach(directions) { direction in
                    if let string = direction.string {
                        HStack {
                            Text("\(direction.index + 1)")
                                .font(.custom(Constants.FontName.black, size: 24.0))
                                .padding(.trailing, 8)
                            Text(LocalizedStringKey(string))
                                .font(.custom(Constants.FontName.body, size: 14.0))
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                        .padding()
                        .background(cardColor)
                        .clipShape(RoundedRectangle(cornerRadius: 24.0))
                    }
                }
            } else {
                if !isLoadingRecipeFinalizer {
                    // Finish Generating Button, recipeNeedsFinalization is implied so not explicitly checked for displaying this
                    Button(action: {
                        HapticHelper.doLightHaptic()
                        
                        // If no measuredIngredients or directions, finalize and update remaining
                        if recipeNeedsFinalization {
                            Task {
                                await finishUpdatingRecipe()
                                
                                HapticHelper.doSuccessHaptic()
                            }
                        }
                    }) {
                        Text("Finish Generating...")
                            .font(.custom(Constants.FontName.heavy, size: 24.0))
                            .tint(Colors.elementBackground)
                            .background(Material.regular)
                    }
                }
            }
            
            Spacer(minLength: 240.0)
        }
    }
    
}
