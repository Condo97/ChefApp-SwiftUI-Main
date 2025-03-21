//
//  BarItemPersistenceError.swift
//  Barback
//
//  Created by Alex Coundouriotis on 9/30/23.
//

import Foundation

enum PantryItemPersistenceError: Error {
    case duplicatePantryItemNames([String])
}
