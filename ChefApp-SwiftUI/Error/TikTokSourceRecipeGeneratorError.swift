//
//  TikTokSourceRecipeGeneratorError.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 12/22/24.
//

import Foundation

enum TikTokSourceRecipeGeneratorError: Error {
    case invalidAuthToken
    case invalidPlayAddr
    case invalidTranscription
    case missingPlayAddr
    case missingCookie
    case tikApiErrorResponse
}
