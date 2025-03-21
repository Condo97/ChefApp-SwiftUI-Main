//
//  ErrorResponse.swift
//  PantryPal
//
//  Created by Alex Coundouriotis on 6/24/23.
//

import Foundation

struct ErrorResponse: Codable {
    
    struct Body: Codable {
        
        var description: String?
        
        enum CodingKeys: String, CodingKey {
            case description
        }
    }
    
    var body: Body
    var success: Int
    
    enum CodingKeys: String, CodingKey {
        case body = "Body"
        case success = "Success"
    }
    
}
