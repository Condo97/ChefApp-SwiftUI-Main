//
//  LogPinterestConversionRequest.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 6/25/24.
//

import Foundation

struct LogPinterestConversionRequest: Codable {
    
    let authToken: String
    let idfa: String
    let eventName: String
    let eventID: String
    let test: Bool
    
    enum CodingKeys: String, CodingKey {
        case authToken
        case idfa
        case eventName
        case eventID
        case test
    }
    
}
