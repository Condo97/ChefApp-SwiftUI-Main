//
//  PantryItemsView.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 11/29/24.
//

import SwiftUI

struct PantryItemsView: View {
    
    @Binding var selectedItems: [PantryItem]
    @Binding var editMode: EditMode
    @SectionedFetchRequest var sectionedPantryItems: SectionedFetchResults<String?, PantryItem>
    let showsContextMenu: Bool
    let selectionColor: PantryItemButton.SelectionColors
    
    
    enum TypeSections: String {
        case alcoholTypeSectioned = "Type"
    }
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var editingPantryItem: PantryItem?
    
    @State private var typeSectionFilter: TypeSections = .alcoholTypeSectioned
    
    private var selectButtonShouldSelectAll: Bool {
        switch typeSectionFilter {
        case .alcoholTypeSectioned:
            selectedItems.count < sectionedPantryItems.count
        }
    }
    
    private var allPantryItemsBasedOnTypeSectionFilter: SectionedFetchResults<String?, PantryItem> {
        switch typeSectionFilter {
        case .alcoholTypeSectioned:
            sectionedPantryItems
        }
    }
    
    var body: some View {
        list
            .editPantryItemPopup(pantryItem: $editingPantryItem)
    }
    
    var list: some View {
        SingleAxisGeometryReader(axis: .horizontal) { geo in
//        GeometryReader { geo in
            VStack(alignment: .leading) {
                ForEach(sectionedPantryItems) { pantryItems in
                    HStack {
                        Group {
                            if let id = pantryItems.id {
                                Text(id)
                            } else {
                                VStack(alignment: .leading) {
                                    Text("Not Sorted")
                                    Text("Re-Sort to group in categories.")
                                        .font(.custom(Constants.FontName.body, size: 12.0))
                                }
                            }
                        }
                        .font(.custom(Constants.FontName.black, size: 20.0))
                        .foregroundStyle(Colors.foregroundText)
                        .padding([.leading, .trailing])
                        
                        Spacer()
                    }
                    
                    // TODO: It looks like this is not extending to the width of the view or something
                    FlexibleView(availableWidth: geo.magnitude - 50, data: pantryItems, spacing: 8.0, alignment: .leading) { pantryItem in
                        PantryItemButton(
                            pantryItem: pantryItem,
                            selectionColor: selectionColor,
                            showsContextMenu: showsContextMenu,
                            selectedItems: $selectedItems,
                            editMode: $editMode,
                            editingPantryItem: $editingPantryItem)
                        .frame(maxWidth: 350.0)
                    }
                    .padding(.bottom, 8)
                    .padding([.leading, .trailing])
//                    .frame(maxWidth: 400.0) // TODO: This is a quick fix! For when transitioning from pantry view to sheet view
                }
            }
        }
    }
}

//#Preview {
//    PantryItemsView()
//}
