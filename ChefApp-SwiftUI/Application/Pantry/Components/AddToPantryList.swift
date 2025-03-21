//
//  AddToPantryList.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 3/18/25.
//

import SwiftUI

struct AddToPantryList: View {
    
    @Binding var automaticEntryItems: [String]
    @ObservedObject var pantryItemsParser: PantryItemsParser
    
    var body: some View {
        // New Pantry Items
        VStack(spacing: 0.0) {
            // Empty list preview
            if automaticEntryItems.isEmpty && !pantryItemsParser.isLoadingGetPantryItemsFromImage {
                // List preview
                AddToPantryListItem {
                    Text("Pantry items will appear here.")
                        .font(.body, 14.0)
                        .foregroundStyle(Colors.foregroundText)
                        .opacity(0.6)
                }
            }
            
            if pantryItemsParser.isLoadingGetPantryItemsFromImage {
                AddToPantryListItem {
                    Text("Loading Scan...") // TODO: Pretty sure this is the only use case for this text to display but if there are more use cases it is necessary to change this text
                        .font(.body, 17)
                    Spacer()
                    ProgressView()
                }
            }
            ForEach(automaticEntryItems.reversed(), id: \.self) { item in
                AddToPantryListItem {
                    Text(item)
                        .font(.body, 17)
                    Spacer()
                    Button(action: {
                        automaticEntryItems.removeAll(where: {$0 == item})
                    }) {
                        Image(systemName: "xmark")
                    }
                    .font(.body, 14.0)
                    .foregroundStyle(Color(.systemRed))
                }
            }
        }
    }
    
}
