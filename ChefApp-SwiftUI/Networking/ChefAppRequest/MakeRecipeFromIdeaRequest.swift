//
//  MakeRecipeRequest.swift
//  PantryPal
//
//  Created by Alex Coundouriotis on 6/23/23.
//

import Foundation

struct MakeRecipeFromIdeaRequest: Codable {
    
    var authToken: String
    var ideaID: Int64
    var additionalInput: String?
    
    enum CodingKeys: String, CodingKey {
        case authToken
        case ideaID
        case additionalInput
    }
    
}
