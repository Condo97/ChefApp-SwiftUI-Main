//
//  GetAllTagsResponse.swift
//  PantryPal
//
//  Created by Alex Coundouriotis on 7/7/23.
//

import Foundation

struct GetAllTagsResponse: Codable {
    
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
