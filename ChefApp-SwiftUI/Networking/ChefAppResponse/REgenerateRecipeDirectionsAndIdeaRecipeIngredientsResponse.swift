//
//  RegenerateRecipeDirectionsAndIdeaRecipeIngredientsResponse.swift
//  PantryPal
//
//  Created by Alex Coundouriotis on 7/19/23.
//

import Foundation

struct RegenerateRecipeDirectionsAndIdeaRecipeIngredientsResponse: Codable {
    
    struct Body: Codable {
        
        var allIngredientsAndMeasurements: [String]
        var instructions: [Int: String]
        var estimatedServings: Int?
        var feasibility: Int?
        
        enum CodingKeys: String, CodingKey {
            case allIngredientsAndMeasurements
            case instructions
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
