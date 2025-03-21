//
//  RoundedBorderModifier.swift
//  Barback
//
//  Created by Alex Coundouriotis on 9/22/23.
//

import SwiftUI

struct RoundedBorderModifier<S: ShapeStyle>: ViewModifier {
    
    var cornerRadius: CGFloat = 20.0
    var strokeStyle: S
    var lineWidth: CGFloat = 2.0
    
    func body(content: Content) -> some View {
        content
            .background(Colors.foreground)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(strokeStyle /* TODO: Is this fine here */, lineWidth: lineWidth))
    }
    
}

@available(iOS 17, *)
#Preview(traits: .sizeThatFitsLayout) {
    Text("Some Text")
        .padding()
        .modifier(RoundedBorderModifier(strokeStyle: Colors.elementBackground))
        .background(Colors.background)
}
