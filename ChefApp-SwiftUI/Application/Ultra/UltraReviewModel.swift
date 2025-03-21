//
//  UltraReviewModel.swift
//  Barback
//
//  Created by Alex Coundouriotis on 10/7/23.
//

import Foundation

struct UltraReviewModel: Identifiable, Hashable {
    
    var id = UUID()
    
    var starCount: Int
    var text: String
    
}
