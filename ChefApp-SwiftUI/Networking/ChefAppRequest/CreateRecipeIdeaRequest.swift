//
//  MakeRecipeIdeaRequest.swift
//  PantryPal
//
//  Created by Alex Coundouriotis on 6/23/23.
//

import Foundation

struct CreateRecipeIdeaRequest: Codable {
    
    var authToken: String
    var ingredients: String
    var modifiers: String?
    var expandIngredientsMagnitude: Int
    
    enum CodingKeys: String, CodingKey {
        case authToken
        case ingredients
        case modifiers
        case expandIngredientsMagnitude
    }
    
}
