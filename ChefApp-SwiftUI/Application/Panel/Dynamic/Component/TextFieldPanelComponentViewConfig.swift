//
//  TextFieldPanelComponentViewConfig.swift
//  Barback
//
//  Created by Alex Coundouriotis on 9/17/23.
//

import Foundation
import SwiftUI

struct TextFieldPanelComponentViewConfig: Identifiable, Codable, Hashable {
    
    var id = UUID()
    
    var placeholder: String?
    
    var placeholderUnwrapped: String {
        placeholder ?? defaultPlaceholder
    }
    
    private let defaultPlaceholder = "Tap to start typing..."
    
    enum CodingKeys: String, CodingKey {
        case placeholder
    }
    
}
