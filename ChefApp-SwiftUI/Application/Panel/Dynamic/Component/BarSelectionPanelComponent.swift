////
////  BarSelectionPanelComponent.swift
////  Barback
////
////  Created by Alex Coundouriotis on 9/22/23.
////
//
//import Foundation
//import SwiftUI
//
//struct BarSelectionPanelComponent: PanelComponent {
//    
//    var id = UUID()
//    
//    var title: String
//    var detailTitle: String?
//    var detailText: String?
//    var promptPrefix: String
//    var required: Bool?
//    
//    var selectedBarItems: [BarItem] = []
//    
//    var finalizedPrompt: String? {
//        get {
//            guard selectedBarItems.count > 0 else {
//                return nil
//            }
//            
////            return promptPrefix + selectedBarItems.compactMap(\.item).joined(separator: ", ")
//            return promptPrefix + selectedBarItems.compactMap({$0.item ?? $0.brandName ?? $0.alcoholType}).joined(separator: ", ")
//        }
//    }
//    
//    enum CodingKeys: String, CodingKey {
//        case title
//        case detailTitle
//        case detailText
//        case promptPrefix
//        case required
//    }
//    
//}
