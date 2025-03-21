////
////  OnlyCameraInsertPantryItemView.swift
////  ChefApp-SwiftUI
////
////  Created by Alex Coundouriotis on 6/23/24.
////
//
//import SwiftUI
//
//struct OnlyCameraInsertPantryItemView: View {
//    // Shows the camera and on attach immediately parses and saves pantry items from the image
//    
//    @Binding var isPresented: Bool
//    
//    
//    @Environment(\.managedObjectContext) private var viewContext
//    
//    
//    @StateObject private var pantryItemsParser: PantryItemsParser = PantryItemsParser()
//    
//    
//    var body: some View {
//        CaptureCameraViewControllerRepresentable(
//            reset: .constant(false),
//            onAttach: { image, cropFrame, unmodifiedImage in
//                Task {
//                    do {
//                        // Parse and save pantry items immediately
//                        try await pantryItemsParser.parseSavePantryItems(image: image, input: nil, in: viewContext)
//                        
//                        // Do success haptic
//                        HapticHelper.doSuccessHaptic()
//                    } catch PantryItemPersistenceError.duplicatePantryItemNames(let pantryItemNames) {
//                        // TODO: Show alert with duplicate pantry item names and stuff
//                        
//                        // Do success haptic
//                        HapticHelper.doSuccessHaptic()
//                    } catch {
//                        // TODO: Handle Errors
//                        print("Error getting pantry item text from image in InsertPantryItemView... \(error)")
//                        
//                        
//                        HapticHelper.doWarningHaptic()
//                    }
//                }
//                
//                withAnimation {
//                    isPresented = false
//                }
//            })
//    }
//    
//}
//
//#Preview {
//    
//    OnlyCameraInsertPantryItemView(isPresented: .constant(false))
//        .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
//    
//}
