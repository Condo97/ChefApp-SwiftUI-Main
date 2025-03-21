//
//  RecipeOfTheDayError.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 11/30/24.
//

import Foundation

enum RecipeOfTheDayError: Error {
    
    case recipeOfTheDayExistsForTimeframe(recipe: Recipe)
    
}
