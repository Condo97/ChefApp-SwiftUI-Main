////
////  IngredientsInputPanelComponent.swift
////  Barback
////
////  Created by Alex Coundouriotis on 9/22/23.
////
//
//import Foundation
//import SwiftUI
//
//struct IngredientsInputPanelComponent: PanelComponent {
//    
//    var id = UUID()
//    
//    var title: String
//    var placeholder: String?
//    var detailTitle: String?
//    var detailText: String?
//    var promptPrefix: String
//    var required: Bool?
//    
//    var text: String = ""
//    
//    var finalizedPrompt: String? {
//        guard !text.isEmpty else {
//            return nil
//        }
//        
//        return promptPrefix + " " + text
//    }
//    
//    var placeholderUnwrapped: String {
//        placeholder ?? defaultPlaceholder
//    }
//    
//    private let defaultPlaceholder = "Tap to start typing..."
//    
//    enum CodingKeys: String, CodingKey {
//        case title
//        case placeholder
//        case detailTitle
//        case detailText
//        case promptPrefix
//        case required
//    }
//    
//}
