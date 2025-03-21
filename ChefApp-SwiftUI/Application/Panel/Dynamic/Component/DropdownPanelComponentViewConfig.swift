//
//  DropdownPanelComponentViewConfig.swift
//  Barback
//
//  Created by Alex Coundouriotis on 9/17/23.
//

import Foundation
import SwiftUI

struct DropdownPanelComponentViewConfig: Identifiable, Codable, Hashable {
    
    var id = UUID()
    
    var placeholder: String?
    var items: [String]
    
    var placeholderUnwrapped: String {
        placeholder ?? defaultPlaceholder
    }
    
    private let defaultPlaceholder = "Tap to Select..."
    
    enum CodingKeys: String, CodingKey {
        case placeholder
        case items
    }
    
}
