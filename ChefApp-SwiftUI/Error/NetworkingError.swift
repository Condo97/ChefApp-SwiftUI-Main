//
//  HTTPSError.swift
//  PantryPal
//
//  Created by Alex Coundouriotis on 6/24/23.
//

import Foundation

enum NetworkingError: Int, Error {
    case success = 1
    case jsonError = 4
    case missingRequiredRequestObject = 5
    case capReachedError = 51
    case oaiGPTError = 60
    case invalidAssociatedIDError = 70
    case illegalArgument = 80
    case serverUnhandledError = 99
    case clientUnhandledError = 100
    
    case unknown = -1
}
