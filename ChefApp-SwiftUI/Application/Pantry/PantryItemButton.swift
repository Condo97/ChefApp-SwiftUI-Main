//
//  PantryItemButton.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 11/29/24.
//

import SwiftUI

struct PantryItemButton: View {
    
    let pantryItem: PantryItem
    let selectionColor: SelectionColors
    let showsContextMenu: Bool
    @Binding var selectedItems: [PantryItem]
    @Binding var editMode: EditMode
    @Binding var editingPantryItem: PantryItem?
    
    enum SelectionColors {
        case green
        case red
        
        var color: Color {
            switch self {
            case .green: Color(UIColor.systemGreen).opacity(0.4)
            case .red: Color(UIColor.systemRed).opacity(0.4)
            }
        }
    }
    
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        KeyboardDismissingButton(action: {
            HapticHelper.doLightHaptic()
            
            if editMode == .active {
                // Delete if editing
                Task {
                    do {
                        try await CDClient.delete(pantryItem, in: viewContext)
                    } catch {
                        // TODO: Handle Errors
                        print("Error deleting pantry item in PantryView... \(error)")
                    }
                }
            } else {
                // Add to selectedItems if not editing
                if selectedItems.contains(pantryItem) {
                    withAnimation(.bouncy(duration: 0.5)) {
                        selectedItems.removeAll(where: {$0 == pantryItem})
                    }
                } else {
                    withAnimation(.bouncy(duration: 0.5)) {
                        selectedItems.append(pantryItem)
                    }
                }
            }
        }) {
            HStack {
                PantryItemView(pantryItem: pantryItem)
                .frame(maxHeight: .infinity)
                
                if editMode == .active {
                    Image(systemName: "xmark")
                        .imageScale(.small)
                        .foregroundStyle(Color(UIColor.systemRed))
                }
            }
        }
        .padding([.top, .bottom], 8)
        .padding([.leading, .trailing], 16)
        .background(selectedItems.contains(pantryItem) && editMode != .active ? selectionColor.color : .clear)
        .background(Colors.foreground)
        .clipShape(RoundedRectangle(cornerRadius: 14.0))
        .contextMenu {
            if showsContextMenu {
                // TODO: Impelment context menu
                Button("Edit", systemImage: "pencil") {
                    editingPantryItem = pantryItem
                }
                
                Divider()
                
                Button("Delete", systemImage: "trash", role: .destructive) {
                    Task {
                        do {
                            try await CDClient.delete(pantryItem, in: viewContext)
                        } catch {
                            // TODO: Handle Errors
                            print("Error deleting pantry item in PantryView... \(error)")
                        }
                    }
                }
            }
        }
    }
    
}

//#Preview {
//    PantryItemButton()
//}
