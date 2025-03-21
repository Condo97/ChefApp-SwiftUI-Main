//
//  TagRecipeIdeaRequest.swift
//  PantryPal
//
//  Created by Alex Coundouriotis on 7/6/23.
//

import Foundation

struct TagRecipeIdeaRequest: Codable {
    
    var authToken: String
    var recipeID: Int64
    
    enum CodingKeys: String, CodingKey {
        case authToken
        case recipeID
    }
    
}
