//
//  GetCreatePanelsResponse.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 6/17/24.
//

import Foundation

struct GetCreatePanelsResponse: Codable {
    
    struct Body: Codable {
        
        var createPanels: String
        
        enum CodingKeys: String, CodingKey {
            case createPanels
        }
        
    }
    
    var body: Body
    var success: Int
    
    enum CodingKeys: String, CodingKey {
        case body = "Body"
        case success = "Success"
    }
    
}

