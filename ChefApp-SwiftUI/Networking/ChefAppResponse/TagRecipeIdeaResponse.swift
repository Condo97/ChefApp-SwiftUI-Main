//
//  TagRecipeIdeaResponse.swift
//  PantryPal
//
//  Created by Alex Coundouriotis on 7/6/23.
//

import Foundation

struct TagRecipeIdeaResponse: Codable {
    
    struct Body: Codable {
        
        var tags: [String]
        
        enum CodingKeys: String, CodingKey {
            case tags
        }
        
    }
    
    var body: Body
    var success: Int
    
    enum CodingKeys: String, CodingKey {
        case body = "Body"
        case success = "Success"
    }
    
}
