//
//  Panel.swift
//  Barback
//
//  Created by Alex Coundouriotis on 9/17/23.
//

import Foundation
import UIKit

struct Panel: Identifiable, Codable, Hashable {
    
    let id = UUID()
    
    let emoji: String
    let title: String
    let summary: String
    let prompt: String
    var components: [PanelComponent]
    
    enum CodingKeys: String, CodingKey {
        case emoji
        case title
        case summary
        case prompt
        case components
    }
    
}

//extension Panel {
//    
//    struct PanelComponentDecodable: Codable {
//        
//        var type: String
//        
//        enum CodingKeys: String, CodingKey {
//            case type
//        }
//        
//    }
//    
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        emoji = try container.decode(String.self, forKey: .emoji)
//        title = try container.decode(String.self, forKey: .title)
//        summary = try container.decode(String.self, forKey: .summary)
//        prompt = try container.decode(String.self, forKey: .prompt)
//        
//        components = []
//        
//        var componentContainer = try container.nestedUnkeyedContainer(forKey: .components)
//        while (!componentContainer.isAtEnd) {
//            let nestedDecoder = try componentContainer.superDecoder()
//            let containerAsPanelComponentDecodable = try nestedDecoder.container(keyedBy: PanelComponentDecodable.CodingKeys.self)
//            let type = try containerAsPanelComponentDecodable.decode(String.self, forKey: .type)
////            let panelComponentType = PanelComponentType.from(type)
////            print(panelComponentType)
//            
////            switch panelComponentType {
////            case .barSelection:
////                
////                let barSelectionComponent = try nestedDecoder.container(keyedBy: BarSelectionPanelComponent.CodingKeys.self)
////                components.append(barSelectionComponent.decode(BarSelectionPanelComponent.self, forKey: .))
////            }
//        }
//        
//    }
//    
//    func encode(to encoder: Encoder) throws {
//        
//    }
//    
//}
