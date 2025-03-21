//
//  ParsePantryItemsRequest.swift
//  Barback
//
//  Created by Alex Coundouriotis on 9/18/23.
//

import Foundation

struct ParsePantryItemsRequest: Codable {
    
    var authToken: String
    var input: String?
    var imageDataInput: Data?
    
    enum CodingKeys: String, CodingKey {
        case authToken
        case input
        case imageDataInput
    }
    
}
