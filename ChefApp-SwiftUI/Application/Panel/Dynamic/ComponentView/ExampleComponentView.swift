//
//  ExampleComponentView.swift
//  Barback
//
//  Created by Alex Coundouriotis on 10/10/23.
//

import SwiftUI

struct ExampleComponentView: View {
    
    var panelComponent: PanelComponent
    
    var body: some View {
        if let example = panelComponent.example {
            HStack {
                Text("ex. \(example)")
                    .font(.custom(Constants.FontName.lightOblique, size: 12.0))
                    .foregroundStyle(Colors.foregroundText)
                    .opacity(0.6)
                Spacer()
            }
        }
    }
}

@available(iOS 17.0, *)
#Preview(traits: .sizeThatFitsLayout) {
    ExampleComponentView(panelComponent: PanelComponent(
        input: .textField(TextFieldPanelComponentViewConfig()),
        title: "Title",
        example: "Example",
        promptPrefix: "Prompt Prefix"))
}
