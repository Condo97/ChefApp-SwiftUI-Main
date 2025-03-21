////
////  PanelComponentType.swift
////  Barback
////
////  Created by Alex Coundouriotis on 9/17/23.
////
//
//import Foundation
//
//enum PanelComponentType {
//    
//    case barSelection
//    case dropdown(DropdownPanelComponentViewConfig)
//    case ingredientsInput
//    case textField
//    
//}

//enum PanelComponentType: Identifiable, Codable, Hashable {
//    
//    var id: UUID {
//        any.id
//    }
//    
//    case barSelection(BarSelectionPanelComponent)
//    case dropdown(DropdownPanelComponent)
//    case ingredientsInput(IngredientsInputPanelComponent)
//    case textField(TextFieldPanelComponent)
//    
//    var any: any PanelComponent {
//        switch self {
//        case .barSelection(let component):
//            component
//        case .dropdown(let component):
//            component
//        case .ingredientsInput(let component):
//            component
//        case .textField(let component):
//            component
//        }
//    }
//    
//}
//
//extension PanelComponentType {
//    
//    enum CodingKeys: String, CodingKey {
//        
//        case type
//        
//    }
//    
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        let singleContainer = try decoder.singleValueContainer()
//        
//        let type = try container.decode(String.self, forKey: .type)
//        switch type.lowercased() {
//        case "barSelection".lowercased():
//            let barSelectionPanelComponent = try singleContainer.decode(BarSelectionPanelComponent.self)
//            self = .barSelection(barSelectionPanelComponent)
//        case "dropdown".lowercased():
//            let dropdownPanelComponent = try singleContainer.decode(DropdownPanelComponent.self)
//            self = .dropdown(dropdownPanelComponent)
//        case "ingredientsInput".lowercased():
//            let ingredientsInputPanelComponent = try singleContainer.decode(IngredientsInputPanelComponent.self)
//            self = .ingredientsInput(ingredientsInputPanelComponent)
//        case "textField".lowercased():
//            let textFieldPanelComponent = try singleContainer.decode(TextFieldPanelComponent.self)
//            self = .textField(textFieldPanelComponent)
////        case "multilineInput".lowercased():
////            let textViewPanelComponent = try singleContainer.decode(TextViewPanelComponent.self)
////            self = .textView(textViewPanelComponent)
//        default:
//            throw DecodingError.valueNotFound(Self.self, DecodingError.Context(codingPath: container.codingPath, debugDescription: "Invalid type for PanelComponentType.. \(type)"))
//        }
//    }
//    
//    func encode(to encoder: Encoder) throws {
//        var singleContainer = encoder.singleValueContainer()
//        
//        switch self {
//        case .barSelection(let barSelectionPanelComponent):
//            try singleContainer.encode(barSelectionPanelComponent)
//        case .dropdown(let dropdownPanelComponent):
//            try singleContainer.encode(dropdownPanelComponent)
//        case .ingredientsInput(let ingredientsInputPanelComponent):
//            try singleContainer.encode(ingredientsInputPanelComponent)
//        case .textField(let textFieldPanelComponent):
//            try singleContainer.encode(textFieldPanelComponent)
////        case .textView(let textViewPanelComponent):
////            try singleContainer.encode(textViewPanelComponent)
//        }
//    }
//    
//}
