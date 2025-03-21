//
//  AddToPantryTextInputEntry.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 3/18/25.
//

import SwiftUI

struct AddToPantryTextInputEntry: View {
    
    @Binding var entryText: String
    let onParseEntryText: () -> Void
    
    let instructionText: String = "Enter items to add to your pantry or fridge. Include produce, meats, branded items, and more."
    let instructionExampleText: String = "ex. \"Lemon, Chicken, Pasta, Tomato Paste, etc."
    let placeholderText: String = "Ingredient..."
    
    @Environment(\.colorScheme) private var colorScheme
    
    @FocusState private var automaticEntryTextFieldFocusState
    
    var body: some View {
        // Text field
        TextField(placeholderText, text: $entryText)
            .textFieldTickerTint(colorScheme == .light ? Colors.elementBackground : Colors.foregroundText)
            .keyboardDismissingTextFieldToolbar("Done", color: Colors.elementBackground)
            .focused($automaticEntryTextFieldFocusState)
            .font(.custom(Constants.FontName.body, size: 17.0))
            .foregroundColor(Colors.foregroundText)
            .padding()
            .background(Colors.foreground)
            .clipShape(RoundedRectangle(cornerRadius: 20.0))
            .padding(.horizontal)
            .onSubmit {
                // Set textField to focused to bring up keyboard
                UIView.performWithoutAnimation {
                    automaticEntryTextFieldFocusState = true
                }
                
                // Parse entry text
                onParseEntryText()
            }
        
        // Add button
        if !entryText.isEmpty {
            Button(action: {
                // Parse entry text
                onParseEntryText()
            }) {
                ZStack {
                    Text("Add")
                        .font(.heavy, 20.0)
                    Image(systemName: "return")
                        .font(.body, 20.0)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .foregroundStyle(Colors.elementText)
                .padding()
            }
            .foregroundColor(Colors.foregroundText)
            .background(Colors.elementBackground)
            .clipShape(RoundedRectangle(cornerRadius: 20.0))
            .padding(.horizontal)
        }
        
        // Instructions
        Text(instructionText)
            .font(.custom(Constants.FontName.light, size: 14.0))
            .multilineTextAlignment(.center)
            .opacity(0.4)
        Text(instructionExampleText)
            .font(.custom(Constants.FontName.lightOblique, size: 14.0))
            .multilineTextAlignment(.center)
            .opacity(0.4)
    }
    
}
