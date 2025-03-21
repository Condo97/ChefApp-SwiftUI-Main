//
//  AddOrRemoveLikeOrDislikeRequest.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 11/27/24.
//

import Foundation

struct AddOrRemoveLikeOrDislikeRequest: Codable {
    
    let authToken: String
    let recipeID: Int
    let shouldAdd: Bool
    let isLike: Bool
    
}
