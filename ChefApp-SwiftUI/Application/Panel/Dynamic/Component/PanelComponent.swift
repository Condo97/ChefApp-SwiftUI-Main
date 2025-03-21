//
//  PanelComponent.swift
//  Barback
//
//  Created by Alex Coundouriotis on 9/17/23.
//

import Foundation

struct PanelComponent: Identifiable, Codable, Hashable {
    
    var id = UUID()
    
    var input: Input // For decoding - Sring value, configs are in the base PanelComponent {}
    var title: String
    var example: String?
    var detailTitle: String?
    var detailText: String?
    var promptPrefix: String?
    var required: Bool?
    
    var finalizedPrompt: String?
    
    enum Input: Codable, Hashable {
        case barSelection
        case dropdown(DropdownPanelComponentViewConfig)
        case ingredientsInput(TextFieldPanelComponentViewConfig)
        case textField(TextFieldPanelComponentViewConfig)
    }
    
    enum CodingKeys: String, CodingKey {
        case input
        case title
        case example
        case detailTitle
        case detailText
        case promptPrefix
        case required
    }
    
}

extension PanelComponent {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        self.detailTitle = try container.decodeIfPresent(String.self, forKey: .detailTitle)
        self.example = try container.decodeIfPresent(String.self, forKey: .example)
        self.detailText = try container.decodeIfPresent(String.self, forKey: .detailText)
        self.promptPrefix = try container.decodeIfPresent(String.self, forKey: .promptPrefix)
        self.required = try container.decodeIfPresent(Bool.self, forKey: .required)
        
        let inputString = try container.decode(String.self, forKey: .input)
        switch inputString.lowercased() {
        case "barselection":
            input = .barSelection
        case "dropdown":
//            let dropdownContainer = try decoder.container(keyedBy: DropdownPanelComponentViewConfig.CodingKeys.self)
//            let dropdownViewConfig = try dropdownContainer.decode(<#T##type: Bool.Type##Bool.Type#>, forKey: <#T##KeyedDecodingContainer<DropdownPanelComponentViewConfig.CodingKeys>.Key#>)
            input = .dropdown(try DropdownPanelComponentViewConfig(from: decoder))
        case "ingredientsinput":
            input = .ingredientsInput(try TextFieldPanelComponentViewConfig(from: decoder))
        case "textfield":
            input = .textField(try TextFieldPanelComponentViewConfig(from: decoder))
        default:
            throw DecodingError.valueNotFound(Input.self, DecodingError.Context(codingPath: [CodingKeys.input], debugDescription: "Could not find a valid value for \"input\" in the JSON. Please check your spelling and make sure you are using a valid input name."))
        }
    }
    
}

extension PanelComponent {
    
    var requiredUnwrapped: Bool {
        get {
            required ?? false
        }
        set {
            required = newValue
        }
    }
    
}


/***
 
 Panel json reference for and from GPT
 
 {
   "panels": [
     {
       "emoji": "🔧",
       "title": "Documentation Example",
       "summary": "This is a panel for documentation purposes.",
       "prompt": "Prompt for prompting AI to generate",
       "components": [
         {
           "input": "textField",
           "title": "Title displayed to user.",
           "example": "Example as placeholder for textField",
           "detailTitle": "Optional, shown as the title for a popup if user seeks more information",
           "detailText": "Optional, shown as the body for a popup if user seeks more information.",
           "promptPrefix": "Tells the AI what this field is about",
           "required": bool
         },
         {
           "input": "dropdown",
           "title": "Choose an option",
           "detailTitle": "Optional, shown as the title for a popup if user seeks more information",
           "detailText": "Optional, shown as the body for a popup if user seeks more information.",
           "promptPrefix": "Tells the AI what this field is about",
           "placeholder": "Placeholder for first option",
           "items": [
             "Option 1",
             "Option 2",
             "Option 3"
           ],
           "required": bool
         },
         {
           "input": "ingredientsInput",
           "title": "Enter ingredients",
           "detailTitle": "Optional, shown as the title for a popup if user seeks more information",
           "detailText": "Optional, shown as the body for a popup if user seeks more information.",
           "promptPrefix": "Tells the AI what this field is about",
           "required": bool
         }
       ]
     }
   ]
 }
 
 */

//protocol PanelComponent: Identifiable, Codable, Hashable {
//    
//    var id: UUID { get set }
//    
//    var title: String { get set }
//    var detailTitle: String? { get set }
//    var detailText: String? { get set }
//    var promptPrefix: String { get set }
//    var required: Bool? { get set }
//    
//    var finalizedPrompt: String? { get }
//    
//}
//
//extension PanelComponent {
//    
//    var requiredUnwrapped: Bool {
//        get {
//            required ?? false
//        }
//        set {
//            required = newValue
//        }
//    }
//    
//}
