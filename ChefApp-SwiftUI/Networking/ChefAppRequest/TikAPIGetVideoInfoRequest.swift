//
//  TikAPIGetVideoInfoRequest.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 12/20/24.
//

import Foundation

struct TikAPIGetVideoInfoRequest: Codable {
    
    let authToken: String
    let videoID: String
    
    enum CodingKeys: String, CodingKey {
        case authToken
        case videoID
    }
    
}
