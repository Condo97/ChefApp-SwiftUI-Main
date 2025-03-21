//
//  CreatePanelsJSONPersistenceManager.swift
//  Barback
//
//  Created by Alex Coundouriotis on 9/18/23.
//

import Foundation

class CreatePanelsJSONPersistenceManager {
    
    static func get() -> String? {
        UserDefaults.standard.string(forKey: Constants.UserDefaults.createPanelsJSON)
    }
    
    static func set(_ jsonString: String) {
        UserDefaults.standard.set(jsonString, forKey: Constants.UserDefaults.createPanelsJSON)
    }
    
}
