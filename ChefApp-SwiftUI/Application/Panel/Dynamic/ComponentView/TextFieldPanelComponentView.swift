//
//  TextFieldPanelComponentView.swift
//  Barback
//
//  Created by Alex Coundouriotis on 9/22/23.
//

import SwiftUI

struct TextFieldPanelComponentView: ComponentView {
    
    var panelComponent: PanelComponent
    var textFieldPanelComponentViewConfig: TextFieldPanelComponentViewConfig
    
    @Binding var finalizedPrompt: String?
    @State var text: String = ""
    
    
    var body: some View {
        
        VStack(spacing: 2) {
            TitlePanelComponentView(
                panelComponent: panelComponent)
            PanelTextField(
                placeholder: textFieldPanelComponentViewConfig.placeholderUnwrapped,
                text: $text)
            .onChange(of: text) { newText in
                updateFinalizedPrompt()
            }
            ExampleComponentView(
                panelComponent: panelComponent)
        }
        
    }
    
    func updateFinalizedPrompt() {
        guard !text.isEmpty else {
            finalizedPrompt = nil
            return
        }
        
        finalizedPrompt = (panelComponent.promptPrefix == nil ? "" : panelComponent.promptPrefix! + " ") + text
    }
    
}

@available(iOS 17, *)
#Preview(traits: .sizeThatFitsLayout) {
    let textFieldPanelComponentViewConfig = TextFieldPanelComponentViewConfig()
    
    let panelComponent = PanelComponent(
        input: .textField(textFieldPanelComponentViewConfig),
        title: "Title",
        detailTitle: "Test Detail Title",
        detailText: "Test Detail Text",
        promptPrefix: "Prompt Prefix",
        required: true)
    
    return TextFieldPanelComponentView(
        panelComponent: panelComponent,
        textFieldPanelComponentViewConfig: textFieldPanelComponentViewConfig,
        finalizedPrompt: .constant("asdf"))
    .padding()
    .background(Colors.background)
}
