//
//  PersistenceError.swift
//  Barback
//
//  Created by Alex Coundouriotis on 9/18/23.
//

import Foundation

enum PersistenceError: Error {
    case duplicateObject
    case invalidObjectID
    case noObject
}
