//
//  PanelTextField.swift
//  Barback
//
//  Created by Alex Coundouriotis on 9/22/23.
//

import SwiftUI

struct PanelTextField: View {
    
    var placeholder: String
    
    @Binding var text: String
    
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack {
            TextField(placeholder, text: $text, axis: .vertical)
                .textFieldTickerTint(colorScheme == .light ? Colors.elementBackground : Colors.foregroundText) // TODO: Make sure the light mode ticker tint is correct, I removed textFieldTickerTint which was controlling the tint here
                .keyboardDismissingTextFieldToolbar("Done", color: Colors.elementBackground)
            .padding()
            .font(.custom(Constants.FontName.body, size: 17.0))
            .lineLimit(.max)
//                Spacer()
        }
        .modifier(RoundedBorderModifier(strokeStyle: Colors.background))
    }
    
}

#Preview {
    PanelTextField(
        placeholder: "Placeholder",
        text: .constant("Text")
    )
    .background(Colors.background)
}
