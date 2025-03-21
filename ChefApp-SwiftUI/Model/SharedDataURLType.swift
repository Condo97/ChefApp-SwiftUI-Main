//
//  SharedDataURLType.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 12/20/24.
//

import Foundation

enum SharedDataURLType {
    case tikTok
    case otherWeb
    
    static func from(url: URL) -> SharedDataURLType {
        if url.host()?.contains("tiktok") ?? false {
            return .tikTok
        }
        
        return .otherWeb
    }
    
}
