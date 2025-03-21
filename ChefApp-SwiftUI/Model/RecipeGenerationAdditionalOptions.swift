//
//  RecipeGenerationAdditionalOptions.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 6/25/24.
//

import Foundation

enum RecipeGenerationAdditionalOptions: Int, Codable {
    // Currently maps to expandIngredientsMagnitude for server
    case normal = 1
    case useOnlyGivenIngredients = 0
    case boostCreativity = 2
}
