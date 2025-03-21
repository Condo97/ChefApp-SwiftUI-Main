//
//  APNSRegistrationRequest.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/2/24.
//

import Foundation

struct APNSRegistrationRequest: Codable {
    
    var authToken: String
    var deviceID: Data
    
    enum CodingKeys: String, CodingKey {
        case authToken
        case deviceID
    }
    
}
