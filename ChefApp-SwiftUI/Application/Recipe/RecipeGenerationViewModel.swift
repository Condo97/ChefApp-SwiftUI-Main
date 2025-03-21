//
//  RecipeGenerationViewModel.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 3/17/25.
//

import Foundation

/***
 Recipe Generation View Model
 
 This should be everything that is needed to generate a recipe, which displays on the view, and its values mirror those of and are used in RecipeGenerator.
 
 It can be extended by List and Swipe recipe generation views to provide view specific data while maintaining the basic information for recipe generation.
 */
class RecipeGenerationViewModel: ObservableObject, Identifiable {
    
    @Published var pantryItems: [PantryItem]
    @Published var suggestions: [String]
    @Published var input: String
    @Published var generationAdditionalOptions: RecipeGenerationAdditionalOptions
    
    init(pantryItems: [PantryItem], suggestions: [String], input: String, generationAdditionalOptions: RecipeGenerationAdditionalOptions) {
        self.pantryItems = pantryItems
        self.suggestions = suggestions
        self.input = input
        self.generationAdditionalOptions = generationAdditionalOptions
    }
    
}
