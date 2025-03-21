//
//  GetImportantConstantsResponse.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/30/23.
//

import Foundation

struct GetImportantConstantsResponse: Codable {
    
    struct Body: Codable {
        
        var annualDisplayPrice: String?
        var bingAPIKey: String?
        var freeEssayCap: Int?
        var monthlyProductID: String?
        var shareURL: String?
        var weeklyProductID: String?
        
        // DEPRECATED
        var monthlyDisplayPrice: String?
        var weeklyDisplayPrice: String?
        
        enum CodingKeys: String, CodingKey {
            case annualDisplayPrice
            case bingAPIKey
            case freeEssayCap
            case monthlyProductID
            case shareURL
            case weeklyProductID
            
            // DEPRECATED
            case monthlyDisplayPrice
            case weeklyDisplayPrice
        }
        
    }
    
    var body: Body
    var success: Int
    
    enum CodingKeys: String, CodingKey {
        case body = "Body"
        case success = "Success"
    }
    
}
