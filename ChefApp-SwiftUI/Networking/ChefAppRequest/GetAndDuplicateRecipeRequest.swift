//
//  GetAndDuplicateRecipeRequest.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 12/5/24.
//

import Foundation

struct GetAndDuplicateRecipeRequest: Codable {
    
    let authToken: String
    let recipeID: Int
    
    enum CodingKeys: String, CodingKey {
        case authToken
        case recipeID
    }
    
}
