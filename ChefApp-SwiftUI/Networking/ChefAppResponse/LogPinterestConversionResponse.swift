//
//  LogPinterestConversionResponse.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 6/25/24.
//

import Foundation

struct LogPinterestConversionResponse: Codable {
    
    struct Body: Codable {
        
        var didLog: Bool
        
        enum CodingKeys: String, CodingKey {
            case didLog
        }
        
    }
    
    var body: Body
    var success: Int
    
    enum CodingKeys: String, CodingKey {
        case body = "Body"
        case success = "Success"
    }
    
}
