//
//  RecipeShareURLMaker.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 12/5/24.
//

import Foundation

class RecipeShareURLMaker {
    
    private static let baseURL = "https://chitchatserver.com/chefappdeeplink/recipe/"
    
    static func getShareURL(recipeID: Int) -> URL? {
        URL(string: "\(baseURL)\(recipeID)")
    }
    
}
