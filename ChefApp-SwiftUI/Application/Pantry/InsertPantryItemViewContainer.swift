////
////  InsertPantryItemViewContainer.swift
////  ChefApp-SwiftUI
////
////  Created by Alex Coundouriotis on 6/22/24.
////
//
//import SwiftUI
//
//struct InsertPantryItemViewContainer: View {
//    
//    @Binding var isActive: Bool
//    let showCameraOnAppear: Bool
//    
//    @Environment(\.managedObjectContext) private var viewContext
//    
//    
//    @State private var manualPantryItem: PantryItem?
//    
//    private var isShowingEditPantryItemViewForManualPantryItemEntry: Binding<Bool> {
//        Binding(
//            get: {
//                manualPantryItem != nil
//            },
//            set: { value in
//                if !value {
//                    manualPantryItem = nil
//                }
//            })
//    }
//    
//    var body: some View {
//        ZStack {
//            if let manualPantryItem = manualPantryItem {
//                EditPantryItemView(pantryItem: manualPantryItem, isActive: isShowingEditPantryItemViewForManualPantryItemEntry)
//            } else {
//                InsertPantryItemView(
//                    isShowing: $isActive,
//                    isShowingCaptureCameraView: showCameraOnAppear,
//                    onUseManualEntry: {
//                        Task {
//                            do {
//                                manualPantryItem = try await viewContext.perform {
//                                    let pantryItem = PantryItem(context: viewContext)
//                                    
//                                    try viewContext.save()
//                                    
//                                    return pantryItem
//                                }
//                            } catch {
//                                // TODO: Handle Errors
//                                print("Error inserting manual pantry item in InsertPantryItemViewContainer... \(error)")
//                            }
//                        }
//                    })
//            }
//        }
//        .onChange(of: isShowingEditPantryItemViewForManualPantryItemEntry.wrappedValue) { newValue in
//            if !newValue {
//                isActive = false
//            }
//        }
//    }
//    
//}
//
//#Preview {
//    
//    InsertPantryItemViewContainer(
//        isActive: .constant(true),
//        showCameraOnAppear: false)
//        .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
//        .environmentObject(PremiumUpdater())
//        .environmentObject(ProductUpdater())
//        .environmentObject(RemainingUpdater())
//    
//}
