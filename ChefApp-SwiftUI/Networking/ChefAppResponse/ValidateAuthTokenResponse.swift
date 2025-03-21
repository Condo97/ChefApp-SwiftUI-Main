//
//  ValidateAuthTokenResponse.swift
//  PantryPal
//
//  Created by Alex Coundouriotis on 6/24/23.
//

import Foundation

struct ValidateAuthTokenResponse: Codable {
    
    struct Body: Codable {
        
        var isValid: Bool
        
        enum CodingKeys: String, CodingKey {
            case isValid
        }
        
    }
    
    var body: Body
    var success: Int
    
    enum CodingKeys: String, CodingKey {
        case body = "Body"
        case success = "Success"
    }
    
}
