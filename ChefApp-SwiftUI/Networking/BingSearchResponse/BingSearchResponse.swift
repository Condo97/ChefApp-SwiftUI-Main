//
//  BingSearchResponse.swift
//  BingSearchPopup
//
//  Created by Alex Coundouriotis on 6/30/23.
//

import Foundation
import UIKit

struct BingSearchResponse: Decodable {
    
    struct Value: Decodable {
        
        var contentUrl: String?
        
    }
    
    var nextOffset: Int?
    var totalEstimatedMatches: Int?
    var value: [Value]
    
}
