//
//  PantryRecipeGenerationAdvancedOptionsView.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 6/25/24.
//

import Foundation
import SwiftUI

struct PantryRecipeGenerationAdvancedOptionsView: View {
    
    @Binding var isDisplayingAdvancedOptions: Bool
    @Binding var generationAdditionalOptions: RecipeGenerationAdditionalOptions
    
    
    var body: some View {
        HStack {
            Button(action: {
                HapticHelper.doLightHaptic()
                
                withAnimation {
                    isDisplayingAdvancedOptions.toggle()
                }
            }) {
                Text("\(isDisplayingAdvancedOptions ? "Hide" : "Show") Advanced Options \(isDisplayingAdvancedOptions ? Image(systemName: "chevron.up") : Image(systemName: "chevron.down"))")
                    .font(.custom(Constants.FontName.heavy, size: 14.0))
                    .foregroundStyle(Colors.elementBackground)
            }
            .padding([.leading, .trailing])
            Spacer()
        }
        
        if isDisplayingAdvancedOptions {
            HStack {
                VStack(alignment: .leading) {
                    // Use All Ingredients Button
                    KeyboardDismissingButton(action: {
                        HapticHelper.doLightHaptic()
                        
                        // Set recipeGenerationAdditionalOptions to useAllGivenIngredients if not useAllGivenIngredients, otherwise set to normal
                        if generationAdditionalOptions != .useOnlyGivenIngredients {
                            withAnimation {
                                generationAdditionalOptions = .useOnlyGivenIngredients
                            }
                        } else {
                            withAnimation {
                                generationAdditionalOptions = .normal
                            }
                        }
                    }) {
                        HStack {
                            Text(Image(systemName: generationAdditionalOptions == .useOnlyGivenIngredients ? "checkmark.circle.fill" : "circle"))
                                .font(.custom(Constants.FontName.body, size: 20.0))
                            Text("Use All Ingredients")
                                .font(.custom(Constants.FontName.heavy, size: 14.0))
                        }
                        .padding([.leading, .trailing], 16)
                        .padding([.top, .bottom], 8)
                        .tint(Colors.elementBackground)
                        .background(Colors.foreground)
                        .clipShape(RoundedRectangle(cornerRadius: 14.0))
                    }
                    .bounceable()
                    
                    // TODO: Add second button for "Increase Creativity" that toggles the use all ingredients one, and update the description to explain it in this way, "toggle AI to use only what's in your prompt or deliciously add ingredients for a better tasting recipe".
                    
                    Text("Ensure AI does not omit any selected ingredients.")
                        .font(.custom(Constants.FontName.bodyOblique, size: 12.0))
                        .opacity(0.6)
                    
                    // Increase Creativity Button
                    KeyboardDismissingButton(action: {
                        HapticHelper.doLightHaptic()
                        
                        // Set recipeGenerationAdditionalOptions to boostCreativity if not boostCreativity, otherwise set to normal
                        if generationAdditionalOptions != .boostCreativity {
                            withAnimation {
                                generationAdditionalOptions = .boostCreativity
                            }
                        } else {
                            withAnimation {
                                generationAdditionalOptions = .normal
                            }
                        }
                    }) {
                        HStack {
                            Text(Image(systemName: generationAdditionalOptions == .boostCreativity ? "checkmark.circle.fill" : "circle"))
                                .font(.custom(Constants.FontName.body, size: 20.0))
                            Text("Boost Creativity")
                                .font(.custom(Constants.FontName.heavy, size: 14.0))
                        }
                        .padding([.leading, .trailing], 16)
                        .padding([.top, .bottom], 8)
                        .tint(Colors.elementBackground)
                        .background(Colors.foreground)
                        .clipShape(RoundedRectangle(cornerRadius: 14.0))
                    }
                    .bounceable()
                    
                    // TODO: Add second button for "Increase Creativity" that toggles the use all ingredients one, and update the description to explain it in this way, "toggle AI to use only what's in your prompt or deliciously add ingredients for a better tasting recipe".
                    
                    Text("Let AI add ingredients to boost tastiness.")
                        .font(.custom(Constants.FontName.bodyOblique, size: 12.0))
                        .opacity(0.6)
                }
                Spacer()
            }
            .padding([.leading, .trailing])
        }
    }
    
}


#Preview {
    
    PantryRecipeGenerationAdvancedOptionsView(
        isDisplayingAdvancedOptions: .constant(true),
        generationAdditionalOptions: .constant(.normal)
    )
    
}
