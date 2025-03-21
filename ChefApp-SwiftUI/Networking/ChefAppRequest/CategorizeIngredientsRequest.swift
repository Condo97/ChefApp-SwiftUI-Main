//
//  CategorizeIngredientsRequest.swift
//  PantryPal
//
//  Created by Alex Coundouriotis on 7/8/23.
//

import Foundation

struct CategorizeIngredientsRequest: Codable {
    
    var authToken: String
    var ingredients: [String]
    
    enum CodingKeys: String, CodingKey {
        case authToken
        case ingredients
    }
    
}
