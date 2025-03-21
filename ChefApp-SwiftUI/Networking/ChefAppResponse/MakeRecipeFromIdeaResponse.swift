//
//  MakeRecipeResponse.swift
//  PantryPal
//
//  Created by Alex Coundouriotis on 6/23/23.
//

import Foundation

struct MakeRecipeFromIdeaResponse: Codable {
    
    struct Body: Codable {
        
        var directions: [Int: String]
        var allIngredientsAndMeasurements: [String]
        var estimatedTotalCalories: Int?
        var estimatedTotalMinutes: Int?
        var estimatedServings: Int?
        var feasibility: Int?
        
        enum CodingKeys: String, CodingKey {
            case directions = "instructions"
            case allIngredientsAndMeasurements
            case estimatedTotalCalories
            case estimatedTotalMinutes
            case estimatedServings
            case feasibility
        }
        
    }
    
    var body: Body
    var success: Int
    
    enum CodingKeys: String, CodingKey {
        case body = "Body"
        case success = "Success"
    }
    
}
