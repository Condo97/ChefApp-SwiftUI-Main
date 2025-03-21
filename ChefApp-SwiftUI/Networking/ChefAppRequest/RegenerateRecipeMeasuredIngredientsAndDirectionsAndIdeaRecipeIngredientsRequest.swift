//
//  RegenerateRecipeDirectionsAndIdeaRecipeIngredientsRequest.swift
//  PantryPal
//
//  Created by Alex Coundouriotis on 7/19/23.
//

import Foundation

struct RegenerateRecipeMeasuredIngredientsAndDirectionsAndIdeaRecipeIngredientsRequest: Codable {
    
    var authToken: String
    var recipeID: Int64
    var newName: String?
    var newSummary: String?
    var newServings: Int?
    var measuredIngredients: [String]?
    var additionalInput: String?
    
    enum CodingKeys: String, CodingKey {
        case authToken
        case recipeID
        case newName
        case newSummary
        case newServings
        case measuredIngredients
        case additionalInput
    }
    
}
