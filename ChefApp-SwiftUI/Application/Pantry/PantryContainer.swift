////
////  PantryContainer.swift
////  ChefApp-SwiftUI
////
////  Created by Alex Coundouriotis on 12/13/24.
////
//
//import SwiftUI
//
//struct PantryContainer: View {
//    
//    var showsEditButton: Bool = false
//    let onDismiss: () -> Void
//    var onCreateRecipe: ((_ pantryItems: [PantryItem]) -> Void)? = nil
//    
//    @State private var selectedItems: [PantryItem] = []
//    
//    var body: some View {
//        PantryView(
//            selectedItems: $selectedItems,
//            onDismiss: onDismiss,
//            onCreateRecipe: onCreateRecipe == nil ? nil : {
//                onCreateRecipe?(selectedItems)
//            })
//    }
//}
//
//#Preview {
//    
//    PantryContainer(
//        showsEditButton: true,
//        onDismiss: {
//            
//        },
//        onCreateRecipe: { recipe in
//            
//        }
//    )
//    
//}
