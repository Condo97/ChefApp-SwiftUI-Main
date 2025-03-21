//
//  UpdateRecipeImageURLRequest.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 12/7/24.
//

import Foundation

struct UpdateRecipeImageURLRequest: Codable {
    
    let authToken: String
    let recipeID: Int
    let imageURL: String
    
    enum CodingKeys: String, CodingKey {
        case authToken
        case recipeID
        case imageURL
    }
    
}
