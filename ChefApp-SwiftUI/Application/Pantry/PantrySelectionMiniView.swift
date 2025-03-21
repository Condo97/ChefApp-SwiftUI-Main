//
//  PantrySelectionMiniView.swift
//  Barback
//
//  Created by Alex Coundouriotis on 9/22/23.
//

import SwiftUI

struct PantrySelectionMiniView: View {
    
    @Binding var selectedPantryItems: [PantryItem]
    @State var showsAdvancedOptions: Bool = true
    @Binding var generationAdditionalOptions: RecipeGenerationAdditionalOptions
    @State var axis: Axis = .vertical
    
    
    @Namespace private var namespace
    
    @Environment(\.managedObjectContext) var viewContext
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \PantryItem.name, ascending: false)], animation: .default) private var pantryItems: FetchedResults<PantryItem>
    
    @State private var isDisplayingAdvancedOptions: Bool = false
    
    @State private var isShowingPantrySelectionView: Bool = false
    
    @State private var deselectedPantryItems: [PantryItem] = []
    
    
    var body: some View {
        VStack {
            KeyboardDismissingButton(action: {
                HapticHelper.doLightHaptic()
                
                //                    withAnimation(.easeInOut(duration: 0.1)) {
                //                        isPantryShowing = true
                //                    }
                withAnimation {
                    isShowingPantrySelectionView = true
                }
            }) {
                Text("+ Add from Pantry")
                    .font(.custom(Constants.FontName.heavy, size: 14.0))
                    .padding([.leading, .trailing], 16)
                    .padding([.top, .bottom], 8)
                    .foregroundStyle(Colors.elementBackground)
                    .background(Colors.foreground)
                    .clipShape(RoundedRectangle(cornerRadius: 14.0))
                Spacer()
            }
            .padding([.leading, .trailing])
            
            if !selectedPantryItems.isEmpty || !deselectedPantryItems.isEmpty {
                VStack {
                    if axis == .vertical {
                        GeometryReader { geo in
                            VStack(alignment: .leading) {
                                FlexibleView(availableWidth: geo.size.width, data: selectedPantryItems + deselectedPantryItems, spacing: 8.0, alignment: .leading) { selectedPantryItem in
                                    pantryItemButton(for: selectedPantryItem)
                                }
                                .padding([.leading, .trailing])
                                
                                selectionButtons
                            }
                        }
                    } else {
                        VStack {
                            ScrollView(.horizontal) {
                                HStack {
                                    ForEach(selectedPantryItems + deselectedPantryItems) { selectedPantryItem in
                                        pantryItemButton(for: selectedPantryItem)
                                    }
                                }
                                .padding([.leading, .trailing])
                            }
                            .scrollIndicators(.never)
                            
                            selectionButtons
                        }
                    }
                    
                }
            }
        }
        .sheet(isPresented: $isShowingPantrySelectionView) {
            // TODO: Is the next button logic here fine?
            PantryItemsContainer(
                selectedItems: $selectedPantryItems,
                editMode: .constant(.inactive),
                showsContextMenu: true,
                selectionColor: .green)
            .chefAppHeader(
                showsDivider: true,
                left: {
                    
                },
                right: {
                    Button(action: {
                        isShowingPantrySelectionView = false
                    }) {
                        Text("Done")
                            .font(.custom(Constants.FontName.heavy, size: 17.0))
                            .padding(8)
                    }
                })
//            PantryView(
//                selectedItems: $selectedPantryItems,
//                multipleSelection: true,
//                isActive: $isShowingPantrySelectionView,
//                shouldShowEntryView: .constant(false))
            .background(Colors.background)
            .ignoresSafeArea()
        }
    }
    
    
    var selectionButtons: some View {
        PantryRecipeGenerationAdvancedOptionsView(
            isDisplayingAdvancedOptions: $isDisplayingAdvancedOptions,
            generationAdditionalOptions: $generationAdditionalOptions)
    }
    
    
    func pantryItemButton(for selectedPantryItem: PantryItem) -> some View {
        KeyboardDismissingButton(action: {
            HapticHelper.doLightHaptic()
            
            // TODO: Turn green and add to generate list or something when tapped
            if !selectedPantryItems.contains(where: {$0 == selectedPantryItem}) {
                withAnimation(.bouncy) {
                    selectedPantryItems.append(selectedPantryItem)
                    deselectedPantryItems.removeAll(where: {$0 == selectedPantryItem})
                }
            } else {
                withAnimation(.bouncy) {
                    selectedPantryItems.removeAll(where: {$0 == selectedPantryItem})
                    
                    if !deselectedPantryItems.contains(selectedPantryItem) {
                        deselectedPantryItems.append(selectedPantryItem)
                    }
                }
            }
        }) {
            PantryItemView(pantryItem: selectedPantryItem)
                .frame(maxHeight: .infinity)
        }
        .padding([.top, .bottom], 8)
        .padding([.leading, .trailing], 16)
        .background(
            selectedPantryItems.contains(where: {$0 == selectedPantryItem})
            ?
            Color(uiColor: .systemGreen).opacity(0.4)
            :
                Colors.foreground
        )
        .cornerRadius(14.0)
    }
    
    
}

#Preview {
    PantrySelectionMiniView(
        selectedPantryItems: .constant([]),
        generationAdditionalOptions: .constant(.normal))
        .background(Colors.background)
        .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
}
