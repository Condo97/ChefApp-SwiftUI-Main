//
//  MainGenerateRecipeButton.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 3/25/25.
//

import SwiftUI

struct MainGenerateRecipeButton: View {
    
    @ObservedObject var viewModel: MainViewModel
    
    var body: some View {
        Button(action: {
            // Do light haptic
            HapticHelper.doLightHaptic()
            
            // Show entry view
            withAnimation {
                // TODO: Make sure to test this !!! This is important I'm making some changes now.. need to construct those
                // TODO: It should just work correctly. Figure out what this button is specifically, pretty sure it's the recipe start gen button, and make sure that it works optimally
                viewModel.presentingRecipeSaveGenerationSwipeViewModel = RecipeSaveGenerationSwipeViewModel(
                    recipeGenerationSwipeViewModel: RecipeGenerationSwipeViewModel(
                        pantryItems: [],
                        suggestions: [],
                        input: "",
                        generationAdditionalOptions: .normal))
            }
        }) {
            ZStack {
                Spacer()
                Text("Create Recipe")
                    .font(.custom("copperplate-bold", size: 24.0))
                    .foregroundStyle(Colors.elementText)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14.0)
                .fill(Colors.elementBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20.0))
        .bounceable()
        .padding()
        .background(Material.regular)
    }
    
}

#Preview {
    
    MainGenerateRecipeButton(viewModel: MainViewModel())
    
}
