//
//  CategorizeIngredientsResponse.swift
//  PantryPal
//
//  Created by Alex Coundouriotis on 7/8/23.
//

import Foundation

struct CategorizeIngredientsResponse: Codable {
    
    struct Body: Codable {
        
        struct IngredientCategory: Codable {
            
            var ingredient: String
            var category: String
            
            enum CodingKeys: String, CodingKey {
                case ingredient
                case category
            }
            
        }
        
        var ingredientCategories: [IngredientCategory]
        
        enum CodingKeys: String, CodingKey {
            case ingredientCategories
        }
        
    }
    
    var body: Body
    var success: Int
    
    enum CodingKeys: String, CodingKey {
        case body = "Body"
        case success = "Success"
    }
    
}
