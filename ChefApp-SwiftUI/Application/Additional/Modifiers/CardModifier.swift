//
//  CardModifier.swift
//  Barback
//
//  Created by Alex Coundouriotis on 9/21/23.
//

import SwiftUI

struct CardModifier: ViewModifier {
    
    var backgroundColor: Color = Colors.foreground
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 14.0))
    }
    
}

extension View {
    
    public func card() -> some View {
        modifier(CardModifier(backgroundColor: .black))
    }
    
}
