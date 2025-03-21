//
//  GetAndDuplicateRecipeResponse.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 12/5/24.
//

import Foundation

struct GetAndDuplicateRecipeResponse: Codable {
    
    struct Body: Codable {
        
        struct Recipe: Codable {
            
            let recipeID: Int?
            let userID: Int?
            let input: String?
            let name: String?
            let summary: String?
            let cuisineType: String?
            let expandIngredientsMagnitude: Int?
            let estimatedTotalCalories: Int?
            let estimatedTotalMinutes: Int?
            let estimatedServings: Int?
            let feasibility: Int?
            let likesCount: Int?
            let dislikesCount: Int?
            let measuredIngredients: [String]?
            let instructions: [Int: String]?
            
            // CodingKeys to map Swift property names to JSON keys
            enum CodingKeys: String, CodingKey {
                case recipeID = "recipe_id"
                case userID = "user_id"
                case input
                case name
                case summary
                case cuisineType
                case expandIngredientsMagnitude
                case estimatedTotalCalories
                case estimatedTotalMinutes
                case estimatedServings
                case feasibility
                case likesCount
                case dislikesCount
                case measuredIngredients
                case instructions
            }
        }
        
        let recipe: Recipe
        
        enum CodingKeys: String, CodingKey {
            case recipe
        }
        
    }
    
    let body: Body
    let success: Int
    
    enum CodingKeys: String, CodingKey {
        case body = "Body"
        case success = "Success"
    }
    
}
