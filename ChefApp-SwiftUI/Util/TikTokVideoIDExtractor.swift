//
//  TikTokVideoIDExtractor.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 12/21/24.
//

import Foundation

class TikTokVideoIDExtractor {
    
    static func extract(from url: URL) -> String? {
        // Find the index of the "video" component
        if let videoIndex = url.pathComponents.firstIndex(of: "video") {
            // Ensure there is a component after "video" to extract the ID
            let idIndex = url.pathComponents.index(after: videoIndex)
            if idIndex < url.pathComponents.count {
                let videoID = url.pathComponents[idIndex]
                return videoID
            }
        }
        
        return nil
    }
    
}
