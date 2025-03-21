//
//  TranscribeSpeechRequest.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/15/24.
//

import Foundation

struct TranscribeSpeechRequest: Codable {
    
    var authToken: String
    var speechFileName: String
    var speechFile: Data
    
    enum CodingKeys: String, CodingKey {
        case authToken
        case speechFileName
        case speechFile
    }
    
}
