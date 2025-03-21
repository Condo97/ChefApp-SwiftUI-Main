//
//  AddToPantryListItem.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 3/18/25.
//

import SwiftUI

public struct AddToPantryListItem<Content: View>: View {
    
    @ViewBuilder var content: () -> Content
    
    public var body: some View {
        VStack(spacing: 0.0) {
            HStack {
                content()
            }
            .frame(maxWidth: .infinity)
            .foregroundStyle(Colors.foregroundText)
            .padding()
            .background(Colors.foreground)
            
            Divider()
        }
    }
    
}
