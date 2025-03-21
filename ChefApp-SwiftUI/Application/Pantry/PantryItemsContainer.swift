//
//  PantryItemsContainer.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 11/29/24.
//

import SwiftUI

struct PantryItemsContainer: View {
    
    @Binding var selectedItems: [PantryItem]
    @Binding var editMode: EditMode
    let showsContextMenu: Bool
    let selectionColor: PantryItemButton.SelectionColors
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @SectionedFetchRequest<String?, PantryItem>(
        sectionIdentifier: \.category,
        sortDescriptors: [
            NSSortDescriptor(keyPath: \PantryItem.category, ascending: true),
            NSSortDescriptor(keyPath: \PantryItem.name, ascending: true)
        ],
        animation: .default)
    private var sectionedPantryItems: SectionedFetchResults<String?, PantryItem>
    
    var body: some View {
        PantryItemsView(
            selectedItems: $selectedItems,
            editMode: $editMode,
            sectionedPantryItems: _sectionedPantryItems,
            showsContextMenu: showsContextMenu,
            selectionColor: selectionColor)
    }
    
}

//#Preview {
//    PantryItemsContainer()
//}
