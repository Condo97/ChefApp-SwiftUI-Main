//
//  CreateRecipeIdeaResponse.swift
//  PantryPal
//
//  Created by Alex Coundouriotis on 6/23/23.
//

import Foundation

struct CreateRecipeIdeaResponse: Codable {
    
    struct Body: Codable {
        
        var ingredients: [String]
//        var equipment: [String]
        var name: String
        var summary: String
        var cuisineType: String
        var recipeID: Int
        var remaining: Int?
        
        enum CodingKeys: String, CodingKey {
            case ingredients
//            case equipment
            case name
            case summary
            case cuisineType
            case recipeID
            case remaining
        }
        
    }
    
    var body: Body
    var success: Int
    
    enum CodingKeys: String, CodingKey {
        case body = "Body"
        case success = "Success"
    }
    
}
