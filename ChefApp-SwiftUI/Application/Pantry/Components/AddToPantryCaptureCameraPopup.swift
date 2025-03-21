//
//  AddToPantryCaptureCameraPopup.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 3/18/25.
//

import SwiftUI

struct AddToPantryCaptureCameraPopup: View {
    
    @Binding var automaticEntryItems: [String]
    @ObservedObject var pantryItemsParser: PantryItemsParser
    let onDismiss: () -> Void
    
    var body: some View {
        CaptureCameraPopup(
            onAttach: { image, cropFrame, uncroppedImage in
                guard let image else {
                    // TODO: [Error Handling] Handle Errors
                    print("Received nil image in AddToPantryCaptureCameraPopup!")
                    return
                }
                
                Task {
                    do {
                        // Get pantryItemStrings from image and add them to automaticEntryItems
                        let pantryItemStrings = try await pantryItemsParser.parseGetPantryItemsFromImage(image: image, input: nil).map({$0.name})
                        
                        automaticEntryItems.append(contentsOf: pantryItemStrings)
                    } catch {
                        // TODO: Handle Errors
                        print("Error getting pantry item text from image in InsertPantryItemView... \(error)")
                    }
                }
                
                withAnimation {
                    onDismiss()
                }
            },
            onDismiss: {
                HapticHelper.doLightHaptic()
                
                withAnimation {
                    onDismiss()
                }
            })
    }
    
}


extension View {
    
    func addToPantryCaptureCameraPopup(isPresented: Binding<Bool>, automaticEntryItems: Binding<[String]>, pantryItemsParser: PantryItemsParser) -> some View {
        self
            .fullScreenCover(isPresented: isPresented) {
                AddToPantryCaptureCameraPopup(
                    automaticEntryItems: automaticEntryItems,
                    pantryItemsParser: pantryItemsParser,
                    onDismiss: {
                        withAnimation {
                            isPresented.wrappedValue = false
                        }
                    })
            }
    }
    
}
