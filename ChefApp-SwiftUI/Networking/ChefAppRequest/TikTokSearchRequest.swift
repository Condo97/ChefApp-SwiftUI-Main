//
//  TikTokSearchRequest.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 12/3/24.
//

import Foundation

struct TikTokSearchRequest: Codable {
    
    enum Category: String, Codable {
        case general = "general"
        case uesrs = "users"
        case videos = "videos"
        case autocomplete = "autocomplete"
    }
    
    let authToken: String
    let category: Category
    let query: String
    let nextCursor: String?
    
    enum CodingKeys: String, CodingKey {
        case authToken
        case category
        case query
        case nextCursor
    }
    
}
