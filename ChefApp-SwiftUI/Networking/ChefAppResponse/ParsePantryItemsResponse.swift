//
//  ParsePantryItemsResponse.swift
//  Barback
//
//  Created by Alex Coundouriotis on 9/18/23.
//

import Foundation

struct ParsePantryItemsResponse: Codable {
    
    struct Body: Codable {
        
        struct PantryItem: Codable {
            
            var item: String?
            var category: String?
            
            enum CodingKeys: String, CodingKey {
                case item
                case category
            }
            
        }
        
        var pantryItems: [PantryItem]
        
        enum CodingKeys: String, CodingKey {
            case pantryItems
        }
        
    }
    
    var success: Int
    var body: Body
    
    enum CodingKeys: String, CodingKey {
        case success = "Success"
        case body = "Body"
    }
    
}
