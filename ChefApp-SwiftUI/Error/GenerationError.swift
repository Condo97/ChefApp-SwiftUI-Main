//
//  GenerationError.swift
//  PantryPal
//
//  Created by Alex Coundouriotis on 7/19/23.
//

import Foundation

enum GenerationError: Error {
    case auth
    case missingInput
    case request
    case response
}
