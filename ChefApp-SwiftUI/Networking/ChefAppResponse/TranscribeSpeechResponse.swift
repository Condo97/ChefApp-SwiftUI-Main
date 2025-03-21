//
//  TranscribeSpeechResponse.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/15/24.
//

import Foundation

struct TranscribeSpeechResponse: Codable {
    
    struct Body: Codable {
        
        var text: String?
        
        enum CodingKeys: String, CodingKey {
            case text
        }
        
    }
    
    var body: Body
    var success: Int
    
    enum CodingKeys: String, CodingKey {
        case body = "Body"
        case success = "Success"
    }
    
}
